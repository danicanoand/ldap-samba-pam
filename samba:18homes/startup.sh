#! /bin/bash
# @edt ASIX M06 2018-2019
# startup.sh
# -------------------------------------

/opt/docker/install.sh && echo "Install Ok"
/usr/sbin/nslcd && echo "nslcd Ok"
/usr/sbin/nscd && echo "nscd Ok"
/usr/sbin/smbd && echo "smb Ok"
/usr/sbin/nmbd && echo "nmb  Ok"
/opt/docker/smbusers.sh && echo "Smbusers OK"
/opt/docker/smbhomes.sh && echo "Smbhomes OK"
/bin/bash
