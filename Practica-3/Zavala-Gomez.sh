!/bin/bash

Choice=-1
url="Default"
word="Default"

userId=-1
id=-1
title="Default"
body="Default"

until [ "$Choice" = "1" ] || [ "$Choice" = "2" ] || [ "$Choice" = "3" ]
do
        printf "Seleccione entre las siguientes opciones \n 1. Guardar HTML como palabra \n 2. Consultar informacion de una API \n 3. Postear>
        read Choice
done

if [ "$Choice" = "1" ]
then

        until [ "$url" = "NO" ] || [ "$word" = "NO" ]
        do
                url="Default"
                word="Default"

                while [ "$url" =  "Default" ] || [ -z "$url" ]
                do
                        printf "Introduzca una URL: "
                        read url
                done

                while [ "$word" = "Default" ] || [ -z "$word" ]
                do
                        printf "Introduzca el nombre bajo el que se guardara el archivo: "
                        read word
                done

                if [ "$url" = "NO" ] || [ "$word" = "NO" ]
                then
                        break
                fi

                curl -L $url > $word.html
                printf "Archivo $word.tar.gz guardado con exito"

        done
fi

if [ "$Choice" = "2" ]
then
        curl  https://jsonplaceholder.typicode.com/posts -H "Accept: application/json" > posts.json
        printf "POST Guardado en post.json correctamente"
fi

if [ "$Choice" = "3" ]
then
        printf "Introduzca lo siguiente:"
        printf "\n userID: "
        read userId
        printf "\n ID: "
        read id
        printf "\n Title: "
        read title
        printf "\n Body: "
        read body

        curl -X POST https://jsonplaceholder.typicode.com/posts -H 'Content-Type: application/json' -d '{ "userId": "'"$userID"'", "id": "'"$id"'", "title": "'"$title"'", "body": "'"$body"'"}' > $title.json 
fi
