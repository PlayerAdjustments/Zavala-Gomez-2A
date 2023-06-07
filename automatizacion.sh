#!/bin/bash

#Puesto en CRON cada 5 min
#head -NoLinea Archivo | tail -1 >> donde copiar la linea al final del archivo.
#head -214 ordinario.sh | tail -1 >> automatizacion.sh

#Definir cabecillas de información
INFO="\033[1;94m [INFO] \033[0;94m"
BACKUP="\033[1;93m [BACKUP] \033[0;93m"
CONFIRMATION="\033[1;92m [CONFIRMATION] \033[0;92m"
ERROR="\033[1;91m [ERROR] \033[0;91m"
DATE="\033[1;96m [$(date +'%Y-%m-%d %T')]"
NC="\033[0m"
MATRICULA="\033[1;95m [MATRICULA] \033[0:95m"

#Definir la fecha en formato anio-mes-dia-hora-minutos
CURRENTDATE=$(date +'%Y-%m-%d_%H-%M')

#Definir al usuario y contraseña  
DEFAULTUSER="luis@gmail.com"
DEFAULTPASSWORD="1234"

#Directorio del archivo
QUACK="/home/rafa24/Zavala-Gomez-2A"

#Se imprime el path
echo "$QUACK/tmp-logs.txt"

#Si no existe el archivo, se crea
if [ ! -f "$QUACK/tmp-logs.txt" ]
then
	touch "$QUACK/tmp-logs.txt"
	printf " «··············» “LOGS” «··············»" >> "$QUACK/tmp-logs.txt"
fi

#Si no existe la carpeta, se entrega
if [ -d "$QUACK/LOGS-CRON" ]
then
	printf "\n $DATE $NC Carpeta 'LOGS-CRON' detectada.\n" >> "$QUACK/tmp-logs.txt"
else
	printf "\n $DATE $NC Carpeta 'LOGS-CRON' no detectada. Carpeta creada.\n" >> "$QUACK/tmp-logs.txt"
	mkdir "$QUACK/LOGS-CRON"
fi

#Si el archivo dentro de la carpeta no existe, se crea
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

#Si no existe la carpeta de crons, se crea
if [ ! -d "$QUACK/CRONS" ]
then
	printf "\n $DATE $NC Carpeta 'CRONS' no detectada. Carpeta creada \n" >> "$QUACK/LOGS-CRON/logs.txt"
	mkdir "$QUACK/CRONS"
fi

#Definir las matriculas de usuarios permitidos
AllowedProductUsers=("54219247" "15221673" "15221403" "15222160" "14197923" "15222623" "15221666" "15222605" "13160606" "15222385" "15221710" "15222733" "15222136" "15209883" "15222137" "15222207" "15222734" "15222100" "15221672" "15221310" "15221428" "15222607" "13160815" "15221664" "15221661" "15221664" "15221661" "15222119" "15222431" "15222103" "15222431" "15222103" "15222195" "15221663" "15222101" "152211667" "15221669" "15198855")

#Realizar la solicitud a la API con la informacion default de inicio de sesion
curl -X POST https://tierra-nativa-api.eium.com.mx/api/ordinario-so/logIn -H 'Content-Type:application/json' -d '{ "user":"'"$DEFAULTUSER"'", "password": "'"$DEFAULTPASSWORD"'" }' > "$QUACK/LOGS-CRON/cronLOGIN.json"

#Extraer el token de acceso
userTkn=$(jq -r ".token" $QUACK/LOGS-CRON/cronLOGIN.json)

#Verificar el resultado de la solicitud
curlResult=$(jq -r ".status" $QUACK/LOGS-CRON/cronLOGIN.json)

#Si el resultado de la solicitud es exitoso se guarda la informacion en el archivo de logs
if [ "$curlResult" = "success" ]
then
	printf "\n $DATE $NC Loggeado como $DEFAULTUSER exitosamente. \n" >> "$QUACK/LOGS-CRON/logs.txt"
	printf "\n $DATE $NC Token: $userTkn \n" >> "$QUACK/LOGS-CRON/logs.txt"
else
	printf "\n $DATE $ERROR Something happended. Check 'cronLOGIN.json' in 'CRON-LOGS' for details. $NC \n" >> "$QUACK/LOGS-CRON/logs.txt"
	exit
fi

#Si el archivo con la fecha y hora no existe, se crea
if [ ! -f "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt" ]
then
	printf "\n $DATE $NC Archivo 'mis-archivos-$CURRENTDATE' no detectado en carpeta 'CRONS' archivo-creado \n" >> "$QUACK/LOGS-CRON/logs.txt"
	touch "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt"
	printf " «············»“ Productos - $CURRENTDATE ”«············»\n" >> "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt"
fi

