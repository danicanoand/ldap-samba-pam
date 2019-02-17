#! /bin/bash
# @edt ASIX M06 2018-2019
# instal.lacio
# -------------------------------------
useradd lila
useradd roc
useradd patipla
useradd pla
echo -e "smblila\nsmblila" | smbpasswd -a lila
echo -e "smbroc\nsmbroc" | smbpasswd -a roc
echo -e "smbpatipla\nsmbpatipla" | smbpasswd -a patipla
echo -e "smbpla\nsmbpla" | smbpasswd -a pla
echo -e "smbpere\nsmbpere" | smbpasswd -a pere
echo -e "smbanna\nsmbanna" | smbpasswd -a anna
echo -e "smbpau\nsmbpau" | smbpasswd -a pau
echo -e "smbvladimir\nsmbvladimir" | smbpasswd -a vladimir
echo -e "smbfrancisco\nsmbfrancisco" | smbpasswd -a francisco
echo -e "smbcarles\nsmbcarles" | smbpasswd -a carles
