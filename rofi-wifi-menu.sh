#!/bin/bash
#
# Autor:           Eric Murphy    - https://www.youtube.com/@EricMurphyxyz    | https://github.com/ericmurphyxyz
# Colaboração:     Fernando Souza - https://www.youtube.com/@fernandosuporte/ | https://github.com/tuxslack
# Data:            23/11/2023
# Script:          rofi-wifi-menu.sh
# Versão:          0.2
#
# Um menu Wi-Fi escrito em bash. Usa rofi e nmcli.
#
#
# Data da atualização:  22/01/2025 as 19:38:37
#
# Licença:  GPL - https://www.gnu.org/
#
#
# Você provavelmente vai querer colocar o script no seu $PATH para poder executá-lo como 
# um comando e mapear uma combinação de teclas para ele.
#
# echo $PATH
#
# mv -i  rofi-wifi-menu.sh /usr/local/bin/
#
# chmod +x  /usr/local/bin/rofi-wifi-menu.sh


# https://www.youtube.com/watch?v=v8w1i3wAKiw
# https://plus.diolinux.com.br/t/como-poder-usar-algum-script-do-rofi-em-um-so-atalho/47781/4
# https://www.vivaolinux.com.br/dica/Erro-msgfmt-Resolvido


# FONT="DejaVu Sans Mono 8"

FONT="Monospace 12"


clear

# ----------------------------------------------------------------------------------------

# Cores para formatação da saída dos comandos

RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
NC='\e[0m' # sem cor


# ----------------------------------------------------------------------------------------

# Carregar arquivos .mo com textdomain

# Define a variável de ambiente do idioma

export LANG="$LANG"
export TEXTDOMAIN=rofi-wifi-menu
export TEXTDOMAINDIR=/usr/share/locale

# ----------------------------------------------------------------------------------------


# Obtém o idioma do sistema

idioma=$(echo "$LANG" | cut -d. -f1)  # | cut -d_ -f1  Extrai a parte do idioma antes do "_"

# Caminho do arquivo, com base na variável do idioma.

arquivo="/usr/share/locale/$idioma/LC_MESSAGES/rofi-wifi-menu.mo"


diretorio=$(dirname "$arquivo")  # Obtém o diretório onde o arquivo está localizado


# Verificar se o diretório existe

# !: O símbolo de exclamação nega a condição seguinte. Ou seja, ele inverte o resultado. 
# Se a condição -d "$diretorio" normalmente fosse verdadeira (indicando que o diretório 
# existe), a negação (!) a tornaria falsa (indicando que o diretório não existe).

if [ ! -d "$diretorio" ]; then

#    message=$(gettext 'The folder %s exists.')

#    echo -e "\n${GREEN}$(printf "$message" "$diretorio") ${NC}\n"


# else

    message=$(gettext 'The folder %s does not exist.')

    echo -e "\n${RED}$(printf "$message" "$diretorio") ${NC}\n"

    exit

fi




# Verificar se o arquivo existe

# !: O símbolo de exclamação nega a condição seguinte. Ou seja, ele inverte o resultado. 
# Se a condição -d "$diretorio" normalmente fosse verdadeira (indicando que o diretório 
# existe), a negação (!) a tornaria falsa (indicando que o diretório não existe).

if [ ! -f "$arquivo" ]; then

#    message=$(gettext 'The file %s exists.')

#    echo -e "\n${GREEN}$(printf "$message" "$arquivo") ${NC}\n"

#    ls -lh "$arquivo"


# else

    message=$(gettext 'The file %s does not exist.')

    echo -e "\n${RED}$(printf "$message" "$arquivo") ${NC}\n"

    exit

fi



# Explicação:
#
#    -d: Verifica se o diretório existe.
#    -f: Verifica se o arquivo existe.
#
# Essa parte do script verifica ambos, o diretório onde o arquivo está e o arquivo em si. 




# ----------------------------------------------------------------------------------------

# Função para verificar se um comando está instalado.

check_command() {


    message=$(gettext 'Error: %s is not installed. Please install it to use this script.')

    command -v "$1" &>/dev/null || { echo -e "\n${RED}$(printf "$message" "'$1'") ${NC}\n"; exit 1; }

}


