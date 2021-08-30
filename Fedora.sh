#updates
#https://docs.fedoraproject.org/en-US/quick-docs/dnf-system-upgrade/
sudo dnf upgrade --refresh
sudo dnf install dnf-plugin-system-upgrade
sudo dnf system-upgrade download --releasever=34
sudo dnf system-upgrade reboot


#installs

#zoom
sudo dnf install wget -y 
wget https://zoom.us/client/latest/zoom_x86_64.rpm 
sudo dnf localinstall zoom_x86_64.rpm

#wine
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/34/winehq.repo
sudo dnf -y install winehq-stable
wget  https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks
sudo mv winetricks /usr/local/bin/

#teams
wget https://packages.microsoft.com/yumrepos/ms-teams/teams-1.2.00.32451-1.x86_64.rpm
sudo dnf localinstall teams-1.2.00.32451-1.x86_64.rpm