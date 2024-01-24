#!/bin/bash

vpn_path=/opt
vpn_script_path=$vpn_path/vpn
vpn_config_path=$vpn_path/vpn/vpn_config

ask_question() {
    local question=$1
    local answer

    read -p "$question " answer
    echo "$answer"
}

get_vpn_files() {
    
    wget -P $vpn_path https://docs.basa.ir/vpn/linux/vpn.tar.gz
    tar -xvzf $vpn_path/vpn.tar.gz -C $vpn_path/
    chmod +x $vpn_path/*
    mv $vpn_script_path/vpn /bin
}

current_os_dns=$(cat /etc/resolv.conf | grep -oP 'nameserver \K\d+\.\d+\.\d+\.\d+' | head -n 1)

operation=$(ask_question "choose operation [ --install | --install-basa  | --edit | --uninstall ]:")

case $operation in

    --install)
        
        get_vpn_files
        vpn_host=$(ask_question "What is your vpn host?")
        vpn_port=$(ask_question "What is your vpn port?")
        vpn_hub=$(ask_question "What is your virtual hub?")
        username=$(ask_question "What is your username?")
        password=$(ask_question "What is your password?")

        if [[ $vpn_host =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            VPN_IP=$vpn_host
        else
            VPN_IP=$(nslookup $vpn_host $current_os_dns| grep -A 2 "Name" | grep Address | awk 'NR==1 {print $2}')
        fi

        DEFAULT_GW="192.168.30.1"

        LAST_GATEWAY=$(ip route | awk '/default/ { print $3 }')
        
        sed -i "s|\${ACCOUNT_NAME}|$username|g" $vpn_config_path
        sed -i "s|\${VPN_HOST_IPv4}|$VPN_IP|g" $vpn_config_path
        sed -i "s|\${LOCAL_GATEWAY}|$LAST_GATEWAY|g" $vpn_config_path
        sed -i "s|\${DESTINATION_HUB}|$vpn_hub|g" $vpn_config_path
        sed -i "s|\${VPN_PORT}|$vpn_port|g" $vpn_config_path
        sed -i "s|\${VPN_PASS}|$password|g" $vpn_config_path
        sed -i "s|\${DEFAULT_GW}|$DEFAULT_GW|g" $vpn_config_path
        
        bash  $vpn_script_path/setup-client.sh
        vpn start

        echo
        echo
        echo "---------------------> start your vpn with command:   vpn start"
        echo "---------------------> stop your vpn with command:    vpn stop"

    ;;

    --install-simple)
        
        get_vpn_files
        vpn_host="your-company-domain"
        vpn_port="your-company-port"
        vpn_hub="your-company-hub"
        username=$(ask_question "What is your username?")
        password=$(ask_question "What is your password?")

        
        VPN_IP=$(nslookup $vpn_host $current_os_dns| grep -A 2 "Name" | grep Address | awk 'NR==1 {print $2}')
        

        LAST_GATEWAY=$(ip route | awk '/default/ { print $3 }')
        DEFAULT_GW="your-company-default-gateway"
        
        sed -i "s|\${ACCOUNT_NAME}|$username|g" $vpn_config_path
        sed -i "s|\${VPN_HOST_IPv4}|$VPN_IP|g" $vpn_config_path
        sed -i "s|\${LOCAL_GATEWAY}|$LAST_GATEWAY|g" $vpn_config_path
        sed -i "s|\${DESTINATION_HUB}|$vpn_hub|g" $vpn_config_path
        sed -i "s|\${VPN_PORT}|$vpn_port|g" $vpn_config_path
        sed -i "s|\${VPN_PASS}|$password|g" $vpn_config_path
        sed -i "s|\${DEFAULT_GW}|$DEFAULT_GW|g" $vpn_config_path
        
        bash  $vpn_script_path/setup-client-custom.sh
        vpn start

        echo
        echo
        echo "---------------------> start your vpn with command:   vpn start"
        echo "---------------------> stop your vpn with command:    vpn stop"

    ;;

    --uninstall)
        
        vpn stop
        bash  $vpn_script_path/remove-client.sh
        rm -rf $vpn_script_path
        rm -rf /bin/vpn*

    ;;

    --edit)
        
        vpn stop
        bash  $vpn_script_path/remove-client.sh
        rm -rf $vpn_script_path
        rm -rf /bin/vpn*

        get_vpn_files
        vpn_host=$(ask_question "What is your vpn host?")
        vpn_port=$(ask_question "What is your vpn port?")
        vpn_hub=$(ask_question "What is your virtual hub?")
        username=$(ask_question "What is your username?")
        password=$(ask_question "What is your password?")

        if [[ $vpn_host =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            VPN_IP=$vpn_host
        else
            VPN_IP=$(nslookup $vpn_host $current_os_dns| grep -A 2 "Name" | grep Address | awk 'NR==1 {print $2}')
        fi

        LAST_GATEWAY=$(ip route | awk '/default/ { print $3 }')

        DEFAULT_GW="192.168.30.1"
        
        sed -i "s|\${ACCOUNT_NAME}|$username|g" $vpn_config_path
        sed -i "s|\${VPN_HOST_IPv4}|$VPN_IP|g" $vpn_config_path
        sed -i "s|\${LOCAL_GATEWAY}|$LAST_GATEWAY|g" $vpn_config_path
        sed -i "s|\${DESTINATION_HUB}|$vpn_hub|g" $vpn_config_path
        sed -i "s|\${VPN_PORT}|$vpn_port|g" $vpn_config_path
        sed -i "s|\${VPN_PASS}|$password|g" $vpn_config_path
        sed -i "s|\${DEFAULT_GW}|$DEFAULT_GW|g" $vpn_config_path
        
        bash  $vpn_script_path/setup-client.sh
        vpn start

        echo
        echo
        echo "---------------------> start your vpn with command:   vpn start"
        echo "---------------------> stop your vpn with command:    vpn stop"
    ;;

    *)
        echo "Invalid parameter was passed!"
    ;;

esac

