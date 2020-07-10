require 'ipaddr'

puts "\n=== AWX MiniLab ===\n\n"
system('./tools/create_key.sh')

Vagrant.configure("2") do |config|

    # hostmanager plugin configuration
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = false
    config.hostmanager.manage_guest = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true

    config_file = YAML.load_file('config.yaml')

    # fetch lab configuration
    lab_domain = config_file.fetch('lab').fetch('domain')
    lab_provision = config_file.fetch('lab').fetch('provision')

    # fetch AWX configuration
    awx_image = "centos/8"
    awx_cpu = config_file.fetch('awx').fetch('cpu')
    awx_memory = config_file.fetch('awx').fetch('memory')
    awx_hostname = config_file.fetch('awx').fetch('hostname')
    awx_port_http = config_file.fetch('awx').fetch('port_http')
    awx_port_https = config_file.fetch('awx').fetch('port_https')
    awx_hostip = '192.168.100.10'

    # AWX provisioning
    config.vm.define "awx" do |awx|
        hostname = awx_hostname + "." + lab_domain
        awx.vm.box = awx_image
        awx.vm.provider :virtualbox do |v|
            v.cpus = awx_cpu
            v.memory = awx_memory
        end
        awx.vm.network "private_network", ip: awx_hostip, virtualbox__intnet: true
        awx.vm.network "forwarded_port", guest: 80, host: awx_port_http
        awx.vm.network "forwarded_port", guest: 443, host: awx_port_https
        awx.vm.hostname = hostname
        if lab_provision
            awx.vm.provision "shell", inline: "sudo dnf -y install python3"
            awx.vm.provision "ansible" do |ansible|
                ansible.playbook = "setup/awx/awx.yaml"
                ansible.extra_vars = { ansible_python_interpreter:"/usr/bin/python3" }
            end
        end
        puts "AWX:  " + awx_hostname.ljust(16) + awx_hostip
    end

    # node provisioning
    nodes = config_file.fetch('nodes')
    o = 20
    nodes.each do |os, item|
        (1..item['count']).each do |i|
            o += 1
            ip = "192.168.100.#{o}"
            hostname = item['hostname'] + i.to_s
            config.vm.define hostname do |node|
                node.vm.box = item['image']
                node.vm.provider :virtualbox do |v|
                    v.cpus = item['cpu']
                    v.memory = item['memory']
                end
                node.vm.hostname = hostname + "." + lab_domain
                node.vm.network "private_network", ip: ip, virtualbox__intnet: true
                if lab_provision
                    node.vm.provision "ansible" do |ansible|
                        ansible.playbook = item['setup']
                    end
                end
                puts "Node: " + hostname.ljust(16) + ip
            end
        end
    end
end
