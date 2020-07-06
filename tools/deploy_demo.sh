#!/bin/bash
#
# Deploy a demo config to AWX
#

export TOWER_HOST=http://localhost
export TOWER_USERNAME=admin
export TOWER_PASSWORD=password
export SSH_KEY_DATA=$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' /home/ansible/.ssh/id_rsa)
export HOSTS=$(sed '/vagrant-hostmanager-start/,/vagrant-hostmanager-end/!d;//d' /etc/hosts | awk '/^(1|2)/ { print $2 }')

c=1
while [ `curl -s -o /dev/null -w "%{http_code}" http://localhost/api/v2/ping/` != "200" ]
do
    echo "AWX not ready yet. Wait for 30s ($c/20) ..."
    sleep 30
    c=`expr $c + 1`
    if [ $c -ge 20 ]; then
        echo "\n\nTimout reached - AWX does still not accept API requests.\n\n"
        exit 255
    fi
done

# Auth
awx login

# Clean Up
awx job_templates get 'Demo Job Template' &>/dev/null && awx job_templates delete 'Demo Job Template'
awx projects get 'Demo Project' &> /dev/null && awx projects delete 'Demo Project'
awx credentials get 'Demo Credential' &> /dev/null && awx credentials delete 'Demo Credential'
awx inventory get 'Demo Inventory' &> /dev/null && awx inventory delete 'Demo Inventory'

# Inventory
awx inventory create \
 --name "MiniLab" \
 --organization Default

# Inventory Nodes
for each in $HOSTS
do
    awx hosts create \
     --name $each \
     --description "MiniLab Node" \
     --inventory "MiniLab"
done

# Credentials
awx credentials create \
 --name "MiniLab" \
 --organization Default \
 --credential_type "Machine" \
 --inputs "{'username': 'ansible', 'ssh_key_data': '@/home/ansible/.ssh/id_rsa', 'become_method': 'sudo', 'become_username': 'root'}"

# Projects
awx projects create \
 --name "MiniLab" \
 --scm_type git \
 --scm_url "https://github.com/ansible/ansible-tower-samples" \
 --scm_update_on_launch true

sleep 10
awx login

# Templates
awx job_templates create \
 --name="Hello MiniLab" \
 --project "MiniLab" \
 --playbook "hello_world.yml" \
 --inventory "MiniLab" \
 --credential "MiniLab"

awx job_templates get 'Hello MiniLab'

exit $?