# TP1 : Serve things and monitor things

# I. Service SSH

## 1. Analyse du service

🌞 **S'assurer que le service `sshd` est démarré**

```bash 
[fata@vbox ~]$ systemctl status
● vbox
    State: running
    Units: 285 loaded (incl. loaded aliases)
     Jobs: 0 queued
   Failed: 0 units
    Since: Mon 2024-12-02 16:12:53 CET; 1h 19min ago
  systemd: 252-46.el9_5.2.0.1
   CGroup: /
           ├─init.scope
           │ └─1 /usr/lib/systemd/systemd --switched-root --system --deserialize 31
           ├─system.slice
           │ ├─NetworkManager.service
           │ │ └─708 /usr/sbin/NetworkManager --no-daemon
           │ ├─auditd.service
           │ │ └─643 /sbin/auditd
           │ ├─chronyd.service
           │ │ └─705 /usr/sbin/chronyd -F 2
           │ ├─crond.service
           │ │ ├─ 751 /usr/sbin/crond -n
           │ │ └─4553 /usr/sbin/anacron -s
           │ ├─dbus-broker.service
           │ │ ├─675 /usr/bin/dbus-broker-launch --scope system --audit
           │ │ └─677 dbus-broker --log 4 --controller 9 --machine-id 605367c1bed2405d81719f1>
           │ ├─firewalld.service
           │ │ └─682 /usr/bin/python3 -s /usr/sbin/firewalld --nofork --nopid
           │ ├─rsyslog.service
           │ │ └─801 /usr/sbin/rsyslogd -n
           │ ├─sshd.service
           │ │ └─742 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"
           │ ├─systemd-journald.service
           │ │ └─561 /usr/lib/systemd/systemd-journald
           │ ├─systemd-logind.service
           │ │ └─695 /usr/lib/systemd/systemd-logind
           │ └─systemd-udevd.service
           │   └─udev
           │     └─577 /usr/lib/systemd/systemd-udevd
           └─user.slice
             └─user-1000.slice
               ├─session-1.scope
               │ ├─ 753 "login -- fata"
               │ └─4258 -bash
               ├─session-3.scope
               │ ├─4360 "sshd: fata [priv]"
lines 1-43
```

🌞 **Analyser les processus liés au service SSH**

```bash
[fata@vbox ~]$ ps aux | grep sshd
root         742  0.0  0.5  16796  9088 ?        Ss   16:12   0:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root        4360  0.0  0.6  20328 11648 ?        Ss   16:19   0:00 sshd: fata [priv]
fata        4365  0.0  0.3  20328  6808 ?        S    16:19   0:00 sshd: fata@pts/0
root       14480  0.0  0.6  20316 11520 ?        Ss   17:30   0:00 sshd: fata [priv]
fata       14484  0.0  0.3  20316  6932 ?        S    17:30   0:00 sshd: fata@pts/1
fata       14513  0.0  0.1   6408  2304 pts/1    S+   17:33   0:00 grep --color=auto sshd
```
🌞 **Déterminer le port sur lequel écoute le service SSH**

```bash
[fata@vbox ~]$ sudo ss -alnpt | grep sshd
[sudo] password for fata:
LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=742,fd=3))
LISTEN 0      128             [::]:22           [::]:*    users:(("sshd",pid=742,fd=4))
```
🌞 **Consulter les logs du service SSH**

