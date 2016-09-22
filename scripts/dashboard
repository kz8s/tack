#!/bin/bash -u

case "${OSTYPE}" in
 linux*)
    OPEN="xdg-open"
    ;;
 darwin*)
    OPEN="open"
    ;;
esac

command -v ${OPEN} &> /dev/null
[ $? -ne 0 ] && ( echo "cannot determine 'open' command" ; exit 1 )

kubectl cluster-info &> /dev/null
[ $? -ne 0 ] && ( echo "cluster is not healthy" ; exit 1 )

kubectl proxy &
echo "✓ kubectl proxy is listening"

${OPEN} http://localhost:8001/ui
sleep 1 && echo " "
