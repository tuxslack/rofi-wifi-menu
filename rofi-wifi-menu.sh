#!/bin/bash
#
# Autor:           Eric Murphy    - https://www.youtube.com/@EricMurphyxyz    | https://github.com/ericmurphyxyz
# Colaboração:     Fernando Souza - https://www.youtube.com/@fernandosuporte/ | https://github.com/tuxslack
# Data:            23/11/2023
# Script:          rofi-wifi-menu.sh
# Versão:          0.2
# 
#
# Data da atualização:  22/01/2025 as 19:38:37
#
# Licença:  GPL - https://www.gnu.org/



# https://www.youtube.com/watch?v=v8w1i3wAKiw
# https://plus.diolinux.com.br/t/como-poder-usar-algum-script-do-rofi-em-um-so-atalho/47781/4


clear

# ----------------------------------------------------------------------------------------


# Função para verificar se um comando está instalado.

check_command() {

    command -v "$1" &>/dev/null || { echo -e "\nError: $1 is not installed. Please install it to use this script. \n"; exit 1; }

}


# Verifica se os programas necessários estão instalados.

# Verificando dependências.

for cmd in "notify-send" "nmcli" "sed" "rofi" "dmenu" "fc-list"; do

    check_command "$cmd"

done


# ----------------------------------------------------------------------------------------

# As duas fontes deve esta instaladas no sistema.

# Função para verificar se uma das fontes (Font Awesome ou Nerd Font) está instalada.


check_font() {

# A verificação de fontes usa uma expressão regular combinando "Font Awesome" ou 
# "Nerd Fonts" em uma única chamada grep.


# Essa expressão irá procurar no fc-list as fontes "Font Awesome" ou "Nerd Fonts" e, se 
# não encontrar nenhuma delas, o comando dentro do if será executado.

    if ! fc-list | grep -iqE "Font Awesome|Nerd Fonts"; then


# O -i significa "ignorar diferenças entre maiúsculas e minúsculas" (case-insensitive).
#
# O -E significa que você está usando expressões regulares estendidas (para que você 
# possa usar operadores como |, sem a necessidade de escapá-los).
#
# O padrão "Font Awesome|Nerd Fonts" procura pela string "Font Awesome" ou "Nerd Fonts", 
# sem se importar com o caso das letras, ou seja, ele encontrará "font awesome", 
# "FONT AWESOME", "Nerd Fonts", "nerd fonts", etc.
#
# O -q significa "quiet" (silencioso). Com essa opção, o grep não exibe a saída do 
# comando, ele simplesmente retorna um código de saída (0 se encontrou o padrão, 1 se 
# não encontrou). Isso é útil quando você só se importa com a presença ou ausência do 
# padrão, mas não precisa da saída do grep.


        echo "Error: Neither 'Font Awesome' nor 'Nerd Fonts' is installed."
        echo "Please install one of them to use this script."
        echo
        echo "Font Awesome: You can install the Font Awesome package from your system's repositories or download it directly from the official website:"
        echo "  https://fontawesome.com/"
        echo
        echo "Nerd Fonts: Nerd Fonts can be installed directly from the official website, or you can use available packages from your Linux distribution's repositories:"
        echo "font3270:  https://www.nerdfonts.com/"

        exit 1

    fi
}




# Verifica se as fontes Font Awesome ou Nerd Fonts estão instaladas.

# Função check_font

check_font



# ----------------------------------------------------------------------------------------


# Verificar se o Wi-Fi está habilitado ou desabilitado.

# Definir a mensagem de toggle conforme o estado do Wi-Fi.


wifi_status=$(nmcli radio wifi)

if   [[ "$wifi_status" =~ "enabled" || "$wifi_status" =~ "habilitado" ]]; then

	    toggle="󰖪  Disable Wi-Fi"


# ----------------------------------------------------------------------------------------


# Exibe uma notificação informando que a busca de redes Wi-Fi está em andamento.

notify-send "Getting list of available Wi-Fi networks..."


# Aguarda 1 segundo para exibir a notificação

sleep 1


# Obtém a lista de redes Wi-Fi disponíveis e a formata com ícones.

# Get a list of available wifi connections and morph it into a nice-looking list

wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d")


# ----------------------------------------------------------------------------------------


elif [[ "$wifi_status" =~ "disabled" || "$wifi_status" =~ "desabilitado" ]]; then

	    toggle="󰖩  Enable Wi-Fi"


fi


# ----------------------------------------------------------------------------------------


# Escolher rede

# Usa o rofi para selecionar a rede Wi-Fi ou a opção de alternar o Wi-Fi.

# Use rofi to select wifi network

chosen_network=$(echo -e "$toggle\n$wifi_list" | uniq -u | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: ")


# ----------------------------------------------------------------------------------------

# Verifica se a escolha foi cancelada.

# Se não houver escolha, sair.


if [ -z "$chosen_network" ]; then

    exit

fi

# ----------------------------------------------------------------------------------------


# Get name of connection

# read -r chosen_id <<< "${chosen_network:3}"


# Extrai o nome da rede selecionada.

chosen_id="${chosen_network:3}"



# Lógica para alternar o estado do Wi-Fi.

# Lidar com ativação/desativação de Wi-Fi.


if  [ "$chosen_network" = "󰖩  Enable Wi-Fi" ]; then

	nmcli radio wifi on

    notify-send "Wi-Fi Enabled" "Wi-Fi has been enabled."


elif [ "$chosen_network" = "󰖪  Disable Wi-Fi" ]; then

	nmcli radio wifi off

    notify-send "Wi-Fi Disabled" "Wi-Fi has been disabled."

else


    # Mensagem a ser mostrada quando a conexão for bem-sucedida.

	# Message to show when connection is activated successfully


  	success_message="You are now connected to the Wi-Fi network \"$chosen_id\"."



	# Get saved connections

    # Verifica se a rede já está salva.

	saved_connections=$(nmcli -g NAME connection)



    # Conectar à rede salva ou pedir senha se necessário

    if echo "$saved_connections" | grep -w -q "$chosen_id"; then

        # Conecta-se à rede salva.

        nmcli connection up id "$chosen_id" | grep "successfully" && notify-send "Connection Established" "$success_message"
    else

        # Se for uma rede protegida, pede a senha.

        if [[ "$chosen_network" =~ "" ]]; then

            wifi_password=$(rofi -dmenu -p "Password: ")

        fi

        # Conecta-se à rede Wi-Fi usando a senha fornecida.

        nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep "successfully" && notify-send "Connection Established" "$success_message"
    fi


fi

exit 0
