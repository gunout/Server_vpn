# Server VPN

REQUIREMENTS :

    sudo apt install openvpn 
    sudo apt install openvpn easy-rsa -y


1 . RUN 

    sudo bash vpn.sh

2 . Edit vars 

example :

    set_var EASYRSA_COUNTRY "US"
    set_var EASYRSA_PROVINCE "CA"
    set_var EASYRSA_CITY "Los Angeles"
    set_var EASYRSA_ORG "MyOrg"
    set_var EASYRSA_EMAIL "admin@myorg.com"
    set_var EASYRSA_OU "MyUnit"

3 . Construire l'authorité de certification 

4 . Configurer le serveur ( server.conf ) 

    port 1194
    proto udp
    dev tun

    # Certificats et clés
    ca ca.crt
    cert server.crt
    key server.key
    dh dh.pem
    tls-auth ta.key 0

    # Configuration du réseau
    server 10.8.0.0 255.255.255.0
    ifconfig-pool-persist ipp.txt

    # Autres paramètres
    keepalive 10 120
    cipher AES-256-CBC
    comp-lzo
    user nobody
    group nogroup
    persist-key
    persist-tun
    status openvpn-status.log
    verb 3

    # Configurer le routage
    push "redirect-gateway def1 bypass-dhcp"
    push "dhcp-option DNS 8.8.8.8"
    push "dhcp-option DNS 8.8.4.4"

enregistrer ce script ( connexion illimitées ) server.conf

5 . Demarrer le serveur 

    sudo systemctl start openvpn@server

Demmarage en même temps que le system 

    sudo systemctl enable openvpn@server

