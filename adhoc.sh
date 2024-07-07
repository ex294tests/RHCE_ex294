#!/bin/bash

echo StrictHostKeyChecking=no > .ssh/config
chmod 0600 .ssh/config

yum install -y ansible-collection-community-general vim-enhanced
ansible -m user -a "name=automation comment='Automation user' uid=1040 groups=wheel shell=/bin/bash generate_ssh_key=yes password={{ 'devops' | password_hash('sha512') }}" all:localhost -i inventory
ansible -m authorized_key -a "user=automation state=present key=\"{{ lookup('file', '/home/automation/.ssh/id_rsa.pub') }}\" " all:localhost -i inventory
ansible -m community.general.sudoers -a "name=automation state=present user=automation commands=ALL nopassword=true" all:localhost -i inventory

ansible -m lineinfile -a "path=/home/automation/.ssh/config line=StrictHostKeyChecking=no owner=automation group=automation  mode='0600' create=yes" -i inventory all:localhost

echo  "set ai nu cuc cul et ts=2 sw=2" > /home/automation/.vimrc

echo "
alias ap='ansible-playbook '
alias aps='ansible-playbook --syntax-check '
alias apc='ansible-playbook --check '

function aex(){
   ansible-doc $1|sed -n -e '/EXAM/,/RET/ p'
}
" >>  /home/automation/.bashrc
source  /home/automation/.bashrc