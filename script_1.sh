#Run this script from root user

whoami
addgroup hadoop
adduser hadoopuser
adduser hadoopuser hadoop
sed '34 hadoopuser ALL= (ALL:ALL) NOPASSWD:ALL' /etc/sudoers
sudo cat <<EOF | tee >> /etc/sudoers
hadoopuser     ALL=(ALL:ALL)   NOPASSWD:ALL
EOF
su - hadoopuser 

