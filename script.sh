#!/bin/sh
ls /
pwd
ls /rancher/
/bin/rancher-compose \
 --url http://${PLUGIN_URL}/v1 \
 --access-key ${PLUGIN_ACCESSKEY} \
 --secret-key ${PLUGIN_SECRETKEY} \
 -f /rancher/${PLUGIN_PATH}/docker-compose.yml -r /rancher/${PLUGIN_PATH}/rancher-compose.yml \
 --verbose -p ${PLUGIN_STACK} up -p -d --force-upgrade --confirm-upgrade
