#!/bin/bash

#Puesto en CRON cada 5 min
#head -NoLinea Archivo | tail -1 >> donde copiar la linea al final del archivo.
#head -214 ordinario.sh | tail -1 >> automatizacion.sh


INFO="\033[1;94m [INFO] \033[0;94m"
BACKUP="\033[1;93m [BACKUP] \033[0;93m"
CONFIRMATION="\033[1;92m [CONFIRMATION] \033[0;92m"
ERROR="\033[1;91m [ERROR] \033[0;91m"
DATE="\033[1;96m [$(date +'%Y-%m-%d %T')]"
NC="\033[0m"
MATRICULA="\033[1;95m [MATRICULA] \033[0:95m"


CURRENTDATE=$(date +'%Y-%m-%d_%H-%M')

DEFAULTUSER="luis@gmail.com"
DEFAULTPASSWORD="1234"

QUACK="home/player/Zavala-Gomez-2A"

echo "$QUACK/tmp-logs.txt"

if [ ! -f "$QUACK/tmp-logs.txt" ]
then
	touch "$QUACK/tmp-logs.txt"
	printf " «··············» “LOGS” «··············»" >> "$QUACK/tmp-logs.txt"
fi

if [ -d "$QUACK/LOGS-CRON" ]
then
	printf "\n $DATE $NC Carpeta 'LOGS-CRON' detectada.\n" >> "$QUACK/tmp-logs.txt"
else
	printf "\n $DATE $NC Carpeta 'LOGS-CRON' no detectada. Carpeta creada.\n" >> "$QUACK/tmp-logs.txt"
	mkdir "$QUACK/LOGS-CRON"
fi

if [ -f "$QUACK/LOGS-CRON/logs.txt" ]
then
	printf "\n $DATE $NC Archivo 'logs.txt' detectado.\n" >> "$QUACK/tmp-logs.txt"
else
	printf "\n $DATE $NC Archivo 'logs.txt' no detectado. Archivo creado.\n" >> "$QUACK/tmp-logs.txt"
	touch "$QUACK/LOGS-CRON/logs.txt"
fi

#Sacamos la primera linea del archivo.txt para saber si esta vacia.
line="$(head -n 1 $QUACK/LOGS-CRON/logs.txt)"
if [ -z "$line" ]
then
	cat "$QUACK/tmp-logs.txt" >> "$QUACK/LOGS-CRON/logs.txt"
	rm "$QUACK/tmp-logs.txt"
else
	rm "$QUACK/tmp-logs.txt"
fi


if [ ! -d "$QUACK/CRONS" ]
then
	printf "\n $DATE $NC Carpeta 'CRONS' no detectada. Carpeta creada \n" >> "$QUACK/LOGS-CRON/logs.txt"
	mkdir "$QUACK/CRONS"
fi

AllowedProductUsers=("54219247" "15221673" "15221403" "15222160" "14197923" "15222623" "15221666" "15222605" "13160606" "15222385" "15221710" "15222733" "15222136" "15209883" "15222137" "15222207" "15222734" "15222100" "15221672" "15221310" "15221428" "15222607" "13160815" "15221664" "15221661" "15221664" "15221661" "15222119" "15222431" "15222103" "15222431" "15222103" "15222195" "15221663" "15222101" "152211667" "15221669" "15198855")


curl -X POST https://tierra-nativa-api.eium.com.mx/api/ordinario-so/logIn -H 'Content-Type:application/json' -d '{ "user":"'"$DEFAULTUSER"'", "password": "'"$DEFAULTPASSWORD"'" }' > "$QUACK/LOGS-CRON/cronLOGIN.json"
userTkn=$(jq -r ".token" $QUACK/LOGS-CRON/cronLOGIN.json)
curlResult=$(jq -r ".status" $QUACK/LOGS-CRON/cronLOGIN.json)

if [ "$curlResult" = "success" ]
then
	printf "\n $DATE $NC Loggeado como $DEFAULTUSER exitosamente. \n" >> "$QUACK/LOGS-CRON/logs.txt"
	printf "\n $DATE $NC Token: $userTkn \n" >> "$QUACK/LOGS-CRON/logs.txt"
else
	printf "\n $DATE $ERROR Something happended. Check 'cronLOGIN.json' in 'CRON-LOGS' for details. $NC \n" >> "$QUACK/LOGS-CRON/logs.txt"
	exit
