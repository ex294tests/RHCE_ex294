#!/bin/bash

echo StrictHostKeyChecking=no > .ssh/config
chmod 0600 .ssh/config

yum install -y ansible-collection-community-general vim-enhanced sshpass

ansible -u root -k -m user -a "name=automation comment='Automation user' generate_ssh_key=yes shell=/bin/bash groups=wheel password={{ 'devops' | password_hash('sha512') }}" -i inventory localhost:k8s_nodes 
ansible -u root -k -m authorized_key -a "user=automation state=present key=\"{{ lookup('file', '/home/automation/.ssh/id_rsa.pub') }}\" " -i inventory k8s_nodes
ansible -u root -k -m copy -a "content='automation ALL=(root) NOPASSWD:ALL' dest=/etc/sudoers.d/automation" -i inventory k8s_nodes
ansible -u root -k -m lineinfile -a "path=/home/automation/.ssh/config line=StrictHostKeyChecking=no owner=automation group=automation  mode='0600' create=yes" -i inventory k8s_nodes

echo  "set ai nu cuc cul et ts=2 sw=2" > /home/automation/.vimrc

echo "
alias ap='ansible-playbook '
alias aps='ansible-playbook --syntax-check '
alias apc='ansible-playbook --check '

# function to look up examples only using keywords, ie 'aex user'
function aex(){
   ansible-doc $1|sed -n -e '/EXAM/,/RET/ p'
}
" >>  /home/automation/.bashrc
source  /home/automation/.bashrc
source  /home/automation/.vimrc
