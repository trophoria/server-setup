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


# ------ CONFIGURATION GUIDE  ------

# create ssh key and save it to env

echo
read -p "Do you want to generate a ssh public key for the connection? [y/N]: " generate_ssh
until [[ "$generate_ssh" =~ ^[yYnN]*$ ]]; do
				echo "$generate_ssh: invalid selection."
				read -p "[y/N]: " generate_ssh
done

if [[ "$generate_ssh" =~ ^[yY]$ ]]; then
  echo;  echo "Please enter your email address:";
  read -p "Email: " email_input

  ssh-keygen -t ed25519 -C $email_input -f ~/.ssh/trophoria_id -q -N ""
  public_key=$(cat ~/.ssh/trophoria_id.pub)
  escaped_key=$(printf '%s\n' "$public_key" | sed -e 's/[\/&]/\\&/g')
  sed "s/{{ SSH_PUBLIC_KEY }}/$escaped_key/g" ./ansible/inventory.yml > ./ansible/_inventory.yml && mv ./ansible/_inventory.yml ./ansible/inventory.yml
fi

# setup up the rest of the env

cp -n ./ansible/templates/inventory.template.yml ./ansible/inventory.yml

keys=( 
    "HOST_IP" 
    "HOSTNAME" 
    "SSH_USER" 
    "SSH_PASSWORD" 
    "SSH_PORT" 
    "USERNAME" 
    "USER_PASSWORD" 
    "POSTGRES_USER" 
    "POSTGRES_PASSWORD" 
    "POSTGRES_TEST_USER"
    "POSTGRES_TEST_PASSWORD"
    "REDIS_PASSWORD"
)

desc=( 
    "Enter the ip adress of the remote server"
    "Enter the hostname of the remote server"
    "Enter your temporary/initial ssh user name"
    "Enter your temporary/initial ssh password"
    "Enter the desired ssh connection port"
    "Enter your desired UNIX username"
    "Enter your password of the UNIX user"
    "Enter the name of the postgres user"
    "Enter the password of the postgres database"
    "Enter the name of the postgres user for the test database"
    "Enter the password of the postgres user for the test database"
    "Enter the password of the redis server"
)

label=( 
    "Host IP: " 
    "Hostname: "
    "Temporary SSH Username: " 
    "Temporary SSH Password: " 
    "SSH port: "
    "UNIX Username: "
    "UNIX Password: "
    "Posgtres username: "
    "Postgres password: "
    "Postgres test username: "
    "Postgres test password: "
    "Redis password: "
)

username = ""

for (( i=0; i<${#keys[@]}; i++ ));
do
    if grep -q "{{ ${keys[$i]} }}" "ansible/inventory.yml"; then
        echo;  echo "${desc[$i]}";
        read -p "${label[$i]}" input
        sed "s/{{ ${keys[$i]} }}/$input/g" ./ansible/inventory.yml > ./ansible/_inventory.yml && mv ./ansible/_inventory.yml ./ansible/inventory.yml
    
        if [ "${keys[$i]}" = "USERNAME" ]; then
          username = input
        fi
    fi
done


# ------ RUN THE PLAYBOOK ------

echo
read -p "Would you like to run the playbook now? [y/N]: " launch_playbook
until [[ "$launch_playbook" =~ ^[yYnN]*$ ]]; do
				echo "$launch_playbook: invalid selection."
				read -p "[y/N]: " launch_playbook
done

cd ansible

if [[ "$launch_playbook" =~ ^[yY]$ ]]; then
  ansible-playbook run.yml
else 
  echo
  read -p "Would you like to start only the services now? [y/N]: " launch_services
  until [[ "$launch_services" =~ ^[yYnN]*$ ]]; do
          echo "$launch_services: invalid selection."
          read -p "[y/N]: " launch_services
  done

  if [[ "$launch_services" =~ ^[yY]$ ]]; then
    ansible-playbook run-services.yml
  else 
    echo "Still testing connections..."
    ansible all -m ping
    echo "You can run the playbook by executing the following command"
    echo "ansible-playbook run.yml"
  fi
fi


# ------ CONFIGURE AFTER PLAYBOOK ------

# Disable temp user/password authentication
sed "s/ansible_ssh_user:.*$/ansible_ssh_user: $username/g" ./ansible/inventory.yml > ./ansible/_inventory.yml && mv ./ansible/_inventory.yml ./ansible/inventory.yml
sed "s/ansible_ssh_pass:.*$/ansible_ssh_private_key_file: ~\/.ssh\/trophoria_id/g" ./ansible/inventory.yml > ./ansible/_inventory.yml && mv ./ansible/_inventory.yml ./ansible/inventory.yml