fi

if [ ! -f "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt" ]
then
	printf "\n $DATE $NC Archivo 'mis-archivos-$CURRENTDATE' no detectado en carpeta 'CRONS' archivo-creado \n" >> "$QUACK/LOGS-CRON/logs.txt"
	touch "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt"
	printf " «············»“ Productos - $CURRENTDATE ”«············»\n" >> "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt"
fi

for matricula in "${AllowedProductUsers[@]}"
do
	printf "\n «············» $MATRICULA $matricula «············» \n" >> "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt"

	curl https://tierra-nativa-api.eium.com.mx/api/ordinario-so/get-products/$matricula -H "Accept: application/json" -H "Authorization: Bearer $userTkn" > "$QUACK/LOGS-CRON/CurrentProducts.json"

	curlResultGET=$(jq -r ".status" "$QUACK/LOGS-CRON/CurrentProducts.json")

	if [ "$curlResultGET" = "success" ]
	then
		printf "\n $DATE $NC Productos de $MATRICULA $matricula $NC agregados a 'mis-archivos-$CURRENTDATE' en carpeta 'CRONS'. \n" >> "$QUACK/LOGS-CRON/logs.txt"

		cat "$QUACK/LOGS-CRON/CurrentProducts.json" > "$QUACK/SucessProducts.json"

		jq ".products" "$QUACK/SucessProducts.json" > "$QUACK/tmp-product.json"

		productsLength=$(jq length "$QUACK/tmp-product.json")
		productsLength=$((productsLength - 1))
		START=0
		i=$START

		until [ "$i" -gt "$productsLength" ]
		do
			printf "\n $i = $productsLength\n"
			currentProductID=$(jq -r ".products[$i] .id_product" "$QUACK/SucessProducts.json")
			currentProductName=$(jq -r ".products[$i] .name" "$QUACK/SucessProducts.json")
			currentProductDescription=$(jq -r ".products[$i] .description" "$QUACK/SucessProducts.json")
			currentProductCreatedDate=$(jq -r ".products[$i] .created_date" "$QUACK/SucessProducts.json")
			currentProductUser=$(jq -r ".products[$i] .user" "$QUACK/SucessProducts.json")
			currentProductPrice=$(jq -r ".products[$i] .price" "$QUACK/SucessProducts.json")
			printf "\n $BACKUP $currentProductName $NC \n"
			printf "\n «~~~~~»“ $currentProductName ”«~~~~~» \n" >> "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt"
			printf "\n id: $currentProductID\n name: $currentProductName\n description: $currentProductDescription \n created_date: $currentProductCreatedDate \n user: $currentProductUser \n price: $currentProductPrice \n " >> "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt"
			printf "\n «~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~» \n" >> "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt"

			((i++))
		done

	else
		printf "\n $DATE $NC Usuario $MATRICULA $matricula $NC no posee productos.\n" >> "$QUACK/LOGS-CRON/logs.txt"
		cat $QUACK/LOGS-CRON/CurrentProducts.json > "$QUACK/FailedProducts.json"

		printf "\n $ERROR $NC No posee productos \n" >> "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt"
	fi

done

printf "\n «············» «·····················» «············» \n" >> "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt"

if [ -f "$QUACK/SucessProducts.json" ]
then
	rm "$QUACK/SucessProducts.json"
	printf "\n $DATE $NC 'SucessProducts.json' eliminado correctamente. \n" >> "$QUACK/LOGS-CRON/logs.txt"
fi

if [ -f "$QUACK/FailedProducts.json" ]
then
	rm "$QUACK/FailedProducts.json"
	printf "\n $DATE $NC 'FailedProducts.json' eliminado correctamente. \n" >> "$QUACK/LOGS-CRON/logs.txt"
fi

if [ -f "$QUACK/tmp-product.json" ]
then
	rm "$QUACK/tmp-product.json"
	printf "\n $DATE $NC 'tmp-product.json' eliminado correctamente. \n" >> "$QUACK/LOGS-CRON/logs.txt"
fi

if [ -f "$QUACK/LOGS-CRON/CurrentProducts.json" ]
then
	rm "$QUACK/LOGS-CRON/CurrentProducts.json"
	printf "\n $DATE $NC 'CurrentProducts.json' eliminado de 'LOGS-CRON' correctamente. \n" >> "$QUACK/LOGS-CRON/logs.txt"
fi
