#!/bin/bash
# This script downloads the latest version of Discord for linux, and creates a package with rpmbuild.

cd "$(dirname "$(readlink -f -- "$0")")"

source ./scripts/terminal-colors.sh # Adds color variables
source ./scripts/common-functions.sh # Adds utilities functions
source ./scripts/basic-checks.sh # Checks that rpmbuild is available and that the script isn't started as root

rpm_dir="$PWD/RPMs"
work_dir="$PWD/work"
downloaded_dir="$work_dir/discord"
desktop_model="$PWD/discord.desktop"
spec_file="$PWD/discord.spec"
arch='x86_64'

# Settings according to the distribution
if [[ $distrib == "redhat" ]]; then
	pkg_req='libatomic%{?_isa}, glibc%{?_isa}, alsa-lib%{?_isa}, GConf2%{?_isa}, libnotify%{?_isa}, nspr%{?_isa} >= 4.13, nss%{?_isa} >= 3.27, libstdc++%{?_isa}, libX11%{?_isa} >= 1.6, libXtst%{?_isa} >= 1.2, libappindicator-gtk3%{?_isa}, libXScrnSaver%{?_isa}'
elif [[ $distrib == "suse" ]]; then
	pkg_req='libatomic1, glibc, alsa, gconf2, libnotify, mozilla-nspr >= 4.13, mozilla-nss >= 3.27, libstdc++6, libX11 >= 1.6, libXtst >= 1.2, libappindicator, libc++1, libXScrnSaver'
else
	disp "${red}Sorry, your distribution isn't supported (yet).$reset"
	exit 1
fi	

app_name='Discord'
exe_name='Discord'
pkg_name='discord'
download_url='https://discordapp.com/api/download'
cut_part=2
desktop_file="$work_dir/discord.desktop"


# Downloads the discord tar.gz archive and puts its name in the global variable archive_name.
download_discord() {
	echo "Downloading $app_name for linux..."
	archive_url=$(curl -is --write-out "%{redirect_url}\n"  "${download_url}?platform=linux&format=tar.gz" -o /dev/null)
	wget --content-disposition $wget_progress "${archive_url}"
	archive_name="$(ls *.tar.gz)"
}

manage_dir "$work_dir" 'work'
manage_dir "$rpm_dir" 'RPMs'
cd "$work_dir"

# Downloads discord if needed.
archive_name="$(ls *.tar.gz 2>/dev/null)"
if [ $? -eq 0 ]; then
	echo 'Existing archive selected.'
	rm "$archive_name"
	download_discord
else 
	download_discord
fi

# Extracts the archive:
echo
mkdir -p "$downloaded_dir"
extract "$archive_name" "$downloaded_dir" "--strip 1" # --strip 1 gets rid of the top archive's directory


# Gets Discord's version number + icon file name
echo 'Analysing the files...'
pkg_version="$(echo "$archive_name" | cut -d'-' -f$cut_part | rev | cut -c 8- | rev)"
# cut -d'-' -fn  splits the archive's name around the '-' character, and takes the n-th part
# For example if archive_name is "discord-0.0.1.tar.gz" we get "0.0.1.tar.gz"
# Then, rev | cut -c 8- | rev  reverse the string, removes the first 7 characters, and re-reverse it.
# This actually removes the last 8 characters, ie the ".tar.gz" part.
# So in our example we'll get pkg_version=0.0.1

cd "$downloaded_dir"
icon_name="$(ls *.png)"
echo " -> Version: $pkg_version"
echo " -> Icon: $icon_name"


echo 'Generating desktop entry...'
sed "s/@version/$pkg_version/; s/@icon/$icon_name/; s/@exe/$exe_name/; s/@name/$app_name/; s/@dir/$pkg_name/"\
	"$desktop_model" > "$desktop_file"

disp "${yellow}Creating the RPM package (this may take a while)..."
rpmbuild --quiet -bb "$spec_file" --define "_topdir $work_dir" --define "_rpmdir $rpm_dir"\
	--define "pkg_version $pkg_version" --define "downloaded_dir $downloaded_dir"\
	--define "desktop_file $desktop_file" --define "pkg_name $pkg_name" --define "pkg_req $pkg_req"

disp "${bgreen}RPM package created! Installation is starting...${reset_font}"

install_pkg
patch
clear_folders