```bash
[fata@vbox ~]$ sudo journalctl -u sshd
Dec 02 16:12:57 localhost.localdomain systemd[1]: Starting OpenSSH server daemon...
Dec 02 16:12:57 localhost.localdomain sshd[742]: Server listening on 0.0.0.0 port 22.
Dec 02 16:12:57 localhost.localdomain sshd[742]: Server listening on :: port 22.
Dec 02 16:12:57 localhost.localdomain systemd[1]: Started OpenSSH server daemon.
Dec 02 16:19:52 vbox unix_chkpwd[4362]: password check failed for user (fata)
Dec 02 16:19:52 vbox sshd[4360]: pam_unix(sshd:auth): authentication failure; logname= >
Dec 02 16:19:54 vbox sshd[4360]: Failed password for fata from 192.168.56.1 port 55849 >
Dec 02 16:19:59 vbox sshd[4360]: Accepted password for fata from 192.168.56.1 port 5584>
Dec 02 16:19:59 vbox sshd[4360]: pam_unix(sshd:session): session opened for user fata(u>
Dec 02 17:30:23 vbox sshd[14480]: Accepted password for fata from 10.1.1.4 port 56002 s>
Dec 02 17:30:23 vbox sshd[14480]: pam_unix(sshd:session): session opened for user fata(>
lines 1-11/11 (END)
```
```bash
[fata@vbox /]$ sudo tail -n 10 /var/log/secure
Dec  2 17:30:23 vbox sshd[14480]: pam_unix(sshd:session): session opened for user fata(uid=1000) by fata(uid=0)
Dec  2 17:34:05 vbox sudo[14514]:    fata : TTY=pts/1 ; PWD=/home/fata ; USER=root ; COMMAND=/sbin/ss -alnpt
Dec  2 17:34:05 vbox sudo[14514]: pam_unix(sudo:session): session opened for user root(uid=0) by fata(uid=1000)
Dec  2 17:34:05 vbox sudo[14514]: pam_unix(sudo:session): session closed for user root
Dec  2 17:35:32 vbox sudo[14520]:    fata : TTY=pts/1 ; PWD=/home/fata ; USER=root ; COMMAND=/bin/journalctl -u sshd
Dec  2 17:35:32 vbox sudo[14520]: pam_unix(sudo:session): session opened for user root(uid=0) by fata(uid=1000)
Dec  2 17:36:44 vbox sudo[14520]: pam_unix(sudo:session): session closed for user root
Dec  2 17:37:19 vbox sudo[14527]:    fata : TTY=pts/1 ; PWD=/home/fata ; USER=root ; COMMAND=/bin/tail -n 10 /var/log/auth.log
Dec  2 17:37:19 vbox sudo[14527]: pam_unix(sudo:session): session opened for user root(uid=0) by fata(uid=1000)
Dec  2 17:37:19 vbox sudo[14527]: pam_unix(sudo:session): session closed for user root
```
## 2. Modification du service

🌞 **Identifier le fichier de configuration du serveur SSH**

```bash
/etc/ssh/sshd_config
```
🌞 **Modifier le fichier de conf**

```bash
[fata@vbox /]$ echo $((RANDOM % 65535 + 1))
8684
```

```bash
[fata@vbox /]$ sudo cat /etc/ssh/sshd_config | grep Port
#Port 8684
#GatewayPorts no
```

```bash 
[fata@vbox /]$ sudo firewall-cmd --remove-service=ssh --permanent
success

[fata@vbox /]$ sudo firewall-cmd --add-port=12345/tcp --permanent
success

[fata@vbox /]$ sudo firewall-cmd --list-all | grep ports
  ports: 12345/tcp
  forward-ports:
  source-ports:
```
🌞 **Redémarrer le service**

```bash
[fata@vbox /]$ sudo systemctl restart sshd

[fata@vbox ~]$ sudo systemctl status sshd
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; preset: enabled)
     Active: active (running) since Mon 2024-12-16 15:39:07 CET; 13s ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 1390 (sshd)
      Tasks: 1 (limit: 11084)
     Memory: 1.4M
        CPU: 9ms
     CGroup: /system.slice/sshd.service
             └─1390 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Dec 16 15:39:07 vbox systemd[1]: Starting OpenSSH server daemon...
Dec 16 15:39:07 vbox sshd[1390]: Server listening on 0.0.0.0 port 22.
Dec 16 15:39:07 vbox sshd[1390]: Server listening on :: port 22.
Dec 16 15:39:07 vbox systemd[1]: Started OpenSSH server daemon.
```
🌞 **Effectuer une connexion SSH sur le nouveau port**

```bash
PS C:\Users\makina> ssh fata@10.1.1.1 -p 22
fata@10.1.1.1's password:
Last login: Mon Dec 16 15:13:59 2024 from 10.1.1.4
```
✨ **Bonus : affiner la conf du serveur SSH**

```bash

```

# II. Service HTTP

## 1. Mise en place

🌞 **Installer le serveur NGINX**

