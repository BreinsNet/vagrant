# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'pp'

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

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
  release_script_path = File.join('bootstrap',settings['distribution'],settings['release'])
  common_script_path = File.join('bootstrap','common')

  # Vagrant configuration
  config.vm.hostname  = settings['fqdn']
  config.vm.box = settings['vagrant']['box']
  config.vm.network "private_network", ip: settings['ipaddress']
  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
  config.vm.network "forwarded_port", guest: 443, host: 8443, auto_correct: true
  config.ssh.forward_agent = true

  # VM Configuration
  config.vm.provider "virtualbox" do |v|
    v.name = settings['fqdn']
    v.customize ["modifyvm", :id, "--ioapic", "on"]
    v.customize ["modifyvm", :id, "--memory", settings['vagrant']['memory']]
    v.customize ["modifyvm", :id, "--cpus", settings['vagrant']['cpu']]
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
  end if settings['puppet']['bootstrap']

  # PUPPET apply run using run_puppet.sh wrapper
  if settings['run_puppet_apply']

    content = File.open('templates/default.pp').read
    content.gsub!(/SYSTEM_ROLE/,settings['puppet']['system_role'])
    content.gsub!(/SYSTEM_ENV/,settings['puppet']['system_env'])
    File.open('manifests/default.pp','w').puts content

    config.vm.provision "shell" do |s|
      s.path = File.join(common_script_path,'run_puppet.sh')
      s.args = 'apply'
    end

  end

  # Deploy some script helpers
  if settings['deploy_tools']
    config.vm.provision "shell" do |s|
      s.path = File.join(common_script_path,'deploy_tools.sh')
    end
  end

  # PUPPET agent run using run_puppet.sh wrapper
  if settings['run_puppet_agent']
    config.vm.provision "shell" do |s|
      s.path = File.join(common_script_path,'run_puppet.sh')
      s.args = ['agent',settings['puppet']['puppetmaster']]
    end
  end

  # CLEAN UP bootsrap script
  config.vm.provision "shell" do |s|
    s.path = File.join(release_script_path,'cleanup.sh')
    s.args = settings['puppet']['version']
  end

end

