#!/usr/bin/env bash
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

GRAVITEEIO_AM_CONSOLE_UI_HOST="http://localhost/am/ui"
GRAVITEEIO_AM_MGT_API_HOST="http://localhost/am/management"

TOKEN=$(curl -u admin:adminadmin -s -X POST $GRAVITEEIO_AM_MGT_API_HOST/auth/token | jq -r ".access_token")

echo -e "\nUpdate the entrypoint value"
DEFAULT_ENTRYPOINT_ID=$(curl -H "Authorization: Bearer $TOKEN" -s -X GET $GRAVITEEIO_AM_MGT_API_HOST/organizations/DEFAULT/entrypoints  | jq -r ".[0].id")
curl -s -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type:application/json;charset=UTF-8" \
     -X PUT \
     -d '{"name":"Default","description":"Default entrypoint","url":"http://localhost/am","tags":[]}' \
     "$GRAVITEEIO_AM_MGT_API_HOST/organizations/DEFAULT/entrypoints/$DEFAULT_ENTRYPOINT_ID"

echo -e "\nCreate the domain"
DOMAIN_ID=$(curl -s -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type:application/json;charset=UTF-8" \
     -X POST \
     -d '{"name":"Local","description":"My First Security Domain description"}' \
     $GRAVITEEIO_AM_MGT_API_HOST/organizations/DEFAULT/environments/DEFAULT/domains | jq -r ".id")

echo -e "\nEnable the domain"
curl -s -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type:application/json;charset=UTF-8" \
     -X PATCH \
     -d '{"enabled": true}' \
     "$GRAVITEEIO_AM_MGT_API_HOST/organizations/DEFAULT/environments/DEFAULT/domains/$DOMAIN_ID"

echo -e "\nAllow localhost & http redirect uri"
curl -s -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type:application/json;charset=UTF-8" \
     -X PATCH \
     -d '{
             "oidc": {
                 "clientRegistrationSettings": {
                     "allowLocalhostRedirectUri": true,
                     "allowHttpSchemeRedirectUri": true,
                     "allowWildCardRedirectUri": false,
                     "isDynamicClientRegistrationEnabled": false,
                     "isOpenDynamicClientRegistrationEnabled": false,
                     "isAllowedScopesEnabled": false,
                     "isClientTemplateEnabled": false
                 },
                 "securityProfileSettings": {
                     "enablePlainFapi": false,
                     "enableFapiBrazil": false
                 },
                 "redirectUriStrictMatching": false,
                 "cibaSettings": {
                     "enabled": false,
                     "authReqExpiry": 600,
                     "tokenReqInterval": 5,
                     "bindingMessageLength": 256
                 }
             }
         }' \
     "$GRAVITEEIO_AM_MGT_API_HOST/organizations/DEFAULT/environments/DEFAULT/domains/$DOMAIN_ID"


echo -e "\ncreate inline provider"
PROVIDER_ID=$(curl -s -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type:application/json;charset=UTF-8" \
     -X POST \
     -d '{
           "external": false,
           "type": "inline-am-idp",
           "configuration": "{\"users\":[{\"firstname\":\"Alice\",\"lastname\":\"Dupont\",\"username\":\"alice\",\"password\":\"pass\"}]}",
           "name": "Inline IdP"
         }' \
     "$GRAVITEEIO_AM_MGT_API_HOST/organizations/DEFAULT/environments/DEFAULT/domains/$DOMAIN_ID/identities" | jq -r ".id")

echo -e "\ncreate an application"
APPLICATION_ID=$(curl -s -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type:application/json;charset=UTF-8" \
     -X POST \
     -d '{
             "name": "example",
             "type": "BROWSER",
             "redirectUris": [
                 "http://localhost:4200"
             ]
         }' \
     "$GRAVITEEIO_AM_MGT_API_HOST/organizations/DEFAULT/environments/DEFAULT/domains/$DOMAIN_ID/applications" | jq -r ".id")


echo -e "\nConfigure application"
curl -s -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type:application/json;charset=UTF-8" \
     -X PATCH \
     -d "{
            \"settings\": {
                \"oauth\": {
                    \"grantTypes\": [
                        \"authorization_code\",
                        \"refresh_token\"
                    ],
                    \"enhanceScopesWithUserPermissions\": false,
                    \"scopeSettings\": [
                        { \"scope\": \"openid\", \"defaultScope\": false },
                        { \"scope\": \"profile\", \"defaultScope\": false },
                        { \"scope\": \"email\",   \"defaultScope\": false }
                    ],
                    \"redirectUris\": [
                        \"http://localhost:4200\"
                    ],
                    \"postLogoutRedirectUris\": [],
                    \"singleSignOut\": false,
                    \"silentReAuthentication\": false
                },
                \"advanced\": {
                    \"skipConsent\": true
                }
            },
            \"identityProviders\": [
                {
                    \"identity\": \"$PROVIDER_ID\",
                    \"selectionRule\": \"\",
                    \"priority\": 0
                }
            ]
         }" \
     "$GRAVITEEIO_AM_MGT_API_HOST/organizations/DEFAULT/environments/DEFAULT/domains/$DOMAIN_ID/applications/$APPLICATION_ID"

echo -e "\nget OAuth2 clientId"
OAUTH_CLIENT_ID=$(curl -s -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type:application/json;charset=UTF-8" \
     -X GET "$GRAVITEEIO_AM_MGT_API_HOST/organizations/DEFAULT/environments/DEFAULT/domains/$DOMAIN_ID/applications/$APPLICATION_ID" | jq -r ".settings.oauth.clientId")

echo "==> OAuth2 client Id: $OAUTH_CLIENT_ID"
echo "==> AM application overview: $GRAVITEEIO_AM_CONSOLE_UI_HOST/environments/default/domains/local/applications/$APPLICATION_ID/overview"
