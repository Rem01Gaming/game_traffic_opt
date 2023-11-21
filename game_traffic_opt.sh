#!/bin/bash

# Game Traffic Optimizer v1.0
# By Rem01Gaming
# ---------------------------------------
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# Bandwidth limit
export bw_limit=3mbit

# Text coloring
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

clear
echo -e "${LIGHTBLUE}Game traffic optimizer v1.0 By Rem01Gaming"
echo "---------------------------------------"
echo -e "${NOCOLOR}"

# Check requirements
check_requirements() {
    if ! hash ip tc 2>/dev/null; then
        echo -e "${RED}error:${NOCOLOR} 'ip' or 'tc' command not found!"
        echo -e "${ORANGE}Install iproute2 first!${NOCOLOR}"
        exit 130
    fi
}

fetch_interfaces() {
    echo "Fetching available internet interfaces..."
    echo ""
    sleep 1.5
    echo "Available interfaces:"
    interfaces=$(ip -o link show | awk -F': ' '{print $2}')
    echo -e "${LIGHTCYAN}"
    ip -o link show | awk -F': ' '{print $2}'
    echo -e "${NOCOLOR}"
}

select_interface() {
    read -p "Enter the interface you want to optimize for games (e.g., ccmni1, wlan0): " selected_interface

    if [[ $interfaces =~ (^|[[:space:]])$selected_interface($|[[:space:]]) ]]; then
       export interface=$selected_interface
       echo "Interface $interface has been selected."
    else
        echo -e "${RED}error:${NOCOLOR} Invalid interface name."
        echo -e "${ORANGE}Please select from the available interfaces!${NOCOLOR}"
        exit 1
    fi
}

reset_network_optimizations() {
    tc qdisc del dev $interface root
    echo -e "${YELLOW}Your network settings on interface $interface have been reset to default.${NOCOLOR}"
    echo -e "${LIGHTGREEN}Rerun this script if you want to apply optimizations again.${NOCOLOR}"
    exit 0
}

select_game() {
    echo ""
    echo -e "${BLUE}Select game you want to optimize:${NOCOLOR}"
    echo -e "${LIGHTCYAN}1. Genshin Impact"
    echo -e "2. PUBG Mobile"
    echo -e "3. Free Fire"
    echo -e "4. Mobile Legends"
    echo -e "5. Custom with my own ports${NOCOLOR}"
    read -p "Enter number: " selected_game
    echo ""

    case $selected_game in
        1) set_ports 42472 "42472,22101-22102" ;;
        2) set_ports "7889,10012,13004,14000,17000,17500,18081,20000-20002,20371" "8011,9030,10491,10612,12235,13004,13748,17000,17500,20000-20002,7086-7995,10039,10096,11455,12070-12460,13894,13972,41182-41192" ;;
        3) set_ports "6006,6008,6674,7000-7999,8001-8012,9006,9137,10000-10015,11000-11019,12006,12008,13006,15006,20561,39003,39006,39698,39779,39800" "6006,6008,6674,7000-7999,8008,8001-8012,8130,8443,9008,9120,10000-10015,10100,11000-11019,12008,13008" ;;
        4) set_ports "5000-5221,5224-5227,5229-5241,5243-5287,5289-5352,5354-5509,5517,5520-5529,5551-5569,5601-5700,8443,9000-9010,9443,10003,30000-30900" "2702,3702,4001-4009,5000-5221,5224-5241,5243-5287,5289-5352,5354-5509,8443,9000-9010,9120,9992,10003,30000-30900" ;;
        5) custom_ports ;;
        *) echo -e "${RED}error:${NOCOLOR} Invalid selection." ;;
    esac
}

set_ports() {
    export tcp_ports=$1
    export udp_ports=$2
    apply_optimizations
}

custom_ports() {
    read -p "Enter TCP ports (leave blank if none): " tcp_ports
    read -p "Enter UDP ports (leave blank if none): " udp_ports
    apply_optimizations
}

apply_optimizations() {
    tc qdisc add dev $interface root handle 1: htb default 10
    tc class add dev $interface parent 1: classid 1:10 htb rate $bw_limit ceil $bw_limit

    set_port() {
        local protocol=$1
        local port=$2
        
        if [[ $protocol == UDP ]]; then
        export port_a=sport
        export protocol_a=17
        elif [[ $protocol == TCP ]]; then
        export port_a=dport
        export protocol_a=6
        fi

        echo "debug: entering new loop, interface=$interface, protocol=${protocol}/${protocol_a}, port=$port."
        tc filter add dev $interface protocol ip parent 1:0 prio 1 u32 match ip ${port_a} $port 0xffff match ip protocol $protocol_a 0xff flowid 1:10
    }

    handle_ports() {
        local protocol=$1
        local ports=$2

        IFS=',' read -ra port_list <<< "$ports"

        for item in "${port_list[@]}"; do
            if [[ $item =~ "-" ]]; then
                IFS='-' read -ra port_range <<< "$item"
                start=${port_range[0]}
                end=${port_range[1]}
                for ((i = start; i <= end; i++)); do
                    set_port $protocol "$i"
                done
            else
                set_port $protocol "$item"
            fi
        done
    }

    handle_ports "TCP" "$tcp_ports"
    handle_ports "UDP" "$udp_ports"

    echo -e "${LIGHTGREEN}Done!${NOCOLOR}"
}

# Main script logic
check_requirements
fetch_interfaces
select_interface

if [[ $1 == "reset" ]]; then
    reset_network_optimizations
else
    select_game
fi