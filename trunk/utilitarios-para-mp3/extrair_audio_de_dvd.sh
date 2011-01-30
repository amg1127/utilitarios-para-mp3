#!/bin/bash

prefixo="faixa_"

ajusteganho () {
    mp3gain -r -s r -c "$1" && mp3gain -g 6 "$1"
}

echo -e "\n****    Programa para a extracao de musicas de um DVD    ****"
if [ "$1" ]; then
    dispositivo="$1"
else
    echo "Erro: especifique o caminho do arquivo ou dispositivo onde esta o DVD que se deseja extrair!"
    exit 1
fi

lsdvd -x "$dispositivo"

echo -n "Qual o numero do titulo do DVD? "
read titulo

echo -n "Qual o numero do capitulo inicial para extrair? "
read capi

echo -n "Qual o numero do capitulo final para extrair? "
read capf

echo -ne "\n"

for i in `seq $capi $capf`; do
    o=$((i+1-$capi))
    arq="${prefixo}`echo -n 000$o | tail -c2`"
    while true; do
        echo "Codificando capitulo ${o} para '$arq.mp3'..."
        if false; then
            transcode -x dvd,dvd -y null,lame -o "$arq" -i "$dispositivo" -b 256 -T $titulo,$i && ajusteganho "$arq.mp3"
        else
            ( mplayer -vc dummy -vo null -af resample=44100:0:0 -af volume=0:0 -ao pcm:file="$arq.wav" -chapter $i-$i -dvd-device $dispositivo dvd://$titulo || true ) && lame -b 256 "$arq.wav" "$arq.mp3" && rm -f "$arq.wav" && ajusteganho "$arq.mp3"
        fi
        if [ $? -eq 0 ]; then
            break
        else
            echo 'Erros ocorreram durante a codificacao!'
            resp="A"
            while ! echo sSnN | grep -q $resp; do
                echo -n "Deseja tentar novamente? (S/N) "
                read resp
                resp="`echo $resp | cut -b 1-1`"
            done
            if ! echo sS | grep -q $resp; then
                rm -fv "$arq.mp3"
                echo -e "Abortando a codificacao da faixa $o...\n"
                break
            fi
        fi
    done
done

echo "Concluido."
