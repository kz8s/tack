#!/bin/bash -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
for file in manifests/addons/*.tpl; do cp "$file" ${file/.tpl/}; done
sed -i.bak 's|${INTERNAL_TLD}|'"$INTERNAL_TLD|g" "$DIR/"*.yml
sed -i.bak 's|${DNS_SERVICE_IP}|'"${DNS_SERVICE_IP}|g" "$DIR/"*.yml