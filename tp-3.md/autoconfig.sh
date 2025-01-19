```
#!/bin/bash

log() {
    echo "$(date +'%H:%M:%S') [$1] $2"
}
log "INFO" "Le script commence."

if [ "$(id -u)" -ne 0 ]; then
    log "ERROR" "Faut être root pour lancer ça."
    exit 1
fi
log "INFO" "Ok, on est root."

if sestatus | grep -q "enforcing"; then
    log "WARN" "SELinux est actif, je désactive."
    setenforce 0
    log "INFO" "SELinux désactivé (temporaire)."
else
    log "INFO" "SELinux est déjà désactivé."
fi

if grep -q "^SELINUX=enforcing" /etc/selinux/config; then
    sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
    log "INFO" "SELinux désactivé (fichier)."
else
    log "INFO" "Le fichier SELinux est bon."
fi

if systemctl is-active --quiet firewalld; then
    log "INFO" "Le firewall marche bien."
else
    log "ERROR" "Le firewall est pas actif."
    exit 1
fi

SSH_PORT=$(grep "^Port " /etc/ssh/sshd_config | awk '{print $2}' || echo "22")
if [ "$SSH_PORT" == "22" ]; then
    log "WARN" "SSH utilise encore le port 22, on change."
    NEW_PORT=$((RANDOM % 64512 + 1024))
    sed -i "s/^Port 22/Port $NEW_PORT/" /etc/ssh/sshd_config
    log "INFO" "SSH écoute sur le port $NEW_PORT."
    systemctl restart sshd
    firewall-cmd --permanent --add-port=${NEW_PORT}/tcp
    firewall-cmd --permanent --remove-port=22/tcp
    firewall-cmd --reload
    log "INFO" "Firewall mis à jour pour le port $NEW_PORT."
else
    log "INFO" "Le port SSH est déjà bon."
fi

CURRENT_HOSTNAME=$(hostnamectl --static)
if [ "$CURRENT_HOSTNAME" == "localhost" ]; then
    NEW_HOSTNAME=${1:-"nouveau-nom"}
    hostnamectl set-hostname "$NEW_HOSTNAME"
    log "INFO" "Nom de la machine changé en $NEW_HOSTNAME."
else
    log "INFO" "Le nom de la machine est déjà réglé."
fi

USER_NAME="abc"
if id "$USER_NAME" &>/dev/null; then
    if ! groups "$USER_NAME" | grep -q "wheel"; then
        log "WARN" "$USER_NAME n'est pas dans wheel."
        usermod -aG wheel "$USER_NAME"
        log "INFO" "$USER_NAME ajouté à wheel."
    else
        log "INFO" "$USER_NAME est déjà dans wheel."
    fi
else
    log "ERROR" "L'utilisateur $USER_NAME existe pas."
    exit 1
fi

log "INFO" "Le script est fini."

```
