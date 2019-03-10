#! /bin/bash
# @edt ASIX M06 2018-2019
# instal.lacio
# -------------------------------------
useradd lila
useradd roc
useradd patipla
useradd pla
echo -e "lila\nlila" | smbpasswd -a lila
echo -e "roc\nroc" | smbpasswd -a roc
echo -e "patipla\npatipla" | smbpasswd -a patipla
echo -e "pla\npla" | smbpasswd -a pla
echo -e "pere\npere" | smbpasswd -a pere
echo -e "anna\nanna" | smbpasswd -a anna
echo -e "pau\npau" | smbpasswd -a pau
echo -e "vladimir\nvladimir" | smbpasswd -a vladimir
echo -e "francisco\nfrancisco" | smbpasswd -a francisco
echo -e "carles\ncarles" | smbpasswd -a carles