# Verifica se os programas necessários estão instalados.

# Verificando dependências.

for cmd in "notify-send" "nmcli" "sed" "rofi" "dmenu" "fc-list" "gettext" "yad" "sudo" "sed" "grep"; do

    check_command "$cmd"

done

# ----------------------------------------------------------------------------------------


# Solução de problemas
#
# O PopOS! não tem a biblioteca notify-send instalada por padrão. Você pode instalá-la 
# com o seguinte comando (de acordo com este tópico):
#
# https://unix.stackexchange.com/questions/685247/what-is-the-notify-send-alternative-command-in-pop-os
#
#
# sudo apt update
#
# sudo apt install -y libnotify-bin


# Verifica se o arquivo /etc/os-release existe

if [ ! -f /etc/os-release ]; then

    # Exibe uma tela de erro usando yad.

    yad --center --title="$(gettext 'Error')" --text="$(gettext 'The /etc/os-release file was not found! 
This may indicate that the system is not Linux or the system structure is corrupt.')" --button="OK":0 --width="300" --height="150"

    exit 1

# else

#    echo -e "\n${GREEN}$(gettext 'The file /etc/os-release exists.') ${NC}\n"

fi


# ----------------------------------------------------------------------------------------


# O problema é que no NixOS você precisa instalar o pacote libnotify junto com o dunst.
#
# A documentação não inclui uma biblioteca que está faltando na versão do PopOS baseada 
# no Ubuntu!
#
#
# NixOS tem o arquivo /etc/os-release. Ele pode ser usado para identificar o sistema 
# operacional, mas o conteúdo dele pode ser um pouco diferente de outras distribuições, 
# porque o NixOS é uma distribuição única e independente.

if grep -q -i "nixos" /etc/os-release  ; then


# NixOS usa o Nix como seu gerenciador de pacotes e o sistema é configurado de maneira 
# declarativa. Para instalar pacotes, você deve adicionar o pacote à configuração do 
# sistema.

# Caminho para o arquivo de configuração

CONFIG_FILE="/etc/nixos/configuration.nix"

# Verificar se libnotify-bin já está na configuração

if grep -q "libnotify-bin" "$CONFIG_FILE"; then

    echo -e "\n${GREEN}$(gettext 'The libnotify-bin package is already in the configuration.') ${NC}\n"
        
else

# O NixOS utiliza um arquivo de configuração centralizado chamado configuration.nix, onde 
# você especifica todos os pacotes e configurações do sistema. Para instalar libnotify-bin, 
# você precisa modificar esse arquivo.

    # Adicionar o pacote libnotify-bin à configuração

    echo -e "\n${GREEN}$(gettext 'Adding libnotify-bin to configuration...') ${NC}\n"


    # Adicione libnotify-bin à seção environment.systemPackages:

    sed -i '/environment\.systemPackages\s*=/a \\tlibnotify-bin' "$CONFIG_FILE"
    

# Exemplo:
# 
# environment.systemPackages = with pkgs; [
#   libnotify-bin
# ];


    # Aplicar a configuração com nixos-rebuild

    # Isso vai reconstruir o sistema e instalar o pacote libnotify-bin junto com outras 
    # alterações na configuração.

    echo -e "\n${GREEN}$(gettext 'Rebuilding the system to apply the changes...') ${NC}\n"

    sudo nixos-rebuild switch
    

    # Verificar se a instalação foi bem-sucedida

    if which notify-send > /dev/null 2>&1; then

        echo -e "\n${GREEN}$(gettext 'libnotify-bin was installed successfully.') ${NC}\n"

    else

        echo -e "\n${RED}$(gettext 'There was an error installing libnotify-bin.') ${NC}\n"

    fi
fi



# else

#      echo -e "\n${RED}$(gettext 'This part of the script is intended for NixOS or derivatives of it.') ${NC}\n"

fi

# ----------------------------------------------------------------------------------------



# Verificar se o sistema é PopOS! ou um derivado do Debian

