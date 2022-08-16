#!/bin/bash -uxe


# ------ CHECK THE DEVELOPMENT ENVIRONMENT ------

# Detect OS
if grep -qs "ubuntu" /etc/os-release; then
	os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
else
	echo "This installer seems to be running on an unsupported distribution. Supported distros are Ubuntu 20.04 and 22.04"
	exit
fi

# Check if the Ubuntu version is too old
if [[ "$os" == "ubuntu" && "$os_version" -lt 2004 ]]; then
	echo "Ubuntu 20.04 or higher is required to use this installer. This version of Ubuntu is too old and unsupported."
	exit
fi

# Check if the user is root or not
check_root() {
  if [[ $EUID -ne 0 ]]; then
    if [[ ! -z "$1" ]]; then
      SUDO='sudo -E -H'
    else
      SUDO='sudo -E'
    fi
  else
    SUDO=''
  fi
}
check_root

# ------ INSTALL ANSIBLE AND DEPENDENCIES ------

echo
read -p "Do you want to install the ansible environment? [y/N]: " do_install
until [[ "$do_install" =~ ^[yYnN]*$ ]]; do
				echo "$do_install: invalid selection."
				read -p "[y/N]: " do_install
done

if [[ "$launch_playbook" =~ ^[yY]$ ]]; then

  # Disable user interaction while installing
  export DEBIAN_FRONTEND=noninteractive

  # Update apt database, update all packages and install Ansible + dependencies. While installing, ignore interaction and force config overwrites
  $SUDO apt update -y;
  yes | $SUDO apt-get -o Dpkg::Options::="--force-confold" -fuy dist-upgrade;
  yes | $SUDO apt-get -o Dpkg::Options::="--force-confold" -fuy install software-properties-common curl git python3 python3-setuptools python3-apt python3-pip apitude -y;
  yes | $SUDO apt-get -o Dpkg::Options::="--force-confold" -fuy autoremove;
  yes | $SUDO add-apt-repository --yes --update ppa:ansible/ansible
  yes | $SUDO apt install ansible
  yes | $SUDO python3 -m pip install ansible

  ansible-galaxy install -r requirements.yml

  # Enable user interaction again
  export DEBIAN_FRONTEND=
fi

# ssh-keygen -t ed25519 -C "tobi.kaerst@gmx.de"

# ------ RUN THE PLAYBOOK ------

echo
read -p "Would you like to run the playbook now? [y/N]: " launch_playbook
until [[ "$launch_playbook" =~ ^[yYnN]*$ ]]; do
				echo "$launch_playbook: invalid selection."
				read -p "[y/N]: " launch_playbook
done

if [[ "$launch_playbook" =~ ^[yY]$ ]]; then
  ansible-playbook run.yml
else
  echo "Still testing connections..."
  ansible all -m ping
  echo "You can run the playbook by executing the following command"
  echo "ansible-playbook run.yml"
  exit
fi

