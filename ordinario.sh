#TEAM-TierraNativa xd
#!/bin/bash

choice=-1
username="Default-"
password="Default"
passwordCheck=""
userTkn=""
curlResult=""
CURRENTDATE=""
productName=""
productDescription=""
productPrice=""
SALIR=0
totalPrice=0
INFO="\033[1;94m [INFO] \033[0;94m"
BACKUP="\033[1;93m [BACKUP] \033[0;93m"
CONFIRMATION="\033[1;92m [CONFIRMATION] \033[0;92m"
ERROR="\033[1;91m [ERROR] \033[0;91m"
NC="\033[0m"


#Agrega nombres y descripciones para seleccionarse aleatoriamente en ciertos casos.
DefaultProductsNames=("Pan-Peniche" "Rosca-Poot" "Aylin-Te" "Moka-niche" "Soft-latte" "Me-ffin" "Cappu-niche")
DefaultProductsDescriptions=("Redondo y sabroso" "Para chuparse los dedos" "Relajarse requiere de esto" "Nada que lo supere" "El mas sabroso de todos" "Unico e inigualable")
AllowedProductUsers=("54219247" "15221673" "15221403" "15222160" "14197923" "15222623" "15221666" "15222605" "13160606" "15222385" "15221710" "15222733" "15222136" "15209883" "15222137" "15222207" "15222734" "15222100" "15221672" "15221310" "15221428" "15222607" "13160815" "15221664" "15221661" "15221664" "15221661" "15222119" "15222431" "15222103" "15222431" "15222103" "15222195" "15221663" "15222101" "152211667" "15221669" "15198855")

until [ "$choice" = "1" ] || [ "$choice" = "2" ]
do
	#Aqui podriamos igual darle formato, aunque no se me ocurren ideas.
	printf "\033c" #Limpia la terminal antes de escribir de-nuevo.
	printf "\n «············»“ Choice ”«············» \n"
	printf " Desea crear un nuevo usuario? \n 1. Si, quiero crear una cuenta.  \n 2. No, ya tengo cuenta. \n Eleccion: "
	read choice
done

if [ "$choice" = "1" ]
then
	printf "\n «············»“ Crea una nueva cuenta ”«············» \n $INFO En caso de dejar vacio el username o tener espacios en este ultimo, el usuario sera 'Default y un numero random'. \n $INFO En caso de dejar vacio password, la contraseña sera 'Default'. $NC\n  Username: "
	read username
	printf "\n  Password: "
	read password

	if [[ "$username" =~ ^"@gmail.com".* ]] || [ -z "$username" ] || [[ "$username" = *" "* ]]
	then
		username="Default-$(( ( RANDOM ) + 1 ))@gmail.com"
	else
		username+="@gmail.com"
	fi

	if [ -z "$password" ]
	then
		password="Default"
	fi

	printf "\n $INFO Tu usuario es: $NC $username \n $INFO Tu contraseña es: $NC $password \n"

	if [ -d "./UsersInfo" ]
	then
		printf "\n $BACKUP Se detecto que la carpeta 'UsersInfo' ya existe. Datos de usuario guardados.$NC \n"
	else
		printf "\n $BACKUP Carpeta 'UsersInfo' no detectada. Carpeta creada. Datos de usuario guardados.$NC \n"
		mkdir UsersInfo
	fi

	if [ -f "./UsersInfo/luis@gmail.com.json" ]
	then
		printf "\n $BACKUP Archivo 'luis@gmail.com.json' detectado en 'UsersInfo.$NC \n"
	else
		printf "\n $BACKUP Archivo 'luis@gmail.com.json' no detectado en 'UsersInfo'. Archivo creado. $NC \n"
		jq -n '. + {"user": "luis@gmail.com", "password": "$2y$10$VEJlBr0VfE.oUuMGU73ecOfcnBR1XP5y.avHe/hxZIZTHkYd7thBq", "id": "2", "RealPassword": "1234"}' > UsersInfo/luis@gmail.com.json
	fi

	curl -X POST https://tierra-nativa-api.eium.com.mx/api/ordinario-so/signUp -H 'Content-Type:application/json' -d '{"user": "'"$username"'","password": "'"$password"'"}' > ./UsersInfo/$username.json
	jq '. +  {"RealPassword": "'"$password"'"} ' UsersInfo/"$username.json" > UsersInfo/"Real$username.json"
	rm UsersInfo/"$username.json"
	mv UsersInfo/"Real$username.json" UsersInfo/"$username.json"
	printf "\n $INFO Api recibio la informacion con exito, revisa el archivo $username.json dentro de UsersInfo. \n"
fi

