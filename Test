#!/bin/bash

# Colores para la salida en terminal
COLOR_ROJO='\033[0;31m'
COLOR_VERDE='\033[0;32m'
COLOR_AMARILLO='\033[0;33m'
COLOR_RESET='\033[0m'

# Función para mostrar mensajes de error
error() {
    echo -e "${COLOR_ROJO}[!] Error: $1${COLOR_RESET}" >&2
}

# Función para mostrar mensajes de éxito
exito() {
    echo -e "${COLOR_VERDE}[+] $1${COLOR_RESET}"
}

# Función para mostrar advertencias
advertencia() {
    echo -e "${COLOR_AMARILLO}[!] Advertencia: $1${COLOR_RESET}"
}

# Dominios y puertos críticos para Azure DevOps
DOMINIOS=(
    "dev.azure.com"
    "visualstudio.com"
    "servicebus.windows.net"
    "core.windows.net"
)
PUERTOS=("80" "443")

# Array para almacenar dominios con conexión exitosa
DOMINIOS_CONEXION_EXITOSA=()

# Verificar resolución DNS
echo -e "\n${COLOR_VERDE}[+] Verificando resolución DNS...${COLOR_RESET}"
for DOMINIO in "${DOMINIOS[@]}"; do
    if nslookup "$DOMINIO" > /dev/null 2>&1; then
        exito "Resolución DNS exitosa para: $DOMINIO"
    else
        error "No se pudo resolver el dominio: $DOMINIO"
    fi
done

# Verificar conexión a dominios y puertos
echo -e "\n${COLOR_VERDE}[+] Verificando conexión a dominios y puertos...${COLOR_RESET}"
for DOMINIO in "${DOMINIOS[@]}"; do
    CONEXION_EXITOSA=false
    for PUERTO in "${PUERTOS[@]}"; do
        if nc -zv -w 5 "$DOMINIO" "$PUERTO" > /dev/null 2>&1; then
            exito "Conexión exitosa a $DOMINIO en el puerto $PUERTO"
            CONEXION_EXITOSA=true
        else
            error "No se pudo conectar a $DOMINIO en el puerto $PUERTO"
        fi
    done
    if $CONEXION_EXITOSA; then
        DOMINIOS_CONEXION_EXITOSA+=("$DOMINIO")
    fi
done

# Verificar configuración de proxy (si está configurado)
echo -e "\n${COLOR_VERDE}[+] Verificando configuración de proxy...${COLOR_RESET}"
if [ -n "$http_proxy" ] || [ -n "$https_proxy" ]; then
    exito "Proxy configurado:"
    echo -e "  http_proxy: ${http_proxy:-No configurado}"
    echo -e "  https_proxy: ${https_proxy:-No configurado}"
    echo -e "  no_proxy: ${no_proxy:-No configurado}"
else
    advertencia "No se encontró configuración de proxy."
fi

# Verificar acceso a IPs de Azure DevOps
echo -e "\n${COLOR_VERDE}[+] Verificando acceso a IPs de Azure DevOps...${COLOR_RESET}"
IPS=("13.107.6.183" "13.107.9.183")  # Ejemplo de IPs de Azure DevOps
for IP in "${IPS[@]}"; do
    if ping -c 1 "$IP" > /dev/null 2>&1; then
        exito "Ping exitoso a la IP: $IP"
    else
        error "No se pudo hacer ping a la IP: $IP"
    fi
done

# Verificar certificados SSL/TLS solo para dominios con conexión exitosa
echo -e "\n${COLOR_VERDE}[+] Verificando certificados SSL/TLS...${COLOR_RESET}"
for DOMINIO in "${DOMINIOS_CONEXION_EXITOSA[@]}"; do
    if openssl s_client -connect "$DOMINIO:443" -showcerts </dev/null 2>/dev/null | openssl x509 -noout -dates; then
        exito "Certificado SSL/TLS válido para: $DOMINIO"
    else
        error "Problema con el certificado SSL/TLS para: $DOMINIO"
    fi
done

# Mensaje final
echo -e "\n${COLOR_VERDE}[+] Pruebas de conectividad completadas.${COLOR_RESET}"
