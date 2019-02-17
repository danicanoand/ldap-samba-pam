# PAM
## @edt ASIX M06-ASO Curs 2018-2019

Podeu trobar les imatges docker al Dockehub de [danicano](https://hub.docker.com/u/danicano/)

Podeu trobar la documentació del mòdul a [ASIX-M06](https://sites.google.com/site/asixm06edt/)


ASIX M06-ASO Escola del treball de barcelona

 * **hostpam:18samba** host pam amb authenticació ldap. Monta els home dels usuaris samba (cifs) dintre del home de la maquina.
Atenció, per poder realitzar el mount cal que el container es generi amb l'opció **--privileged**.

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
poden ser locals o de xarxa via LDAP. Així doncs, el servidor samba ha d'estar configurat amb nscd i nslcd per
poder accedir al ldap. Amb getent s'han de poder llistar tots els usuaris i grups de xarxa.

    * *homes* Cal que els usuaris tinguin un directori home. Els usuaris unix local ja en tenen en crear-se
l'usuari, però els usuaris LDAP no. Per tant cal crear el directori home dels usuaris ldap i assignar-li la 
propietat i el grup de l'usuari apropiat.

    * *Usuaris samba* Cal crear els comptes d'usuari samba (recolsats en l'existència del mateix usuari unix/ldap).
Per a cada usuari samba els pot crear amb *smbpasswd* el compte d'usuasi samba assignant-li el password de samba. 
Aquest es desarà en la base de dades ldap. 
Convé que sigui el mateix que el de ldap per tal de que en fer login amb un sol password es validi l'usuari (auth de
pam_ldap.so) i es munti el  home via samba (pam_mount.so).


  * **hostpam** Un hostpam configurat per accedir als usuarislocals i ldap i que usant pam_mount.so
munta dins del home dels usuaris un home de xarxa via samba. Cal configurar */etc/security/pam_mount.conf.xml* 
per muntar el recurs samba dels *[homes]*.


#### Execució

```
docker network create sambanet
docker run --rm --name server -h server --network sambanet -d danicano/ldapserver:18samba

docker run --rm --name samba -h samba --network sambanet --privileged -it danicano/samba:18homes

docker run --rm --name host -h host --network sambanet --privileged -it danicano/hostpam:18samba
```


#### Configuracions

system-auth:
```
auth        optional      pam_mount.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
-session     optional      pam_systemd.so
session     optional      pam_mkhomedir.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     [success=2 default=ignore] pam_succeed_if.so uid < 5000
session     requisite      pam_ldap.so
session     optional      pam_mount.so
session     sufficient  pam_unix.so

```

pam_mount.conf.xml:
```
<volume user="*" fstype="cifs" server="172.19.0.3" path="%(USER)" mountpoint="~/%(USER)" />
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


#### Utilització

```
getent passwd
getent group

# su - anna
Creating directory '/tmp/home/anna'.
reenter password for pam_mount:

[anna@host ~]$ ll anna/
total 0
drwxr-xr-x+ 2 anna usuaris 0 Dec 26 11:40 anna

[anna@host ~]$ df -h
Filesystem         Size  Used Avail Use% Mounted on
//172.19.0.3/anna   45G   18G   25G  42% /tmp/home/anna/anna

[anna@host ~]$ mount -t cifs
//172.19.0.3/anna on /tmp/home/anna/anna type cifs (rw,relatime,vers=1.0,cache=strict,username=anna,domain=,uid=5002,forceuid,gid=10000,forcegid,addr=172.19.0.3,unix,posixpaths,serverino,mapposix,acl,rsize=1048576,wsize=65536,echo_interval=60,actimeo=1)
```

