#!/bin/bash
if ! [ "x$2" != "x" ]; then
    echo "Uso: $0 <caminho do pendrive> <itens> ..."
    exit 1
fi
fs="$1"
shift
freespc=$((`stat -f -c '%a*%S' "$fs"`))
usedspc="`du -bcL \"$@\" | tail --lines=1 | awk '{ print $1; }'`"
echo ' **** Espaco disponivel: ****'
resp=$((freespc-usedspc))
echo $resp bytes
resp=$((resp/1024))
echo $resp KB
resp=$((resp/1024))
echo $resp MB
resp=$((resp/1024))
echo $resp GB
