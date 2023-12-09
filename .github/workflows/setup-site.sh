#!/bin/bash
set -eo pipefail

auth0 login \
  --domain $AUTH0_DOMAIN \
  --client-id $AUTH0_CLIENT_ID \
  --client-secret $AUTH0_CLIENT_SECRET
auth0 tenants use $AUTH0_DOMAIN

export SITE_CLIENT_ID=$(auth0 apps create \
  --name $SITE_DOMAIN \
  --description "$SITE_DOMAIN" \
  --type spa \
  --callbacks "https://$SITE_DOMAIN/auth/" \
  --logout-urls "https://$SITE_DOMAIN/auth/" \
  --origins "https://$SITE_DOMAIN" \
  --web-origins "https://$SITE_DOMAIN" \
  --json --no-input -r | jq -r '.client_id')

auth0 api connections | jq -r '.[].id' | xargs -I{} auth0 api patch connections/{} --data '{"enabled_clients":[]}'
cat <<EOF | auth0 api post connections
{
  "options": {
    "client_id": "$GH_CLIENT_ID",
    "client_secret": "$GH_CLIENT_SECRET",
    "gist": false,
    "repo": true,
    "email": false,
    "scope": [
      "repo"
    ],
    "follow": false,
    "profile": true,
    "read_org": false,
    "admin_org": false,
    "read_user": false,
    "write_org": false,
    "delete_repo": false,
    "public_repo": false,
    "repo_status": false,
    "notifications": false,
    "read_repo_hook": false,
    "admin_repo_hook": false,
    "read_public_key": false,
    "repo_deployment": false,
    "write_repo_hook": false,
    "admin_public_key": false,
    "write_public_key": false
  },
  "strategy": "github",
  "name": "github",
  "enabled_clients": [
    "$SITE_CLIENT_ID"
  ]
}
EOF

export ACTION_ID=$(auth0 actions create \
  --name on-login \
  --trigger post-login \
  --code "$(cat on-login.js)" \
  --dependency "auth0=latest" \
  --secret "domain=$AUTH0_DOMAIN" \
  --secret "admin=$SITE_ADMIN" \
  --secret "clientId=$AUTH0_CLIENT_ID" \
  --secret "clientSecret=$AUTH0_CLIENT_SECRET" \
  --json | jq -r '.id')
sleep 3
auth0 actions deploy $ACTION_ID

auth0 api patch actions/triggers/post-login/bindings --data '{"bindings": [{"display_name": "on-login", "ref": {"type": "action_name", "value": "on-login"}}]}'

export GRANT_ID=$(auth0 api client-grants | jq -r '.[].id')
auth0 api patch client-grants/$GRANT_ID --data '{"scope": ["read:user_idp_tokens", "read:users"]}'

mkdir -p /tmp
cp -r ../../public /tmp/public
export SETTINGS="{domain: \"$AUTH0_DOMAIN\", clientId: \"$SITE_CLIENT_ID\"};"
sed -i "s|{}; //<<|$SETTINGS|" /tmp/public/auth/index.html

cd ../..
git fetch origin public
git checkout public --
find . -not -path './.git*' -not -name '.' -exec rm -rf {} +
tar -C /tmp/public -cf - . | tar -xvf -
echo $SITE_DOMAIN > CNAME
git add .
git config --global user.name 'Robot'
git config --global user.email 'robot@users.noreply.github.com'
git commit -m "initial setup"
git push origin public

