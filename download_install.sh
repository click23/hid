#!/bin/sh
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run by root' >&2
    exit 1
fi

checkOS() {
    # Optional: List of supported distributions (leave empty to allow any)
    supported_distros=("Ubuntu" "Debian" "Fedora" "CentOS" "Arch")

    # Check if /etc/os-release exists
    if [[ -f "/etc/os-release" ]]; then
        # Load OS details
        source "/etc/os-release"
        distro_name="$NAME"
        distro_version="$VERSION_ID"
    else
        echo "Unable to determine Linux distribution. /etc/os-release not found."
        exit 1
    fi

    echo "Detected OS: $distro_name $distro_version"

    # If supported_distros is not empty, check if the current distro is supported
    if [[ ${#supported_distros[@]} -gt 0 ]]; then
        is_supported=false
        for distro in "${supported_distros[@]}"; do
            if [[ "$distro_name" == "$distro" ]]; then
                is_supported=true
                break
            fi
        done

        if [[ "$is_supported" != true ]]; then
            echo "Unsupported distribution: $distro_name"
            exit 1
        fi
    fi

    # Optional: Version check (example for Ubuntu 22 and above)
    if [[ "$distro_name" == "Ubuntu" ]]; then
        major_version=$(echo "$distro_version" | cut -d'.' -f1)
        if [[ "$major_version" -lt 22 ]]; then
            echo "This script only supports Ubuntu version 22 or above."
            exit 1
        fi
    fi
}
checkOS

# TODO: this commands are declared in hiddify-panel/install.sh, we don't need them here?!
#localectl set-locale LANG=C.UTF-8 >/dev/null 2>&1
#su hiddify-panel -c update-locale LANG=C.UTF-8 >/dev/null 2>&1

export DEBIAN_FRONTEND=noninteractive
export USE_VENV=true

echo "we are going to download needed files:)"
GITHUB_REPOSITORY=hiddify-config
GITHUB_USER=hiddify
GITHUB_BRANCH_OR_TAG=main

# if [ ! -d "/opt/$GITHUB_REPOSITORY" ];then
apt update
#apt upgrade -y
#apt -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

apt install -y curl unzip
mkdir -p /opt/$GITHUB_REPOSITORY
cd /opt/$GITHUB_REPOSITORY
curl -L -s -o $GITHUB_REPOSITORY.zip https://github.com/hiddify/$GITHUB_REPOSITORY/releases/download/v10.5.73/$GITHUB_REPOSITORY.zip
unzip -o $GITHUB_REPOSITORY.zip > /dev/null
rm $GITHUB_REPOSITORY.zip
rm -f xray/configs/*.json
rm -f singbox/configs/*.json
source /opt/hiddify-config/common/utils.sh
install_python
install_pypi_package pip==24.0
pip install -U hiddifypanel==8.8.99
bash install.sh --no-gui
# exit 0
# fi

sed -i "s|/opt/$GITHUB_REPOSITORY/menu.sh||g" ~/.bashrc
sed -i "s|cd /opt/$GITHUB_REPOSITORY/||g" ~/.bashrc
echo "/opt/$GITHUB_REPOSITORY/menu.sh" >>~/.bashrc
echo "cd /opt/$GITHUB_REPOSITORY/" >>~/.bashrc
if [ "$CREATE_EASYSETUP_LINK" == "true" ];then
    cd /opt/$GITHUB_REPOSITORY/hiddify-panel
    hiddify-panel-cli set-setting --key create_easysetup_link --val True
fi

hiddify-panel-cli set-setting --key auto_update --val False

read -p "Press any key to go  to menu" -n 1 key
cd /opt/$GITHUB_REPOSITORY
bash menu.sh
