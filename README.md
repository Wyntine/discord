![Discord Logo](discord-logo-wordmark.png)

# Discord RPM Patch

Unofficial RPM package installer and patcher for Discord.

- Forked from [RPM-Outpost/discord](https://github.com/RPM-Outpost/discord)
- Uses [Vencord/Installer](https://github.com/Vencord/Installer)

## How to use

1. Clone the repository and `cd` to the `discord-rpm-patch` directory:

   ```
   git clone https://github.com/Wyntine/discord-rpm-patch.git
   cd discord-patch
   ```

2. Run `./install-discord.sh`.
3. Enter sudo password if requested.

## Features

- Downloads the latest version of Discord from the official website
- Installs stable Discord with created RPM package and patches with Vencord
- Automatic installation and patching except authorization
- Adds Discord to the applications list with a nice HD icon
- Supports Fedora 41 (Last tested version)

## More information

### Warning - no accents

The path where you run the script must **not** contain any special character like é, ü, ö, ç, etc. This is a limitation of the RPM tools.

### How to update

When a new version of Discord is released, simply run the script again to get the updated version.

### Dependencies

The `rpmdevtools` package is required to build RPM packages. The script detects if it isn't installed and offers to install it.

### About root privileges

Building an RPM package with root privileges is dangerous. The script will request sudo permission when needed. More information: http://serverfault.com/questions/10027/why-is-it-bad-to-build-rpms-as-root
