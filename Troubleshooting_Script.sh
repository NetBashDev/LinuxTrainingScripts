#!/bin/bash

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verificar permisos de ejecución
if [ "$(id -u)" -ne 0 ]; then
  echo -e "${RED}Este script debe ejecutarse como root.${NC}"
  exit 1
fi

# Función para mostrar encabezados
function print_section() {
  echo -e "\n${BLUE}========================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================${NC}"
}

# 1. Verificar conectividad de red
print_section "Verificando conectividad de red"
read -p "Ingrese una dirección para hacer ping (por defecto: 8.8.8.8): " ping_target
ping_target=${ping_target:-8.8.8.8}

if ping -c 4 "$ping_target" &>/dev/null; then
  echo -e "${GREEN}Conexión con $ping_target: OK${NC}"
else
  echo -e "${RED}No se pudo conectar con $ping_target${NC}"
fi

# 2. Mostrar uso de disco
print_section "Uso de disco"
df -h | grep -v tmpfs

# 3. Mostrar uso de memoria
print_section "Uso de memoria"
free -h

# 4. Verificar servicios en ejecución
print_section "Estado de servicios críticos"
read -p "Ingrese el nombre de un servicio a verificar (por defecto: sshd): " service_name
service_name=${service_name:-sshd}

if systemctl is-active "$service_name" &>/dev/null; then
  echo -e "${GREEN}El servicio '$service_name' está activo.${NC}"
else
  echo -e "${RED}El servicio '$service_name' no está en ejecución.${NC}"
fi

# 5. Mostrar procesos más consumidores de recursos
print_section "Procesos más consumidores de recursos"
echo -e "${YELLOW}Procesos que consumen más memoria:${NC}"
ps aux --sort=-%mem | head -n 5

echo -e "\n${YELLOW}Procesos que consumen más CPU:${NC}"
ps aux --sort=-%cpu | head -n 5

# 6. Comprobar puertos abiertos
print_section "Puertos abiertos"
netstat -tuln | grep LISTEN

# 7. Mostrar logs recientes del sistema
print_section "Logs recientes del sistema"
journalctl -n 10 --no-pager

# 8. Verificar reglas del firewall
print_section "Estado del Firewall"
if command -v ufw &>/dev/null; then
  ufw status
elif command -v firewall-cmd &>/dev/null; then
  firewall-cmd --state
else
  echo -e "${YELLOW}No se detectó un firewall activo o instalado.${NC}"
fi

# 9. Verificar espacio en /var/log (opcional)
print_section "Espacio en /var/log"
du -sh /var/log/* 2>/dev/null | sort -hr | head -n 5

# 10. Verificar carga del sistema
print_section "Carga del sistema"
uptime

# Finalizar
print_section "Análisis básico completado"
echo -e "${GREEN}Si encontró problemas, revise los detalles arriba para tomar acción.${NC}"
