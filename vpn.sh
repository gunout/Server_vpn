#!/bin/bash

# Mise à jour du système
if ! sudo apt update && sudo apt upgrade -y; then
    echo "Échec de la mise à jour du système."
    exit 1
fi

# Installation d'OpenVPN et easy-rsa
if ! sudo apt install openvpn easy-rsa -y; then
    echo "Échec de l'installation d'OpenVPN et easy-rsa."
    exit 1
fi

# Chemin du répertoire pour easy-rsa
EASYRSA_DIR=~/openvpn-ca

# Vérifiez si le répertoire existe déjà
if [ -d "$EASYRSA_DIR" ]; then
    echo "Le répertoire $EASYRSA_DIR existe déjà."
    read -p "Voulez-vous le supprimer et en créer un nouveau ? (o/n) " answer
    if [[ "$answer" == "o" ]]; then
        rm -rf "$EASYRSA_DIR"
    else
        echo "Abandon de l'installation."
        exit 1
    fi
fi

# Création du répertoire pour easy-rsa
if ! make-cadir "$EASYRSA_DIR"; then
    echo "Échec de la création du répertoire pour easy-rsa."
    exit 1
fi

cd "$EASYRSA_DIR" || { echo "Échec de l'entrée dans le répertoire $EASYRSA_DIR"; exit 1; }

# Éditez le fichier vars pour configurer vos paramètres
echo "Veuillez éditer le fichier vars avant de continuer."
nano vars

# Initialiser le PKI (Public Key Infrastructure)
if ! ./easyrsa init-pki; then
    echo "Échec de l'initialisation du PKI."
    exit 1
fi

# Construire le certificat et la clé CA
if ! ./easyrsa build-ca; then
    echo "Échec de la construction du certificat CA."
    exit 1
fi

# Génération des clés du serveur
if ! ./easyrsa gen-req server nopass; then
    echo "Échec de la génération de la clé du serveur."
    exit 1
fi

if ! ./easyrsa sign-req server server; then
    echo "Échec de la signature de la requête du serveur."
    exit 1
fi

if ! ./easyrsa gen-dh; then
    echo "Échec de la génération de DH."
    exit 1
fi

if ! openvpn --genkey secret pki/ta.key; then
    echo "Échec de la génération de la clé secrète."
    exit 1
fi

# Configurer le serveur OpenVPN
if ! sudo cp pki/ca.crt pki/issued/server.crt pki/private/server.key pki/ta.key pki/dh.pem /etc/openvpn; then
    echo "Échec de la copie des fichiers dans /etc/openvpn."
    exit 1
fi

# Éditez le fichier de configuration du serveur
echo "Veuillez éditer le fichier de configuration du serveur."
sudo nano /etc/openvpn/server.conf

# Démarrer le serveur OpenVPN
if ! sudo systemctl start openvpn@server; then
    echo "Échec de démarrage du serveur OpenVPN."
    exit 1
fi

if ! sudo systemctl enable openvpn@server; then
    echo "Échec de l'activation du serveur OpenVPN au démarrage."
    exit 1
fi

echo "Installation et configuration d'OpenVPN terminées avec succès."