if grep -q -i "pop" /etc/os-release || grep -q -i "debian" /etc/os-release || grep -q -i "ubuntu" /etc/os-release || grep -q -i "linuxmint" /etc/os-release || grep -q -i "kali" /etc/os-release || grep -q -i "zorin" /etc/os-release || grep -q -i "elementary" /etc/os-release || grep -q -i "bodhi" /etc/os-release || grep -q -i "peppermint" /etc/os-release || grep -q -i "deepin" /etc/os-release ; then


    # Verificar se a biblioteca libnotify-bin está instalada

    if ! dpkg -l | grep -q "libnotify-bin"; then

        # Usar yad para solicitar a instalação

        yad --center --title="$(gettext 'Installation required')" --text="$(gettext 'The libnotify-bin library is not installed. Do you want to install it?')" --button="$(gettext 'Install')":0 --button="$(gettext 'Cancel')":1

        if [ $? -eq 0 ]; then

            # Instalar a biblioteca

            
            # Executa o comando sudo apt update && sudo apt install -y libnotify-bin

            sudo apt update && sudo apt install -y libnotify-bin

            # Verifica se o comando anterior teve erro

              if [ $? -ne 0 ]; then

                       echo -e "\n${RED}$(gettext 'Command failed! An error occurred while trying to install libnotify-bin.') ${NC}\n"

                  else

                       echo -e "\n${GREEN}$(gettext 'Command executed successfully. The library has been installed.') ${NC}\n"
              fi

        fi

    else

        echo -e "\n${GREEN}$(gettext 'The libnotify-bin library is already installed.') ${NC}\n"
         
    fi

# else

#    echo -e "\n${RED}$(gettext 'This part of the script is intended for PopOS! or Debian-derived systems.') ${NC}\n"

fi

    


# ----------------------------------------------------------------------------------------

# Para verificar se a pasta /usr/share/icons/Adwaita/ existe no sistema.


# A pasta /usr/share/icons/Adwaita contém os ícones do tema Adwaita, que é o tema de 
# ícones padrão do GNOME. Se essa pasta não existir, significa que o tema de ícones Adwaita 
# não está instalado corretamente no sistema, ou o diretório foi removido.
# 
# Para garantir que o tema de ícones Adwaita esteja instalado corretamente, você pode 
# verificar se ele está instalado e, caso contrário, notificar o usuário para 
# instalar os pacotes necessários.




# Caminho da pasta

DIR="/usr/share/icons/Adwaita"


# Verifica se a pasta existe

if [ ! -d "$DIR" ]; then

    # Exibe uma notificação caso a pasta não exista.
    
    # Sugestão para o usuário instalar o pacote.


        message="$(gettext "The %s folder does not exist. This means that the Adwaita theme icons are not installed. 

Suggestion: 

To fix this, install the 'adwaita-icon-theme' package to get the default icons.")"



    yad --center --title="$(gettext 'Error')" --text="$(printf "$message" "$DIR")" --button="OK":0 --width="300" --height="150"


    # Opcional: Também poderia ser feito a instalação automática se o pacote estiver ausente
    # para instalar automaticamente em sistemas baseados em Debian/Ubuntu:
    #
    # sudo apt update && sudo apt install -y adwaita-icon-theme

    exit 1

fi


   # Caso a pasta exista.

#   message="$(gettext 'The %s folder exists and the Adwaita icon theme is installed.')"

#   echo -e "\n${GREEN}$(printf "$message" "$DIR") ${NC}\n"


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


        echo -e "\n${RED}$(gettext "Error: Neither 'Font Awesome' nor 'Nerd Fonts' is installed. 

Please install one of them to use this script. 

Font Awesome: Install from your system's repositories or from the official website: https://fontawesome.com/ 

Nerd Fonts: Install from the official website or your system's repositories: font3270 - https://www.nerdfonts.com/") ${NC}\n"


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

	    toggle="󰖪  $(gettext 'Disable Wi-Fi')"


# ----------------------------------------------------------------------------------------


# Exibe uma notificação informando que a busca de redes Wi-Fi está em andamento.