```bash
[fata@vbox ~]$ sudo dnf install nginx
[sudo] password for fata:
Rocky Linux 9 - BaseOS                                                                  3.9 kB/s | 4.1 kB     00:01
Rocky Linux 9 - BaseOS                                                                  1.0 MB/s | 2.3 MB     00:02
Rocky Linux 9 - AppStream                                                               9.3 kB/s | 4.5 kB     00:00
Rocky Linux 9 - AppStream                                                               1.1 MB/s | 8.3 MB     00:07
Rocky Linux 9 - Extras                                                                  544  B/s | 2.9 kB     00:05
Rocky Linux 9 - Extras                                                                   28 kB/s |  16 kB     00:00
Dependencies resolved.
========================================================================================================================
 Package                         Architecture         Version                             Repository               Size
========================================================================================================================
Installing:
 nginx                           x86_64               2:1.20.1-20.el9.0.1                 appstream                36 k
Installing dependencies:
 nginx-core                      x86_64               2:1.20.1-20.el9.0.1                 appstream               566 k
 nginx-filesystem                noarch               2:1.20.1-20.el9.0.1                 appstream               8.4 k
 rocky-logos-httpd               noarch               90.15-2.el9                         appstream                24 k

Transaction Summary
========================================================================================================================
Install  4 Packages

Total download size: 634 k
Installed size: 1.8 M
Is this ok [y/N]: y
Downloading Packages:
(1/4): nginx-filesystem-1.20.1-20.el9.0.1.noarch.rpm                                     48 kB/s | 8.4 kB     00:00
(2/4): rocky-logos-httpd-90.15-2.el9.noarch.rpm                                         128 kB/s |  24 kB     00:00
(3/4): nginx-1.20.1-20.el9.0.1.x86_64.rpm                                               139 kB/s |  36 kB     00:00
(4/4): nginx-core-1.20.1-20.el9.0.1.x86_64.rpm                                          977 kB/s | 566 kB     00:00
------------------------------------------------------------------------------------------------------------------------
Total                                                                                   600 kB/s | 634 kB     00:01
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                1/1
  Running scriptlet: nginx-filesystem-2:1.20.1-20.el9.0.1.noarch                                                    1/4
  Installing       : nginx-filesystem-2:1.20.1-20.el9.0.1.noarch                                                    1/4
  Installing       : nginx-core-2:1.20.1-20.el9.0.1.x86_64                                                          2/4
  Installing       : rocky-logos-httpd-90.15-2.el9.noarch                                                           3/4
  Installing       : nginx-2:1.20.1-20.el9.0.1.x86_64                                                               4/4
  Running scriptlet: nginx-2:1.20.1-20.el9.0.1.x86_64                                                               4/4
  Verifying        : rocky-logos-httpd-90.15-2.el9.noarch                                                           1/4
  Verifying        : nginx-filesystem-2:1.20.1-20.el9.0.1.noarch                                                    2/4
  Verifying        : nginx-2:1.20.1-20.el9.0.1.x86_64                                                               3/4
  Verifying        : nginx-core-2:1.20.1-20.el9.0.1.x86_64                                                          4/4

Installed:
  nginx-2:1.20.1-20.el9.0.1.x86_64                              nginx-core-2:1.20.1-20.el9.0.1.x86_64
  nginx-filesystem-2:1.20.1-20.el9.0.1.noarch                   rocky-logos-httpd-90.15-2.el9.noarch

Complete!
```
🌞 **Démarrer le service NGINX**

```bash
[fata@vbox ~]$ sudo systemctl start nginx
```
🌞 **Déterminer sur quel port tourne NGINX**

```bash
[fata@vbox ~]$ sudo ss -tlnp | grep nginx
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=11205,fd=6),("nginx",pid=11204,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=11205,fd=7),("nginx",pid=11204,fd=7))

[fata@vbox ~]$ sudo firewall-cmd --permanent --add-port=80/tcp
success

[fata@vbox ~]$ sudo firewall-cmd --reload
success
```
🌞 **Déterminer les processus liés au service NGINX**