if [ "$choice" = "2" ]
then
	until [ -f "UsersInfo/$username.json" ] && [ "$passwordCheck" = "$password" ]
	do

		printf "\033c"
		printf "\n «············»“ Log In ”«············» \n $INFO Puede revisar la informacion de los usuarios dentro de /UsersInfo. \n $INFO En caso de poner un usuario o contraseña que no existan en UsersInfo, se pedira de-nuevo la info. $NC\n  Username: "
		read username
		printf "\n  Password: "
		read password

		if [ -f "UsersInfo/$username.json" ]
		then
			printf "\n $CONFIRMATION File found. $NC \n"
			passwordCheck=$(jq -r ".RealPassword" UsersInfo/"$username.json")

			if [ "$passwordCheck" = "$password" ]
			then
				printf "\n $CONFIRMATION Matched password. $NC \n"
				sleep 5s
				#Continua el Codigo aqui (Ya se hizo los chequeos de usuario!)
				#comando >> archivo.txt para agregar (No reescribe, si no que agrega)

				if [ -d "./LogIn" ]
				then
					printf "\n $BACKUP Carpeta 'LogIn' detectada. $NC \n"
				else
					printf "\n $BACKUP Carpeta 'LogIn' no detectada. Carpeta creada. $NC \n"
					mkdir LogIn
				fi

				curl -X POST https://tierra-nativa-api.eium.com.mx/api/ordinario-so/logIn -H 'Content-Type:application/json' -d '{ "user":"'"$username"'", "password": "'"$password"'" }' > ./LogIn/Tkn-$username.json
				userTkn=$(jq -r ".token" LogIn/"Tkn-$username".json)
				curlResult=$(jq -r ".status" LogIn/"Tkn-$username".json)

				if [ "$curlResult" = "success" ]
				then
					printf "\n $CONFIRMATION Log In sucessful. Entrando como usuario $username. Entregando Token. $NC \n"
					printf "\n $INFO Token: '$userTkn' $NC \n"

					if [ -d "./Products" ]
					then
						printf "\n $BACKUP Carpeta 'Products' detectada. $NC \n"
					else
						printf "\n $BACKUP Carpeta 'Products' no detectada. Carpeta Creada. $NC \n"
						mkdir Products
					fi

					#Aqui crear productos
					until [ "$SALIR" = "1" ] || [ "$SALIR" = "SALIR" ]
					do
						#Pedir Info y crear productos
						printf "\n «············»“ New Product ”«············» \n $INFO Por-favor introduzca la siguiente informacion. En caso de dejar vacio el nombre. Se seleccionara un nombre aleatorio.\n $INFO En caso de no introducir precio. Se asignara un precio aleatorio. \n $INFO En caso de no introducir una matricula. Se asignara una matricula default (15221669).$NC \n Nombre: "
						read productName
						printf "\n Descripcion: "
						read productDescription
						printf "\n Usuario(Matricula): "
						read productUser
						printf "\n Precio: "
						read productPrice
						CURRENTDATE=$(date '+%Y-%m-%d')
						printf "\n Fecha: $CURRENTDATE"

						randomID="$(( ( RANDOM ) + 1 ))"
						if [ -z "$productName" ]
						then
							printf "\n $BACKUP Producto no tiene nombre. Escogiendo uno al azar. $NC \n"
							randomName="${DefaultProductsNames[ $RANDOM % ${#DefaultProductsNames[@]} ]}"
							productName="$randomName-$randomID"
						fi

						if [ -z "$productDescription" ]
						then
							printf "\n $BACKUP Producto no tiene descripcion. Escogiendo una al azar. $NC \n"
							randomDescription="${DefaultProductsDescriptions[ $RANDOM % ${#DefaultProductsDescriptions[@]} ]}"
							productDescription="$randomDescription-$randomID"
						fi

						if [ -z "$productUser" ] || [[ ! " ${AllowedProductUsers[*]} " =~ " ${productUser} " ]]
						then
							printf "\n $BACKUP Usuario no esta permtido. Asignado default. $NC \n"
							productUser="15221669"
						fi

						if [ -z "$productPrice" ] || [[ ! $productPrice =~ ^[[:digit:]]+$ ]] || [ ! "$productPrice" -gt "0" ]
						then
							printf "\n $BACKUP Producto tiene un precio no valido. Asignado uno aleatorio.$NC \n"
							productPrice=$randomID
						fi

						jq -n '. + {"name":"'"$productName"'", "description": "'"$productDescription"'", "created_date": "'"$CURRENTDATE"'", "user": "'"$productUser"'", "price": ("'"$productPrice"'"|tonumber)}' > Products/"$productName.json"
						jq . Products/"$productName.json"
						#Aqui iria el curl para agregar el producto.

						curl -X POST https://tierra-nativa-api.eium.com.mx/api/ordinario-so/create-product -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $userTkn" -d @Products/"$productName.json" > ./Products/"TN-$productName.json"

						curlResult=$(jq -r ".status" Products/"TN-$productName.json")

						if [ "$curlResult" = "success" ]
		                                then

							if [ -d "./Venta-Productos" ]
							then
								printf "\n $BACKUP Carpeta 'Venta-Productos detectada.$NC \n"
							else
								printf "\n $BACKUP Carpeta 'Venta-Productos no detectada. Carpeta creada.$NC \n"
								mkdir Venta-Productos
							fi

							if [ -f "./Venta-Productos/venta-productos-$CURRENTDATE.txt" ]
							then
								printf "\n $BACKUP Archivo 'venta-productos-$CURRENTDATE' detectado en carpeta 'Venta-Productos'.$NC \n"
							else
								printf "\n $BACKUP Archivo 'venta-productos-$CURRENTDATE.txt' no detectado. Creado archivo en carpeta 'Venta-Productos'.$NC \n"
								touch ./Venta-Productos/"venta-productos-$CURRENTDATE".txt
								printf " «············»“ Productos - $CURRENTDATE ”«············»\n" >> Venta-Productos/"venta-productos-$CURRENTDATE".txt 
							fi


							printf "\n $CONFIRMATION Producto creado con exito.$NC \n $INFO Imprimiendo producto. $NC \n"
							jq . Products/"TN-$productName".json

							currentProductName=$(jq -r ".data .name" Products/"TN-$productName".json)
							currentProductDescription=$(jq -r ".data .description" Products/"TN-$productName".json)
							currentProductCreatedDate=$(jq -r ".data .created_date" Products/"TN-$productName".json)
							currentProductUser=$(jq -r ".data .user" Products/"TN-$productName".json)
							currentProductPrice=$(jq -r ".data .price" Products/"TN-$productName".json)
							currentProductID=$(jq -r ".data .id_product" Products/"TN-$productName".json)

							totalPrice=$(($totalPrice+$currentProductPrice))

							printf "\n «~~~~~»“$currentProductName”«~~~~~» \n" >> Venta-Productos/"venta-productos-$CURRENTDATE".txt
							printf "\n name: $currentProductName\n description: $currentProductDescription \n created_date: $currentProductCreatedDate \n user: $currentProductUser \n price: $currentProductPrice \n id: $currentProductID"  >> Venta-Productos/"venta-productos-$CURRENTDATE".txt
							printf "\n «~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~» \n" >> Venta-Productos/"venta-productos-$CURRENTDATE".txt

							printf "\n $BACKUP Producto guardado en 'Products/venta-productos-$CURRENTDATE' correctamente.$NC \n"

							printf "\n $INFO Desea dejar de crear productos (Escriba SALIR o ingrese 1). $NC \n SALIR: "
							read SALIR
						else
							printf "\n $ERROR Something happened. Revise el archivo 'TN-$productName.json' dentro de la carpeta 'Products' para saber mas detalles.$NC \n"
		                                        exit
						fi
					done
					printf "\n TOTAL $ $totalPrice\n «············»“ FIN NOTA - PRODUCTOS ”«············»\n" >> Venta-Productos/"venta-productos-$CURRENTDATE".txt

					printf "\n $INFO Desea hacer una copia de su archivo de compra?$ (Escriba SI o 1 para aceptar).$NC \n Eleccion:"
					read CHOICECOMPRAS

					if [ "$CHOICECOMPRAS" = "1" ] || [ "$CHOICECOMPRAS" = "SI" ]
					then
						if [ -d "./Compras" ]
						then
							printf "\n $BACKUP Carpeta 'Compras' detectada.$NC \n"
						else
							printf "\n $BACKUP Carpeta 'Compras' no detectada. Carpeta creada.$NC \n"
							mkdir Compras
						fi

						cp Venta-Productos/"venta-productos-$CURRENTDATE".txt Compras
						printf "\n $BACKUP Archivo venta-productos-$CURRENTDATE.txt copiado correctamente en 'Compras'.$NC \n"
					fi
				else
					printf "\n $ERROR Something happened. Revise el archivo 'Tkn-$username.json' dentro de la carpeta 'LogIn' para saber mas detalles. $NC \n"
					exit
				fi
			else
				printf "\n $ERROR Password doesnt match. Try again $NC \n"
				sleep 6s
			fi
		else
			printf "\n $ERROR $username.json no encontrado en UsersInfo. Por-favor elija uno de los siguientes usuarios. $NC \n"
                        tree ./UsersInfo
			passwordCheck=$RANDOM
			sleep 15s
		fi

	done
fi
