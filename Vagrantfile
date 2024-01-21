# centos/stream8
#BOX = 'generic/centos8'
# BOX = 'oraclelinux/8'
BOX = 'bento/centos-stream-8'
MANAGED_COUNT = '5'
NODE_PREFFIX = 'node'
CONTROL_NAME = 'controller'
DOMAIN = 'test.local'
SUBNET = '192.168.33'
EXTRA_DISK_SIZE = 1024
CPU_NODE = '1' 
MEMORY_NODE = '1024'
CPU_CTRL = '2' 
MEMORY_CTRL = '4096'
USER = ENV['USER'] = 'root'
USER_HOME = ENV['USER_HOME'] = '/root'
USER_PASSWORD = ENV['USER_PASSWORD'] = 'root'
SSH_PATH = #{USER_HOME}/.ssh
##########################################
$PROVISION = <<-SCRIPT

echo -e "root\nroot" | passwd root
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
sed -in 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

for i in $(seq 1 #{MANAGED_COUNT}); do
    sudo echo "#{SUBNET}.$(($i+10)) #{NODE_PREFFIX}$i #{NODE_PREFFIX}$i.#{DOMAIN}" >> /etc/hosts
done
sudo echo "#{SUBNET}.10 #{CONTROL_NAME} #{CONTROL_NAME}.#{DOMAIN}" >> /etc/hosts
mkdir -p /root/.ssh

#yum update -y


if [ $(hostname) != #{CONTROL_NAME} ]; then
	echo 1, hostname=$(hostname), control node= #{CONTROL_NAME}
elif [ $(hostname) == #{CONTROL_NAME} ]; then
	echo 2, hostname=$(hostname), control node= #{CONTROL_NAME}
    yum install -y epel-release --nogpgcheck
	yum module install -y python36
	yum install -y expect
	pip3 install --upgrade pip
	pip3 install ansible==2.9.15
	####### BEGIN: Generate public and private key pairs - id_rsa, id_rsa.pub
	mkdir -pv #{ ENV['USER_HOME'] }/.ssh
	ssh-keygen -N "" -f /root/.ssh/id_rsa
	####### END
	
	####### BEGIN: Push public key to all node servers
	for i in $(seq 1 #{MANAGED_COUNT}); do
		/usr/bin/expect <<-EOL
		spawn ssh-copy-id -i #{ ENV['USER_HOME'] }/.ssh/id_rsa.pub #{SUBNET}.$(($i+10)) 
		expect "*ontinue*"
		send "yes\r"
		expect "*?assword*"
		send "root\r"
		interact
		expect eof
		EOL
	done
	
	# on the controller against itself too
	/usr/bin/expect <<-EOL
	spawn ssh-copy-id -i #{ ENV['USER_HOME'] }/.ssh/id_rsa.pub #{CONTROL_NAME} 
	expect "*ontinue*"
	send "yes\r"
	expect "*?assword*"
	send "root\r"
	interact
	expect eof
	EOL
	####### END
	
	
fi

#chown root:root -R /root/.ssh
#chmod -R 600 /root/.ssh
SCRIPT
##########################################
Vagrant.configure("2") do |config|
    config.vm.synced_folder ".", "/vagrant" #, type: "rsync"
    config.vm.box_check_update = false  
    #config.ssh.username = USER
    #config.ssh.password = USER_PASSWORD
    #config.ssh.insert_key = 'true'
	
    (1..MANAGED_COUNT.to_i).each do |i|  
        config.vm.define "#{NODE_PREFFIX}#{i}" do |node|
            disk_file = "./storage/disk#{i}.vdi"
            node.vm.box = "#{BOX}"
            node.vm.hostname = "#{NODE_PREFFIX}#{i}"
            node.vm.network "private_network", ip: "#{SUBNET}.#{i + 10}"
            node.vm.provider "virtualbox" do |vb|\
			    #vb.linked_clone = true
                vb.name = "EX294_#{NODE_PREFFIX}#{i}"
                vb.check_guest_additions = false
                vb.cpus = "#{CPU_NODE}"
                vb.memory = "#{MEMORY_NODE}"
                if "#{i}" == "#{MANAGED_COUNT}" # Will attach additional disk to last managed node
                    unless File.exist? disk_file
                    vb.customize ['createhd', '--filename', disk_file, '--size', EXTRA_DISK_SIZE]
                    end
                    
					vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', disk_file]
                end
            end
            # node.vm.provision "file", source: "./id_rsa.pub", destination: "/tmp/id_rsa.pub"
            node.vm.provision "shell", inline: $PROVISION
        end
    end
	
	 config.vm.define "#{CONTROL_NAME}" do |node|
        node.vm.box = "#{BOX}"
        node.vm.hostname = "#{CONTROL_NAME}"
        node.vm.network "private_network", ip: "#{SUBNET}.10"
        node.vm.provider "virtualbox" do |vb|
		    #vb.linked_clone = true
            vb.name = "EX294_#{CONTROL_NAME}"
            vb.check_guest_additions = false
            vb.cpus = "#{CPU_CTRL}"
            vb.memory = "#{MEMORY_CTRL}"
        end
        # node.vm.provision "file", source: "./id_rsa", destination: "/tmp/id_rsa"
        # node.vm.provision "file", source: "./id_rsa.pub", destination: "/tmp/id_rsa.pub"  
        node.vm.provision "shell", inline: $PROVISION
    end
	
		
end