#Iteramos cada matricula en el array de las matriculas permitidas
for matricula in "${AllowedProductUsers[@]}"
do
	printf "\n «············» $MATRICULA $matricula «············» \n" >> "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt"

#Sacamos los productos correspondientes a cada matricula y lo guardamos en el json de productos
	curl https://tierra-nativa-api.eium.com.mx/api/ordinario-so/get-products/$matricula -H "Accept: application/json" -H "Authorization: Bearer $userTkn" > "$QUACK/LOGS-CRON/CurrentProducts.json"

#Confirmación del status 
	curlResultGET=$(jq -r ".status" "$QUACK/LOGS-CRON/CurrentProducts.json")

#Si la respuesta fue exitosa entonces se imprime la informacion 
	if [ "$curlResultGET" = "success" ]
	then
		printf "\n $DATE $NC Productos de $MATRICULA $matricula $NC agregados a 'mis-archivos-$CURRENTDATE' en carpeta 'CRONS'. \n" >> "$QUACK/LOGS-CRON/logs.txt"

		cat "$QUACK/LOGS-CRON/CurrentProducts.json" > "$QUACK/SucessProducts.json"

#Extraemos los productos del json para guardarlo en un un archivo temporal
		jq ".products" "$QUACK/SucessProducts.json" > "$QUACK/tmp-product.json"

#Sacar la longitud de cuantos productos hay (productos en el arreglo)
		productsLength=$(jq length "$QUACK/tmp-product.json")
		productsLength=$((productsLength - 1))
		START=0
		i=$START

#Hasta que el iterador sea mayor a la longitud de productos (productos en el arreglo)
		until [ "$i" -gt "$productsLength" ]
		do

#Imprimir el producto actual
			printf "\n $i = $productsLength\n"

#Imprimir todas las propiedades del producto
			currentProductID=$(jq -r ".products[$i] .id_product" "$QUACK/SucessProducts.json")
			currentProductName=$(jq -r ".products[$i] .name" "$QUACK/SucessProducts.json")
			currentProductDescription=$(jq -r ".products[$i] .description" "$QUACK/SucessProducts.json")
			currentProductCreatedDate=$(jq -r ".products[$i] .created_date" "$QUACK/SucessProducts.json")
			currentProductUser=$(jq -r ".products[$i] .user" "$QUACK/SucessProducts.json")
			currentProductPrice=$(jq -r ".products[$i] .price" "$QUACK/SucessProducts.json")
			printf "\n $BACKUP $currentProductName $NC \n"
			printf "\n «~~~~~»“$currentProductName”«~~~~~» \n" >> "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt"
			printf "\n id: $currentProductID\n name: $currentProductName\n description: $currentProductDescription \n created_date: $currentProductCreatedDate \n user: $currentProductUser \n price: $currentProductPrice \n " >> "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt"
			printf "\n «~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~» \n" >> "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt"

			((i++))
		done

#Si el usuario no tiene productos se guarda en un json de productos fallidos
	else
		printf "\n $DATE $NC Usuario $MATRICULA $matricula $NC no posee productos.\n" >> "$QUACK/LOGS-CRON/logs.txt"
		cat $QUACK/LOGS-CRON/CurrentProducts.json > "$QUACK/FailedProducts.json"

		printf "\n $ERROR $NC No posee productos \n" >> "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt"
	fi

done

printf "\n «············» «·····················» «············» \n" >> "$QUACK/CRONS/mis-archivos-$CURRENTDATE.txt"

#Si el json de productos existe, se borra
if [ -f "$QUACK/SucessProducts.json" ]
then
	rm "$QUACK/SucessProducts.json"
	printf "\n $DATE $NC 'SucessProducts.json' eliminado correctamente. \n" >> "$QUACK/LOGS-CRON/logs.txt"
fi

#Si el json de productos fallidos (usuarios sin productos), se borra
if [ -f "$QUACK/FailedProducts.json" ]
then
	rm "$QUACK/FailedProducts.json"
	printf "\n $DATE $NC 'FailedProducts.json' eliminado correctamente. \n" >> "$QUACK/LOGS-CRON/logs.txt"
fi

#Si el archivo temporal de producto existe, se borra
if [ -f "$QUACK/tmp-product.json" ]
then
	rm "$QUACK/tmp-product.json"
	printf "\n $DATE $NC 'tmp-product.json' eliminado correctamente. \n" >> "$QUACK/LOGS-CRON/logs.txt"
fi

#Si el archivo de currentproducts existe, se borra
if [ -f "$QUACK/LOGS-CRON/CurrentProducts.json" ]
then
	rm "$QUACK/LOGS-CRON/CurrentProducts.json"
	printf "\n $DATE $NC 'CurrentProducts.json' eliminado de 'LOGS-CRON' correctamente. \n" >> "$QUACK/LOGS-CRON/logs.txt"
fi
