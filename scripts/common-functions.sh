#!/bin/bash
# This script requires terminal-colors.sh

# Initializes $installer and $distrib
if hash dnf 2>/dev/null; then
	# Fedora, CentOS with dnf installed
	installer="dnf install --allowerasing"
	distrib="redhat"
elif hash yum 2>/dev/null; then
	# CentOS
	installer="yum install"
	distrib="redhat"
elif hash zypper 2>/dev/null; then
	# OpenSUSE
	installer="zypper install"
	distrib="suse"
elif hash urpmi 2>/dev/null; then
	# Mageia
	installer="urpmi"
	distrib="mageia"
else
	# Unknown
	installer="exit"
	distrib="unknown"
fi

# Initializes $wget_progress: detects if the option --show-progress is available
wget --help | grep -q '\--show-progress' && wget_progress="-q --show-progress" || wget_progress=""

# manage_dir directory directory_short_name
## If the specified directory exists, asks the user if they want to remove it.
## If it doesn't exist, creates it.
manage_dir() {
	if [ -d "$1" ]; then
		rm -r "$1"
		echo "The $2 directory cleared."
	fi
	mkdir -p "$1"
}

clear_folders() {
	rm -r "$work_dir"
	echo "Work directory removed."

	rm -r "$rpm_dir"
	echo "RPMs directory removed".
}

install_pkg() {
	cd "$rpm_dir/$arch"
	rpm_filename=$(find -maxdepth 1 -type f -name '*.rpm' -printf '%P\n' -quit)
	sudo_install $rpm_filename -y
	echo "Discord successfully installed."
	cd ../..
}

# sudo_install pkg [options]
sudo_install() {
	sudo $installer "$@"
}

# sudo_install_prompt prompt pkg [options]
sudo_install_prompt() {
	if [[ $# -eq 2 ]]; then
		sudo -p "$1" $installer "$2"
	else
		sudo -p "$1" $installer "$2" $3
	fi
}

patch() {
	cd "$PWD/scripts"
	sudo ./install-vencord -install -branch stable
	echo "Vencord installed."
	sudo ./install-vencord -install-openasar -branch stable
	echo "OpenAsar installed."
	echo "Discord successfully patched."
	cd ..
}

# extract archive_file destination [option1 [option2]]
extract() {
	echo "Extracting \"$1\"..."
	if [[ "$1" == *.tar.gz ]]; then
		command="tar -xzf \"$1\" -C \"$2\""
	elif [[ "$1" == *.tar.xz ]];then
		command="tar -xJf \"$1\" -C \"$2\""
	elif [[ "$1" == *.tar.bz2 ]];then
		command="tar -xjf \"$1\" -C \"$2\""
	elif [[ "$1" == *.tar ]];then
		command="tar -xf \"$1\" -C \"$2\""
	elif [[ "$1" == *.zip ]]; then
		command="unzip -q \"$1\" -d \"$2\""
	else
		disp "${red}Unsupported archive type for $1"
		return 10
	fi
	if [ $# -eq 3 ]; then
		eval $command $3 # Custom options
	elif [ $# -eq 4 ]; then
		eval $command $3 $4 # Custom options
	else
		eval $command
	fi
}
