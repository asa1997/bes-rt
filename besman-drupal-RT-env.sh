#!/bin/bash
function __besman_install_drupal-RT-env
{
    local environment_name=$(echo $1 | cut -f 1 -d "-")
    # echo $environment_name
    # return
    local version=$2
    local environment_directory=/var/www/html/drupal_RT_env 
    local artifact_path=$environment_directory/$environment_name-$version
    local artifact_url=https://ftp.drupal.org/files/projects/$environment_name-$version.zip
    # install_requirements
    
    if [[ ! -d $environment_directory ]]; then
        sudo mkdir -p $environment_directory
    fi

    if [[ ! -z $artifact_url ]]; then
        echo "Downloading drupal code base"
        sudo wget $artifact_url -P $environment_directory
        if [[ "$?" != "0" ]]; then
            echo "Could not find package $environment_name-$version in the url $artifact_url"
            return
        fi
        
    fi
    echo "unzipping"
    sudo unzip -q $environment_directory/$environment_name-$version.zip -d $environment_directory
    # mv $HOME/$environment_name-$version $environment_directory
    if [[ "$?" != "0" ]]; then
        echo "Could not unzip package $artifact_path.zip"
        return
    fi
    update_file_permissions
    create_db
}

# function __besman_uninstall_drupal
# {

# }


function install_requirements
{
    echo "Installing requirements"
    sudo apt update && sudo apt upgrade -y
    sudo apt install apache2 mysql-server php libapache2-mod-php php-mysql php-curl php-json php-cgi php-mysql phpmyadmin unzip -y
    sudo a2enmod rewrite
    # TODO: configure apacha2 server
}

function update_file_permissions
{
    echo "updating file permissions"
    local artifact_default=$artifact_path/sites/default
    sudo mkdir -p $artifact_default/files
    sudo chmod -R 777 $artifact_default/files
    sudo cp $artifact_default/default.settings.php $artifact_default/settings.php
    sudo chmod 777 $artifact_default/settings.php
}

function create_db
{
    echo "creating db"
    db_user=drupal_user
    db_name=drupal_env
    db_pass=drupal123
    mysql  -u root -p --force<< EOF
drop database if exists ${db_name};
drop user if exists '${db_user}'@'localhost';
CREATE USER '${db_user}'@'localhost' IDENTIFIED BY '${db_pass}';
create database ${db_name};
GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'localhost';
FLUSH PRIVILEGES;
quit
EOF
}