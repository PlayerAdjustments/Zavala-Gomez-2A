#Fernando Zavala
choice=-1
matricula=""
name=""
descripcion=""
created_date=""
user=""
palabra=""

urlGet="https://tierra-nativa-api.eium.com.mx/api/examen-U3/get-products-2A/{matricula}"
urlPost="https://tierra-nativa-api.eium.com.mx/api/examen-U3/create-product-2A"

printf "Por-favor introduzca una de las siguientes opciones\n 1. Subir un producto \n 2. Obtener un producto. \n Eleccion: "
read choice

until [ "$choice" = "1" ] || [ "$choice" = "2" ]
do
	printf "Por-favor introduzca una de las siguientes opciones\n 1. Subir un producto \n 2. Obtener un producto. \n Eleccion: "
	read choice
done

if [ "$choice" = "1" ]
then
	until [ "$palabra" = "Terminado" ]
	do
		printf "Por-favor introduce los siguientes datos: \n 1. Nombre (NO es repetible): "
		read name
		printf " 2. Descripcion: "
		read descripcion
		created_date=$(date '+%Y-%m-%d')
		matricula="15221669"

		#printf '{ "name": "'"$name"'", "description": "'"$descripcion"'", "created_date": "'"$created_date"'", "user": "'"$matricula"'"}' > POST.json
		curl -X POST https://tierra-nativa-api.eium.com.mx/api/examen-U3/create-product-2A -H 'Content-Type: application/json' -d  '{ "name": "'"$name"'", "description": "'"$descripcion"'", "created_date": "'"$created_date"'", "user": "'"$matricula"'"}' > POST.json
		printf "Por-favor revisar el archivo POST.json para saber los detalles de subida"

		printf "\n\n Escriba Terminado para salir del programa \n Palabra: "
		read palabra
	done
fi

if [ "$choice" = "2" ]
then
	printf "Por-favor introduce la matricula a buscar: "
	read matricula
	
	until [ "$getChoice" = "1" ] || [ "$getChoice" = "2" ] || [ "$getChoice" = "3" ]
	do
		printf "Por-favor introduce alguna de las 3 opciones \n 1. Crear archivo JSON y comprimirlo en un tar \n 2. Imprimir los primero 3 elementos \n Eleccion: "
		read getChoice 
	done
	
	if [ "$getChoice" = "1" ]
	then
		curl https://tierra-nativa-api.eium.com.mx/api/examen-U3/get-products-2A/$matricula -H "Accept: application/json" > GET.json
		tar -czvf GET.tar.gz GET.json
		rm GET.json
		printf "Por-favor revisar el archivo GET.tar.gz para saber los detalles de su busqueda"
	fi

	if [ "$getChoice" = "2" ]
	then
		curl https://tierra-nativa-api.eium.com.mx/api/examen-U3/get-products-2A/$matricula -H "Accept: application/json" > GET.json


    		jq '.products[0] .id_product' GET.json
		jq '.products[0] .name' GET.json
		jq '.products[0] .description' GET.json

		printf "\n - Separator -"
		jq '.products[1] .id_product' GET.json
                jq '.products[1] .name' GET.json
                jq '.products[1] .description' GET.json

                printf "\n - Separator -"
		jq '.products[2] .id_product' GET.json
                jq '.products[2] .name' GET.json
                jq '.products[2] .description' GET.json

                printf "\n - Separator -"


	fi
fi
