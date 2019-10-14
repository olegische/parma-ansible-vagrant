# -*- mode: ruby -*-
# vi: set ft=ruby :

PRIVATE_NET="192.168.99."
VAULT_ID="prov"

#servers=[
#  {
#    :hostname => "vm-gitlab",
#    :ip => PRIVATE_NET + "101",
#    :ram => "4096",
#    :cpu => "2",
#    :group => "gitservers"
#  },
#  {
#    :hostname => "vm-jenkins",
#    :ip => PRIVATE_NET + "102",
#    :ram => "1024",
#    :cpu => "1",
#    :group => "ciservers"
#  },
#  {
#    :hostname => "vm-testbox",
#    :ip => PRIVATE_NET + "103",
#    :ram => "1024",
#    :cpu => "1",
#    :group => "testweb"
#  }
#]

servers=[
  {
    :hostname => "vm-jenkins",
    :ip => PRIVATE_NET + "102",
    :ram => "1024",
    :cpu => "1",
    :group => "ciservers"
  }
]

#servers=[
#  {
#    :hostname => "vm-gitlab",
#    :ip => PRIVATE_NET + "101",
#    :ram => "4096",
#    :cpu => "2",
#    :group => "gitservers"
# },
#  {
#    :hostname => "vm-jenkins",
#    :ip => PRIVATE_NET + "102",
#    :ram => "1024",
#    :cpu => "1",
#    :group => "ciservers"
#  }
#]

#servers=[
#  {
#    :hostname => "vm-jenkins",
#    :ip => PRIVATE_NET + "102",
#    :ram => "1024",
#    :cpu => "1",
#    :group => "ciservers"
#  },
#  {
#    :hostname => "vm-testbox",
#    :ip => PRIVATE_NET + "103",
#    :ram => "1024",
#    :cpu => "1",
#    :group => "testweb"
#  }
#]

Vagrant.configure("2") do |config|
  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|

      node.vm.box = "centos/7"
      node.vm.box_check_update = false
      node.vm.hostname = machine[:hostname]

      node.vm.network :private_network,
        :ip => machine[:ip]


      node.vm.provider "libvirt" do |lv|
        lv.memory = machine[:ram]
        lv.cpus = machine[:cpu]
      end

# For authorized_keys ansible module working with delegate_to
      node.ssh.insert_key = false

      node.vm.provision "ansible" do |ansible|
#        ansible.verbose = "v"
        ansible.compatibility_mode = "auto"
        ansible.playbook = "playbooks/prov/" + machine[:group] + ".yml"
        ansible.become = true
        ansible.inventory_path = "playbooks/prov/hosts"
        ansible.raw_arguments = ["--vault-id", "/home/ansible/.vault_pass/" + VAULT_ID + "_pass"]
      end
    end
  end
end