#!/bin/zsh

BLACK='\033[0;30m'
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

file_path=/home/blaze/Scripts/Curso-De-Bash/pwd.txt

lines=$(wc -l $file_path | awk '{print $1}')
level=$((lines - 1))

if [ $1 = 'cat' ]; then
    batcat $file_path -l java
    exit 0
fi

ssh_connection(){
    clear
    last_level=$((lines-1))
    last_password=$(tail -n $((lines-lines-1)) $file_path | awk '{print $2}')
    
    if [[ $1 =~ ^[0-9]+$ ]]; then
        last_level=$(($1))
        last_password=$(awk "NR==$(($1+1))" $file_path | awk '{print $2}')
    fi
    
    if [ $1 = "next" ]; then
        last_level=$((lines))
    fi
    
    
    echo -e  "${GREEN}-----------------------------------------------${NC}"
    toilet "BLAZE"
    echo -ne "${NC}"
    echo -e "${GREEN}-----------------------------------------------${NC}"
    
    echo -e "\n[*] PASSWORD IN LEVEL $last_level:${GREEN} $last_password${NC}"
    echo -e "${BLUE}[*] MAKING CONNECTION WITH SSH\n${NC}"
    echo -e  "${GREEN}-----------------------------------------------${NC}\n"
    
    # $1 => Level to connect
    execution="sshpass -p $last_password ssh bandit$last_level@bandit.labs.overthewire.org -p 2220"
    echo $execution
    bash -c $execution
}

continue_menu_ssh(){
    echo -e "${YELLOW}1)${NC} SI ${BLACK}(Hacer conexión shh) ${NC}"
    echo -e "${YELLOW}2)${NC} NO ${BLACK}(Salir) ${NC}"
    echo -ne "${GREEN}\n[*] SELECCIONAR DIGITO: ${NC}"
}

if [[ $1 = "-c" || -z $1 ]]; then
    if [[ -z $2 ]]; then
        ssh_connection null
        elif [[ $2 =~ ^[0-9]+$ ]];then
        ssh_connection $2
    else
        echo "Se debe de proporcionar un numero"
        exit 1
    fi
    exit 1
fi


if [ $1 = '-r' ]; then
    last_password=$(awk "NR==$((lines))" $file_path)
    
    sed -i "$ d" $file_path # Delete password
    echo -e "${RED}\n[*] ULTIMA CONTRASEÑA ELIMINADA: ${NC}$last_password"
    exit 0
fi


if grep $1 $file_path >/dev/null; then
    echo -e "\n${RED}-----------------La clave del nivel $lines ya existe-----------------"
    echo -e "[${GREEN}$1${RED}]\n"
    echo -ne "${}"
    sed -n "$((lines - 2)), $((lines + 2))p" $file_path
    exit 1
else
    echo -e "${GREEN}\n--------------------------------------------------------${NC}"
    toilet "Nivel $((level))"
    echo -e "${GREEN}--------------------------------------------------------${NC}\n"
    
    echo -ne "${BLUE}"
    echo -e "L$((level+1)). $1" >> $file_path;
    cat $file_path
    echo -e "${GREEN}\n[*] NIVEL COMPLETADO: ${NC}$((level))"
    echo -ne "${GREEN}[*] NEXT KEY: ${NC}$1\n"
    echo -e "${GREEN}\n--------------------------------------------------------${NC}"
    
    echo -e "\n${BLUE}[!] ¿QUIERES CONTINUAR AL NIVEL $((level + 1))?\n ${NC}"
    continue_menu_ssh
    read continue
    
    if [ "$continue" -eq 1 ];then
        clear
        ssh_connection next
    else
        echo "Thanks for using"
        exit 0
    fi
fi;

