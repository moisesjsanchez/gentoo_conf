# /etc/skel/.bashrc
#  ____            _     _____   _____ 
# |  _ \          | |   |  __ \ / ____|
# | |_) | __ _ ___| |__ | |__) | |     
# |  _ < / _` / __| '_ \|  _  /| |     
# | |_) | (_| \__ \ | | | | \ \| |____ 
# |____/ \__,_|___/_| |_|_|  \_\\_____|

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.

if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

# PS1
PS1='\[\e[34m\]μ\[\e[0m\]: \[\e[0m\]\W \[\e[0m\]$(git branch 2>/dev/null | grep '"'"'^*'"'"' | colrm 1 2) \[\e[35m\]=\[\e[35m\]> \[\e[0m\]'

# Setting Bash to Vi mode by default
set -o vi

# Alias
alias v='nvim'
alias sudov='sudo nvim'
alias rm='rm -i'
alias configs='cd ~/.config'
alias newbg='wal -i ~/Pictures/Wallpapers'
alias vbash='nvim ~/.bashrc'
alias sbash='source ~/.bashrc && echo ".bashrc has been updated!"'
alias savest='cp ~/.config/st-0.8.3/config.def.h ~/.config/st-0.8.3/config.h && echo "St has been saved!"'
alias installst='cd ~/.config/st-0.8.3 && sudo make clean install && cd'
alias portage='doas nvim /etc/portage/make.conf'

# Functions
# Make and install kernel
config_kernel(){
	
	echo 'Starting up kernel configuration process!'
	cd /usr/src/linux && doas make menuconfig
	while true; do
		read -p 'Would you like to now install your kernel? (y/n) ' yn
		case $yn in
			[Yy]* ) install_kernel; return;;
			[Nn]* ) echo 'Leaving kernel configuration!' && return;;
		esac
	done
	
}
install_kernel(){

	read -p 'Please type in parition of your boot: ' drive
	echo 'Now mounting' $drive '!'
	sudo mount $drive /boot
	echo 'Now performing the make and install process'
	sudo make && sudo make install_modules && sudo make install
	echo 'Now remaking intramfs!'
	sudo genkernel --lvm --mdadm --install --kernel-config=/usr/src/linux/.config initramfs
	echo 'Now configuring grub bootloader!'
	sudo grub-install --target=x86_64-efi --efi-directory=/boot --removable
	echo 'Now unmounting the boot parition!'
	sudo umount $drive
	echo 'Kernel configuration/install has now be finished!'
	return
}

export PATH="${PATH}:${HOME}/.local/bin/:${HOME}/.cargo/bin"
