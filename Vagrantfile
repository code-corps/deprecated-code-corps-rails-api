# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.5"

def require_plugins(plugins = {})
  needs_restart = false
  plugins.each do |plugin, version|
    next if Vagrant.has_plugin?(plugin)
    cmd =
      [
        "vagrant plugin install",
        plugin
      ]
    cmd << "--plugin-version #{version}" if version
    system(cmd.join(" ")) || exit!
    needs_restart = true
  end
  exit system("vagrant", *ARGV) if needs_restart
end

require_plugins \
  "vagrant-bindfs" => "0.3.2",
  "vagrant-hostmanager" => "1.8.2"

def ansible_installed?
  exts = ENV["PATHEXT"] ? ENV["PATHEXT"].split(";") : [""]
  ENV["PATH"].split(File::PATH_SEPARATOR).any? do |p|
    exts.any? do |ext|
      full_path = File.join(p, "ansible-playbook#{ext}")
      File.executable?(full_path) && File.file?(full_path)
    end
  end
end

Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |vb|
    host = RbConfig::CONFIG["host_os"]

    if host =~ /darwin/ # OS X
      # sysctl returns bytes, convert to MB
      vb.memory = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 3
      vb.cpus = `sysctl -n hw.ncpu`.to_i
    elsif host =~ /linux/ # Linux
      # meminfo returns kilobytes, convert to MB
      memtotal = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i
      vb.memory = memtotal / 1024 / 2
      vb.cpus = `nproc`.to_i
    end

    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  if Vagrant.has_plugin? "vagrant-hostmanager"
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.aliases = %w(api.codecorps.dev codecorps.dev www.codecorps.dev)
  else
    fail_with_message "vagrant-hostmanager missing"
  end

  config.vm.define "code-corps-api" do |machine|
    machine.vm.box = "ubuntu/trusty64"

    machine.vm.hostname = "localhost"

    machine.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
    machine.vm.network "forwarded_port", guest: 443, host: 8081, auto_correct: true
    machine.vm.network "forwarded_port", guest: 5000, host: 5000, auto_correct: true
    machine.vm.network "forwarded_port", guest: 6379, host: 6379, auto_correct: true
    machine.vm.network "private_network", ip: "192.168.20.50"

    mount_options = ["rw", "vers=3", "tcp", "fsc", "actimeo=2"]

    machine.vm.synced_folder ".",
                             "/code-corps-api",
                             type: "nfs",
                             mount_options: mount_options
    machine.bindfs.bind_folder "/code-corps-api", "/code-corps-api"
  end

  config.ssh.forward_agent = true

  if ansible_installed?
    config.vm.provision :hostmanager

    config.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/site.yml"
      ansible.sudo = true
      ansible.groups = {
        "application" => %w(code-corps-api),
        "vm" => %w(code-corps-api),
        "postgresql" => %w(code-corps-api),
        "elasticsearch" => %w(code-corps-api),
        "sidekiq" => %w(code-corps-api),
        "foreman" => %w(code-corps-api),
        "development:children" => %w(application vm postgresql elasticsearch sidekiq foreman),
      }
      ansible.tags = ENV["TAGS"]
      ansible.raw_arguments = ENV["ANSIBLE_ARGS"]
    end
  else
    Dir["shell/*.sh"].each do |script|
      config.vm.provision "shell", path: script, privileged: false, args: ENV["ANSIBLE_ARGS"]
    end
  end
end