```bash
[fata@vbox ~]$ ps aux | grep nginx
root       11204  0.0  0.0  11292  1464 ?        Ss   15:50   0:00 nginx: master process /usr/sbin/nginx
nginx      11205  0.0  0.2  15532  5048 ?        S    15:50   0:00 nginx: worker process
fata       11221  0.0  0.1   6408  2048 pts/0    S+   15:53   0:00 grep --color=auto nginx
```
🌞 **Déterminer le nom de l'utilisateur qui lance NGINX**

```bash
[fata@vbox ~]$ sudo cat /etc/passwd | grep nginx
nginx:x:996:993:Nginx web server:/var/lib/nginx:/sbin/nologin
```
🌞 **Test !**

```bash
[fata@vbox ~]$ curl http://10.1.1.1:80 | head
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
100  7620  100  7620    0     0   465k      0 --:--:-- --:--:-- --:--:--  496k
curl: (23) Failed writing body
```
## 2. Analyser la conf de NGINX

🌞 **Déterminer le path du fichier de configuration de NGINX**

```bash
[fata@vbox ~]$ ls -al /etc/nginx/nginx.conf
-rw-r--r--. 1 root root 2334 Nov  8 17:43 /etc/nginx/nginx.conf
```

🌞 **Trouver dans le fichier de conf**

```bash
[fata@vbox ~]$ cat /etc/nginx/nginx.conf | grep 80 -A 14
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }

[fata@vbox ~]$ cat /etc/nginx/nginx.conf | grep "include /usr/"
include /usr/share/nginx/modules/*.conf;

[fata@vbox ~]$ cat /etc/nginx/nginx.conf | grep "user n"
user nginx;


```

## 3. Déployer un nouveau site web

🌞 **Créer un site web**

```bash
[fata@vbox ~]$ sudo mkdir -p /var/www/tp1_parc
[sudo] password for fata:
[fata@vbox ~]$ sudo nano /var/www/tp1_parc/index.html
```

🌞 **Gérer les permissions**

```bash
[fata@vbox ~]$ ps aux | grep nginx
root       11204  0.0  0.0  11292  1464 ?        Ss   15:50   0:00 nginx: master process /usr/sbin/nginx
nginx      11205  0.0  0.3  15532  5560 ?        S    15:50   0:00 nginx: worker process
fata       11276  0.0  0.1   6408  2048 pts/0    S+   16:06   0:00 grep --color=auto nginx
[fata@vbox ~]$ sudo chown -R nginx:nginx /var/www/tp1_parc
[fata@vbox ~]$ ls -l /var/www/tp1_parc
total 4
-rw-r--r--. 1 nginx nginx 38 Dec 16 16:06 index.html
```

🌞 **Adapter la conf NGINX**

```bash
[fata@vbox ~]$ sudo firewall-cmd --zone=public --add-port=8684/tcp --permanent
[sudo] password for fata:
success
[fata@vbox ~]$ sudo firewall-cmd --reload
success
[fata@vbox ~]$ sudo firewall-cmd --zone=public --remove-port=80/tcp --permanent
success
[fata@vbox ~]$ sudo firewall-cmd --reload
success
[fata@vbox ~]$ curl http://<IP_VM>:8684 | head
-bash: IP_VM: No such file or directory
[fata@vbox ~]$ curl http://10.1.1.1:8684 | head
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
curl: (7) Failed to connect to 10.1.1.1 port 8684: Connection refused

CA VEUT PAS SE CONNECTER !!!
```

# III. Monitoring et alerting
## 1. Installation

🌞 **Installer Netdata**

```bash

```

## 2. Un peu d'analyse de service

🌞 **Démarrer le service `netdata`**

```bash

```

🌞 **Déterminer sur quel port tourne Netdata**

```bash

```

🌞 **Visiter l'interface Web**

```bash

```

## 3. Ajouter un check

🌞 **Ajouter un check**

```bash

```

🌞 **Ajouter un check**

```bash

```

## 4. Ajouter des alertes

🌞 **Configurer l'alerting avec Discord**

```bash

```

🌞 **Tester que ça fonctionne**

```bash

```

🌞 **Euh... tester que ça fonctionne pour de vrai**

```bash

```

🌞 **Configurer une alerte quand le port du serveur Web ne répond plus**

```bash

```

🌞 **Tester que ça fonctionne !**

```bash

```