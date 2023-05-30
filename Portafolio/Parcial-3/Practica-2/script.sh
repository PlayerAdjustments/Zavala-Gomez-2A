Choice=-1
Name="Default"
CompFileName="CDefault"
CompChoice=-1

until [ $Choice -eq 1 ] || [ $Choice -eq 2 ]
do
    echo -e "Seleccione una de las opciones del Menú: \n 1. Comprimir con Zip \n 2. Comprimir con Rar* \n *Opcion no probada (No me deja instalar rar :,D) "
    read Choice
done

echo -e "Introduzca lo siguiente: \n 1. Nombre de la carpeta \n 2. Nombre del archivo comprimido \n * En caso de no introducir nada, el nombre sera Default *"
read Name
read CompFileName

if [ -z "$Name" ]
then
    Name="Default"
fi

if [ -z "$CompFileName" ]
then
    CompFileName="CompDefault"
fi

mkdir $Name
touch $Name/index.html
echo "Default Content" > $Name/index.html

if [ $Choice -eq 1 ] || [ $Choice -eq 2 ]
then
    mkdir descomprimidos
    if [ $Choice -eq 1 ]
    then 
        zip -r "$CompFileName".zip "$Name"
    fi
    
    if [ $Choice -eq 2 ]
    then
        rar a "$CompFileName".rar "$Name"
    fi
fi

until [ $CompChoice -eq 1 ] || [ $CompChoice -eq 2 ]
do
    echo -e "Desea descomprimir la carpeta anterior? \n 1. Si \n 2. No"
    read CompChoice
done

if [ $CompChoice -eq 1 ] 
then
    if [ $Choice -eq 1 ]
    then 
	echo "Archivo a descomprimir: $CompFileName"
        unzip "$CompFileName".zip -d descomprimidos/
        echo "Descomprimiendo archivo en descomprimidos (zip)"
    fi
    
    if [ $Choice -eq 2 ]
    then
        rar x "$CompFileName".rar -d descomprimidos/
        echo "Descromprimiendo archivo en descomprimidos (rar)"
    fi
fi