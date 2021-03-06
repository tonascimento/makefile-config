UBUNTU_CODENAME = $(shell lsb_release -cs)

VIVALDI_DEB = $(shell curl -sS https://vivaldi.com/download/ | grep -oP  '<a *?href="\K(?<link>.*?amd64.deb)"' | sed 's/"//g' | head -1)

TERRAFORM_VERSION = 0.11.11
VAGRANT_VERSION = 2.2.3
PACKER_VERSION = 1.3.5
DOCKER_COMPOSE_VERSION = 1.23.2
VIRTUALBOX_EXTPACK_VERSION = 6.0.4

all: upgrade essentials development browsers tweaks tools container audio design icons themes others
essentials: prepare fonts python tmux zsh java flatpak
development: vscode atom sublimetext aws ansible molecule hashicorp dbeaver gitkraken postman \
	androidstudio apachedirectorystudio gnome_builder oracle_sql_developer \
	graphql_client intellij other_development 
browsers: firefox chrome vivaldi opera
tweaks: synapse atareao yktoo compiz vundle
tools: virtualbox skype plank wireshark qbittorrent corebird vlc tilix \
	bookworm shutter peek simplescreenrecorder typora feedreader libreoffice \
	poedit darktable bitwarden freemind discord telegram other_internet
container: kubectl docker microk8s
audio: spotify other_audio
design: inkscape gimp other_design
icons: icon_noobslab icon_papirus
themes: theme_noobslab

# Essentials
update:
	sudo apt update --fix-missing

upgrade: update
	sudo apt dist-upgrade -y
	sudo snap refresh
	flatpak update -y
	sudo -H pip install --upgrade pip
	sudo -H pip3 install --upgrade pip

	sudo apt autoremove --purge -y

clean:
	sudo apt autoremove -y && sudo apt autoclean -y && sudo apt clean all -y

prepare: flatpak
	sudo apt install -y vim curl wget git git-flow libssl-dev apt-transport-https ca-certificates software-properties-common unzip bash-completion \
		gconf-service gconf-service-backend gconf2-common libgconf-2-4

fonts:
	echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
	sudo apt install -y ttf-mscorefonts-installer

	mkdir -p ~/.fonts
	wget --continue --content-disposition https://raw.githubusercontent.com/todylu/monaco.ttf/master/monaco.ttf -P ~/.fonts/monaco.ttf
	chown ${USER}:${USER} ~/.fonts
	fc-cache -v

flatpak:
	sudo apt install -y flatpak gnome-software-plugin-flatpak
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

java:
	sudo add-apt-repository ppa:linuxuprising/java -y
	echo oracle-java11-installer shared/accepted-oracle-license-v1-2 select true | sudo /usr/bin/debconf-set-selections
	sudo apt install -y oracle-java11-installer oracle-java11-set-default

python:
	sudo -H apt -y install python-pip python3-pip
	sudo -H pip install --upgrade pip
	
tmux: files/tmux.conf
	sudo apt install -y tmux
	
	cp files/tmux.conf ~/.tmux.conf
	cp files/terminalrc ~/.config/xfce4/terminal
	chown ${USER}:${USER} ~/.tmux.conf ~/.config/xfce4/terminal

zsh: files/zshrc
	sudo apt install -y zsh
	curl -L -C - git.io/antigen > ~/.local-antigen.zsh
	chmod +x ~/.local-antigen.zsh

	sudo chsh --shell /usr/bin/zsh ${USER}
	make zsh_update base_eighties

zsh_update:
	cp files/zshrc ~/.zshrc

base_eighties: ~/.config/base16-shell
	rm -rf ~/.config/base16-shell
	git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
# Development

vscode:
	wget --continue https://go.microsoft.com/fwlink/?LinkID=760868 -O vscode.deb
	sudo dpkg -i vscode.deb
	rm vscode.deb

atom:
	wget --continue https://atom.io/download/deb -O atom.deb
	sudo apt install -y gconf2 gvfs-bin
	sudo dpkg -i atom.deb
	rm atom.deb

sublimetext:
	wget --continue -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
	sudo add-apt-repository "deb https://download.sublimetext.com/ apt/stable/"
	sudo apt-get install sublime-text

androidstudio:
	sudo add-apt-repository ppa:maarten-fonville/android-studio -y
	sudo apt install android-studio -y

intellij:
	flatpak install -y flathub com.jetbrains.IntelliJ-IDEA-Community

apachedirectorystudio:
	wget --continue http://mirror.nbtelecom.com.br/apache/directory/studio/2.0.0.v20180908-M14/ApacheDirectoryStudio-2.0.0.v20180908-M14-linux.gtk.x86_64.tar.gz -O apachedirectory.tar.gz
	tar xfz apachedirectory.tar.gz
	sudo mv ApacheDirectoryStudio /opt/apache-directory-studio
	rm apachedirectory.tar.gz

hashicorp:
	make terraform
	make vagrant
	make packer

terraform:
	wget --continue https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip -O terraform.zip
	unzip terraform.zip
	sudo mv terraform /usr/local/bin
	rm terraform.zip

vagrant:
	wget https://releases.hashicorp.com/vagrant/$(VAGRANT_VERSION)/vagrant_$(VAGRANT_VERSION)_x86_64.deb -O vagrant.deb
	sudo dpkg -i vagrant.deb
	rm vagrant.deb

packer:
	wget https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_amd64.zip -O packer.zip
	unzip packer.zip
	sudo mv packer /usr/local/bin
	rm packer.zip

dbeaver:
	sudo flatpak install -y flathub io.dbeaver.DBeaverCommunity

gitkraken:
	sudo flatpak install -y flathub com.axosoft.GitKraken

postman:
	sudo flatpak install -y flathub com.getpostman.Postman

gnome_builder:
	sudo flatpak install -y flathub org.gnome.Builder

oracle_sql_developer:
	sudo snap install osddm

graphql_client:
	sudo snap install altair

# Browsers
vivaldi:
	wget --continue $(VIVALDI_DEB) -O  vivaldi.deb
	sudo dpkg -i vivaldi.deb
	rm vivaldi.deb

chrome:
	wget --continue https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O chrome.deb
	sudo dpkg -i chrome.deb
	rm chrome.deb

opera:
	wget --continue http://download4.operacdn.com/ftp/pub/opera/desktop/56.0.3051.99/linux/opera-stable_56.0.3051.99_amd64.deb -O opera.deb
	sudo dpkg -i opera.deb
	rm opera.deb

firefox:
	sudo apt install -y firefox

# Tweaks

synapse:
	sudo add-apt-repository ppa:synapse-core/testing -y
	sudo apt install -y synapse

compiz: 
	sudo apt install -y compiz compizconfig-settings-manager compiz-core compiz-plugins compiz-plugins-default compiz-plugins-extra compiz-plugins-main compiz-plugins-main-default
	mkdir -p ~/.config/compiz-1/compizconfig/
	cp files/compiz.profile ~/.config/compiz-1/compizconfig/Default.ini
	xfconf-query -c xfce4-session -p /sessions/Failsafe/Client0_Command -t string -t string -s compiz -s ccp

vundle:
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	cp files/vimrc ~/.vimrc
	vim +PluginInstall +qall

initramfs:
	sudo sed -i 's/RESUME=.*$\/RESUME=none/g' /etc/initramfs-tools/conf.d/resume
	sudo update-initramfs -u

grub:
	sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*$\/GRUB_CMDLINE_LINUX_DEFAULT="pci=noaer"/g' /etc/default/grub
	sudo update-grub2

telegram:
	sudo flatpak install -y flathub org.telegram.desktop
	
# Tools
virtualbox:
	make virtualboxd
	make virtualbox_extpack

virtualboxd:
	wget --continue -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
	wget --continue -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
	sudo add-apt-repository -y "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian ${UBUNTU_CODENAME} contrib"
	sudo apt-get install -y virtualbox-6.0

virtualbox_extpack:
	curl  -O -C - https://download.virtualbox.org/virtualbox/$(VIRTUALBOX_EXTPACK_VERSION)/Oracle_VM_VirtualBox_Extension_Pack-$(VIRTUALBOX_EXTPACK_VERSION).vbox-extpack
	printf "y\n" | sudo VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-$(VIRTUALBOX_EXTPACK_VERSION).vbox-extpack
	rm Oracle_VM_VirtualBox_Extension_Pack-$(VIRTUALBOX_EXTPACK_VERSION).vbox-extpack

skype:
	curl -OL -C - https://go.skype.com/skypeforlinux-64.deb
	sudo dpkg -i skypeforlinux-64.deb
	rm skypeforlinux-64.deb

spotify:
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90
	sudo add-apt-repository "deb http://repository.spotify.com stable non-free"
	sudo apt install -y spotify-client

plank:
	sudo add-apt-repository -y ppa:ricotz/docky
	sudo apt install -y plank

whisker:
	sudo add-apt-repository -y ppa:gottcode/gcppa
	make update
	make upgrade

qbittorrent:
	sudo add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable
	sudo apt install -y qbittorrent

corebird:
	sudo add-apt-repository -y ppa:ubuntuhandbook1/corebird
	sudo apt install -y corebird

vlc:
	sudo add-apt-repository -y ppa:videolan/master-daily
	sudo apt install -y vlc

tilix:
	sudo add-apt-repository -y ppa:webupd8team/terminix
	sudo apt install -y tilix

shutter:
	sudo add-apt-repository -y ppa:linuxuprising/shutter
	sudo apt install -y shutter

libreoffice:
	sudo add-apt-repository -y ppa:libreoffice/ppa
	sudo apt install -y libreoffice libreoffice-l10n-pt-br libreoffice-style-sifr

peek:
	sudo add-apt-repository -y ppa:peek-developers/stable
	sudo apt install -y peek

simplescreenrecorder:
	sudo add-apt-repository -y ppa:maarten-baert/simplescreenrecorder
	sudo apt install -y simplescreenrecorder

typora:
	wget --continue -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
	sudo add-apt-repository -y 'deb https://typora.io/linux ./'
	sudo apt install -y typora

feedreader:
	sudo flatpak install -y flathub org.gnome.FeedReader

wireshark:
	sudo add-apt-repository -y ppa:wireshark-dev/stable
	sudo apt install -y wireshark

bookworm:
	sudo flatpak install -y flathub com.github.babluboy.bookworm

poedit:
	sudo flatpak install -y flathub net.poedit.Poedit

darktable:
	sudo flatpak install -y flathub org.darktable.Darktable

freemind:
	sudo snap install freemind

bitwarden:
	flatpak install -y flathub com.bitwarden.desktop

discord:
	flatpak install flathub com.discordapp.Discord

#Design 
inkscape:
	sudo add-apt-repository -y ppa:inkscape.dev/stable
	sudo apt install -y inkscape

gimp:
	sudo add-apt-repository -y ppa:otto-kesselgulasch/gimp
	sudo apt install -y gimp

# Container
kubectl:
	sudo snap install kubectl --classic

microk8s:
	sudo snap install microk8s --classic
	sudo snap disable microk8s

docker:
	make dockerd
	make docker_compose

aws:
	pip install awscli --upgrade --user

ansible:
	pip install ansible --upgrade --user

molecule:
	pip install --user molecule

ara:
	pip install --user ara

dockerd:
	curl -fsSL -C - https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(UBUNTU_CODENAME) stable"
	sudo apt install -y docker-ce
	sudo usermod -aG docker ${USER}

docker_compose:
	sudo curl -L -C - "https://github.com/docker/compose/releases/download/$(DOCKER_COMPOSE_VERSION)/docker-compose-Linux-x86_64" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose

# Icons

icon_noobslab:
	sudo add-apt-repository -y ppa:noobslab/icons
	sudo apt install -y faience-icon-theme faenza-icon-theme numix-icon-theme 

icon_papirus:
	sudo add-apt-repository -y ppa:papirus/papirus
	sudo apt install -y papirus-icon-theme libreoffice-style-papirus

# Themes

theme_noobslab:
	sudo add-apt-repository -y ppa:noobslab/themes
	sudo apt install -y plane-theme

# Others
atareao:
	sudo add-apt-repository -y ppa:atareao/atareao
	sudo apt install -y touchpad-indicator my-weather-indicator calendar-indicator

yktoo:
	sudo add-apt-repository -y ppa:yktooo/ppa
	sudo apt install -y indicator-sound-switcher


other_audio:
	sudo apt install -y libavcodec-extra libdvdread4 icedax ffmpeg easytag id3tool lame libmad0 mpg321 faac faad \
		ffmpeg2theora flac icedax id3v2 lame libflac++6v5 libjpeg-progs mjpegtools mpeg2dec mpeg3-utils mpegdemux mpg123 mpg321 \
		regionset sox uudeview vorbis-tools x264 audacious ubuntu-restricted-extras

other_indicators:
	sudo apt install -y indicator-multiload

other_internet:
	sudo apt install -y pidgin adobe-flashplugin

other_development:
	sudo apt install -y mysql-workbench pgadmin3 subversion meld git-flow

other_design:
	sudo apt install -y dia blender shutter

others:
	sudo apt install -y gparted menulibre htop preload filezilla xfce4-goodies xfce4-messenger-plugin \
		mugshot ncurses-term lm-sensors hddtemp tlp tlp-rdw tp-smapi-dkms smartmontools ethtool hexchat \
		network-manager-pptp-gnome pcmanfm thunar-dropbox-plugin font-manager camorama minidlna \
		atril inkscape arj p7zip p7zip-full p7zip-rar unrar unace-nonfree p7zip-rar p7zip-full unace \
		unrar zip unzip sharutils rar uudeview mpack arj cabextract file-roller remmina guake intel-microcode nvidia-driver-390