notify-send -i "/usr/share/icons/Adwaita/symbolic/status/network-wireless-connected-symbolic.svg" "$(gettext 'Getting list of available Wi-Fi networks...')"


# Aguarda 1 segundo para exibir a notificação

sleep 1


# Obtém a lista de redes Wi-Fi disponíveis e a formata com ícones.

# Get a list of available wifi connections and morph it into a nice-looking list


# nmcli device wifi list


# Original

# wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d")


# wifi_list=$(nmcli --fields "SECURITY,SSID,ACTIVE" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d" | sed "s/no//" | sed "s/yes/✔/")


# SECURITY,SSID,CHAN,RATE,SIGNAL,BARS

wifi_list=$(nmcli --fields "SECURITY,SSID,BARS" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d")


# ----------------------------------------------------------------------------------------


elif [[ "$wifi_status" =~ "disabled" || "$wifi_status" =~ "desabilitado" ]]; then

	    toggle="󰖩  $(gettext 'Enable Wi-Fi')"



fi

# ----------------------------------------------------------------------------------------


# Escolher rede

# Usa o rofi para selecionar a rede Wi-Fi ou a opção de alternar o Wi-Fi.

# Use rofi to select wifi network

# chosen_network=$(echo -e "$toggle\n$wifi_list" | uniq -u | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: ")


chosen_network=$(echo -e "$toggle\n$wifi_list" | uniq -u | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: "   -font "$FONT")

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


if  [ "$chosen_network" = "󰖩  $(gettext 'Enable Wi-Fi')" ]; then

	nmcli radio wifi on

    notify-send -i "/usr/share/icons/Adwaita/symbolic/status/network-wireless-connected-symbolic.svg" "$(gettext 'Wi-Fi Enabled')" "$(gettext 'Wi-Fi has been enabled.')"


elif [ "$chosen_network" = "󰖪  $(gettext 'Disable Wi-Fi')" ]; then

	nmcli radio wifi off

    notify-send -i "/usr/share/icons/Adwaita/symbolic/status/network-wireless-offline-symbolic.svg" "$(gettext 'Wi-Fi Disabled')" "$(gettext 'Wi-Fi has been disabled.')"

else


    # Mensagem a ser mostrada quando a conexão for bem-sucedida.

	# Message to show when connection is activated successfully


    message=$(gettext 'You are now connected to the Wi-Fi network %s.')

  	success_message=$(printf "$message" "\"$chosen_id\"")



	# Get saved connections

    # Verifica se a rede já está salva.

	saved_connections=$(nmcli -g NAME connection)



# find /usr/share/icons/ -name "*network-wireless-offline*"


    # Conectar à rede salva ou pedir senha se necessário

    if echo "$saved_connections" | grep -w -q "$chosen_id"; then

        # Conecta-se à rede salva.


        message=$(gettext 'Failed to connect to %s. Please check the network.')


        nmcli connection up id "$chosen_id" | grep "successfully" && notify-send  -i "/usr/share/icons/Adwaita/symbolic/status/network-wireless-connected-symbolic.svg" "$(gettext 'Connection Established')" "$success_message" || notify-send -i "/usr/share/icons/Adwaita/symbolic/status/network-wireless-offline-symbolic.svg" "$(gettext 'Wi-Fi Connection Error')" "$(printf "$message" "'$chosen_id'")"

    else

        # Se for uma rede protegida, pede a senha.

        if [[ "$chosen_network" =~ "" ]]; then

            wifi_password=$(rofi -dmenu -p "$(gettext 'Password:') " -lines 1 -font "$FONT")

        fi

        # Conecta-se à rede Wi-Fi usando a senha fornecida.

        message=$(gettext 'Failed to connect to %s. Please check the network.')


        nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep "successfully" && notify-send -i "/usr/share/icons/Adwaita/symbolic/status/network-wireless-connected-symbolic.svg" "$(gettext 'Connection Established')" "$success_message" || notify-send -i "/usr/share/icons/Adwaita/symbolic/status/network-wireless-offline-symbolic.svg" "$(gettext 'Wi-Fi Connection Error')" "$(printf "$message" "'$chosen_id'")"




    fi


fi


exit 0

