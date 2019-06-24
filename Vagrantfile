Vagrant.configure(2) do |config|
	config.vm.define "minikubebox" do |devbox|
		devbox.vm.box = "ubuntu/xenial64"
    		#devbox.vm.network "private_network", ip: "192.168.199.9"
	        devbox.vm.hostname = "minikubebox"
		devbox.vm.provision "shell", path: "scripts/install.sh"
    		devbox.vm.provider "virtualbox" do |v|
    		  v.memory = 4096
    		  v.cpus = 2
    		end
	end
end
