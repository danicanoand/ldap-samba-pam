
# SAMBA ldapsam

## @edt ASIX M06 2018-2019

Podeu trobar les imatges docker al Dockehub de [danicano](https://hub.docker.com/u/danicano/)

Podeu trobar la documentació del mòdul a [ASIX-M06](https://sites.google.com/site/asixm06edt/)


ASIX M06-ASO Escola del treball de barcelona

### Imatges:

* **samba:18homes**  En aquesta part vam crear un servidor SAMBA capaç de connectar a un servidor LDAP i exportar directoris HOME d'usuaris locals i LDAP. Per a això necessitem un servidor LDAP, un servidor SAMBA i un client amb LDAP i PAM configurats.

### Arquitectura

Per implementar un host amb usuaris unix i ldap on els homes dels usuaris es muntin via samba de un 
servidor de disc extern cal:

  * **sambanet** Una xarxa propia per als containers implicats.

  * **danicano/ldapserver:18samba** Un servidor ldap en funcionament amb els usuaris de xarxa. [Imatge ldapserver](https://hub.docker.com/r/danicano/ldapserver)
  
  * **hostpam:18samba** host pam amb authenticació ldap. Monta els home dels usuaris samba (cifs) dintre del home de la maquina.
Atenció, per poder realitzar el mount cal que el container es generi amb l'opció **--privileged**. [Imatge hostpam](https://hub.docker.com/r/danicano/hostpam)

  * **danicano/samba:18homes** servidor SAMBA capaç de connectar a un servidor LDAP i exportar directoris HOME d'usuaris locals i LDAP. [Imatge samba](https://hub.docker.com/r/danicano/samba)
  
Contindrà:

    * *Usuaris unix* Samba requereix la existència de usuaris unix. Per tant caldrà disposar dels usuaris unix,
poden ser locals o de xarxa via LDAP. Així doncs, el servidor samba ha d'estar configurat amb ldap.conf, nscd, nslcd i 
nsswitch per poder accedir al ldap. Amb getent s'han de poder llistar tots els usuaris i grups de xarxa.

    * *homes* Cal que els usuaris tinguin un directori home. Els usuaris unix local ja en tenen en crear-se
l'usuari, però els usuaris LDAP no. Per tant cal crear el directori home dels usuaris ldap i assignar-li la 
propietat i el grup de l'usuari apropiat.

    * *Usuaris samba* Cal crear els comptes d'usuari samba (recolsats en l'existència del mateix usuari unix/ldap).
Per a cada usuari samba els pot crear amb *smbpasswd* el compte d'usuasi samba assignant-li el password de samba. 
Aquest es desarà en la base de dades ldap. 
Convé que sigui el mateix que el de ldap per tal de que en fer login amb un sol password es validi l'usuari (auth de
pam_ldap.so).
 


### Configuració samba

/etc/samba/smb.conf
```
[global]
        workgroup = MYGROUP
        server string = Samba Server Version %v
        log file = /var/log/samba/log.%m
        max log size = 50
        security = user
        passdb backend = tdbsam
        load printers = yes
        cups options = raw
[homes]
        comment = Home Directories
        browseable = no
        writable = yes
;       valid users = %S
;       valid users = MYDOMAIN\%S
```

/etc/openldap/ldap.conf
```
BASE	dc=edt,dc=org
URI		ldap://server
```

/etc/nsswitch.conf
```
passwd:    files ldap
shadow:    files 
group:     files ldap
```

/etc/nslcd.conf
```
uri ldap://server
base dc=edt,dc=org
```

#### Execució

```
docker network create sambanet 
docker run --rm --name server -h server --network sambanet -d danicano/ldapserver:18samba

docker run --rm --name samba -h samba --network sambanet --privileged -it danicano/samba:18homes

docker run --rm --name host -h host --network sambanet --privileged -it danicano/hostpam:18samba
```

#### Exemple

- Per montar-ho a mà em de veure la ip del samba18:homes en el meu cas **172.19.0.3**

		[root@pc ~]# mount -t cifs -o user=anna,password=anna //172.19.0.3/anna /mnt
		
		[root@pc ~]# df -h
			Filesystem         Size  Used Avail Use% Mounted on
			//172.19.0.3/anna   45G   28G   15G  65% /mnt
		
		[root@local ~]$ mount -t cifs
			//172.19.0.3/anna on /mnt type cifs (rw,relatime,vers=1.0,cache=strict,username=anna,domain=,uid=0,noforceuid,gid=0,noforcegid,addr=172.19.0.3,unix,posixpaths,serverino,mapposix,acl,rsize=1048576,wsize=65536,echo_interval=60,actimeo=1,user=anna)
```
[root@local ~]# su - pere
	Creating directory '/tmp/home/pere'.
	reenter password for pam_mount:
[pere@host ~]$ su - anna
	pam_mount password:
	Creating directory '/tmp/home/anna'.
[anna@host ~]$ su - francisco
	pam_mount password:
	Creating directory '/tmp/home/2wiaw/fracisco'.
[francisco@host ~]$ ll ../..
	total 12
	drwxr-xr-x. 3 root usuaris 4096 Mar 10 11:03 2wiaw
	drwxr-xr-x. 3 anna usuaris 4096 Mar 10 11:00 anna
	drwxr-xr-x. 3 pere usuaris 4096 Mar 10 11:00 pere
```

