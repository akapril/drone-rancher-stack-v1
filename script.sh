#!/bin/sh
RANCHER_COMPOSE=`find / -name rancher-compose.yml`
DOCKER_COMPOSE=`find / -name docker-compose.yml`
if [[ -n $PLUGIN_ACCESSKEY ]]; then
    ACCESSKEY="$PLUGIN_ACCESSKEY"
fi

if [[ -n $PLUGIN_SECRETKEY ]]; then
    SECRETKEY="$PLUGIN_SECRETKEY"
fi

echo "rancher-compose.yml @ ${RANCHER_COMPOSE}" 
cat ${RANCHER_COMPOSE}
echo ""
echo "docker-compose.yml @ ${DOCKER_COMPOSE}"
cat ${DOCKER_COMPOSE}
echo "/bin/rancher --url ${PLUGIN_URL} --access-key ${ACCESSKEY} --secret-key ${SECRETKEY} stacks ls > /status"
/bin/rancher --url ${PLUGIN_URL} --access-key ${ACCESSKEY} --secret-key ${SECRETKEY} stacks ls > /status

if grep -q degraded /status; then
    echo 'Stack is degraded. Deleting stack now!'
    sed -i '/degraded/!d' /status
    ID=`sed -e 's/\s.*$//' /status`
    echo "/bin/rancher --url ${PLUGIN_URL} --access-key ${ACCESSKEY} --secret-key ${SECRETKEY} rm $ID"
    /bin/rancher --url ${PLUGIN_URL} --access-key ${ACCESSKEY} --secret-key ${SECRETKEY} rm $ID
    echo 'Sleeping for 60 seconds whilst Rancher deletes the stack.'
    sleep 60s
    echo 'Rebuilding new stack'
    echo "/bin/rancher --url ${PLUGIN_URL} --access-key ${ACCESSKEY} --secret-key ${SECRETKEY} up --stack ${PLUGIN_STACK} -d -f ${DOCKER_COMPOSE} --rancher-file ${RANCHER_COMPOSE} --pull --force-recreate --confirm-upgrade"
    /bin/rancher --url ${PLUGIN_URL} --access-key ${ACCESSKEY} --secret-key ${SECRETKEY} up --stack ${PLUGIN_STACK} -d -f ${DOCKER_COMPOSE} --rancher-file ${RANCHER_COMPOSE} --pull --force-recreate --confirm-upgrade
else
    echo 'Stack healthy or not found. Creating/Updating stack with force upgrade'
    echo "/bin/rancher --url ${PLUGIN_URL} --access-key ${ACCESSKEY} --secret-key ${SECRETKEY} up --stack ${PLUGIN_STACK} -d -f ${DOCKER_COMPOSE} --rancher-file ${RANCHER_COMPOSE} --pull --force-recreate --confirm-upgrade"
    /bin/rancher --url ${PLUGIN_URL} --access-key ${ACCESSKEY} --secret-key ${SECRETKEY} up --stack ${PLUGIN_STACK} -d -f ${DOCKER_COMPOSE} --rancher-file ${RANCHER_COMPOSE} --pull --force-recreate --confirm-upgrade
fi
