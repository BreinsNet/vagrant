# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'pp'

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Make sure we are at the root Vagrantfile directory path
  while not File.exists? "Vagrantfile"
    Dir.chdir '../'
  end

  # Create dirs:
  FileUtils.mkdir 'config' if not File.exists? 'config'
  FileUtils.mkdir 'logs' if not File.exists? 'logs'

  # Load settings
  settings = nil
  config_file = File.join('config','vagrant.yaml')
  begin
    raise "vagrant.yaml not exists" if not File.exists? config_file
    settings = YAML::load(File.open(config_file).read)
  rescue => e
    puts "error: Could not load settings"
    puts e
    exit 1
  end
  release_script_path = File.join('bootstrap',settings['bootstrap']['distribution'],settings['bootstrap']['release'])
  common_script_path = File.join('bootstrap','common')

  # General VM config
  config.vm.hostname  = settings['fqdn']
  config.ssh.forward_agent = true

  # Vagrant configuration
  case settings['provision'].keys.first
  when 'virtualbox'
    config.vm.box = settings['provision']['virtualbox']['box']
    config.vm.network "private_network", ip: settings['provision']['virtualbox']['ipaddress']
    config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
    config.vm.network "forwarded_port", guest: 443, host: 8443, auto_correct: true
    config.vm.provider "virtualbox" do |v|
      v.name = settings['fqdn']
      v.customize ["modifyvm", :id, "--ioapic", "on"]
      v.customize ["modifyvm", :id, "--memory", settings['provision']['virtualbox']['memory']]
      v.customize ["modifyvm", :id, "--cpus", settings['provision']['virtualbox']['cpu']]
    end
  when 'digitalocean'
    config.vm.hostname  = settings['fqdn'].split('.').first
    digitalocean = settings['provision']['digitalocean']
    config.vm.provider :digital_ocean do |provider, override|
      override.vm.box = 'digital_ocean'
      override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
      override.ssh.private_key_path = '~/.ssh/id_rsa'
      provider.client_id = digitalocean['client_id']
      provider.api_key = digitalocean['api_key']
      provider.image = digitalocean['image']
      provider.size = digitalocean['size']
      provider.region = digitalocean['region']
      provider.ssh_key_name = digitalocean['ssh_key_name']
      provider.private_networking = digitalocean['private_networking']
    end
  end


  # BASE bootsrap script
  config.vm.provision "shell" do |s|
    s.path = File.join(release_script_path,'base.sh')
    s.args = settings['puppet']['version'] + ' ' + settings['fqdn']
  end

  # PUPPET Bootstrap script:
  config.vm.provision "shell" do |s|
    s.path = File.join(common_script_path,'puppet.sh')
    s.args = settings['puppet']['hiera_repo']
  end if settings['bootstrap']['puppet_masterless']

  # PUPPET apply run using run_puppet.sh wrapper
  if settings['bootstrap']['puppet_run_apply']

    content = File.open('templates/default.pp').read
    content.gsub!(/SYSTEM_ROLE/,settings['puppet']['system_role'])
    content.gsub!(/SYSTEM_ENV/,settings['puppet']['system_env'])
    File.open('manifests/default.pp','w').puts content

    config.vm.provision "shell" do |s|
      s.path = File.join(common_script_path,'run_puppet.sh')
      s.args = 'apply'
    end

  end

  # PUPPET agent run using run_puppet.sh wrapper
  if settings['bootstrap']['puppet_run_agent']
    config.vm.provision "shell" do |s|
      s.path = File.join(common_script_path,'run_puppet.sh')
      s.args = ['agent',settings['bootstrap']['puppet_server']]
    end
  end

  # Deploy some script helpers
  config.vm.provision "shell" do |s|
    s.path = File.join(common_script_path,'deploy_tools.sh')
  end

  # CLEAN UP bootsrap script
  config.vm.provision "shell" do |s|
    s.path = File.join(release_script_path,'cleanup.sh')
    s.args = settings['puppet']['version']
  end

end

