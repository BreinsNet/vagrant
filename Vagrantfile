# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'pp'

# Make sure we are at the root Vagrantfile directory path
while not File.exists? "Vagrantfile"
  Dir.chdir '../'
end

# Create dirs:
FileUtils.mkdir 'config' if not File.exists? 'config'
FileUtils.mkdir 'logs' if not File.exists? 'logs'
FileUtils.mkdir 'manifests' if not File.exists? 'manifests'
FileUtils.touch 'manifests/default.pp' if not File.exists? 'manifests/default.pp'

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

# Add the provisioner argument based con config file:
if ARGV[0] == 'up' && ARGV[1].nil? && settings['bootstrap']['provider'] != 'virtualbox'
  ENV['VAGRANT_DEFAULT_PROVIDER'] = settings['bootstrap']['provider']
end

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # General VM config
  config.vm.hostname  = settings['fqdn'].split('.').first
  config.ssh.forward_agent = true

  # Vagrant configuration
  case settings['bootstrap']['provider']
  when 'virtualbox'
    config.vm.box = settings['provider']['virtualbox']['box']
    config.vm.network "private_network", ip: settings['provider']['virtualbox']['ipaddress']
    config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
    config.vm.network "forwarded_port", guest: 443, host: 8443, auto_correct: true
    config.vm.provider "virtualbox" do |v|
      v.name = settings['fqdn']
      v.customize ["modifyvm", :id, "--ioapic", "on"]
      v.customize ["modifyvm", :id, "--memory", settings['provider']['virtualbox']['memory']]
      v.customize ["modifyvm", :id, "--cpus", settings['provider']['virtualbox']['cpu']]
    end
  when 'digital_ocean'
    digital_ocean = settings['provider']['digital_ocean']
    config.vm.provider :digital_ocean do |provider, override|
      override.vm.box = 'digital_ocean'
      override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
      override.ssh.private_key_path = '~/.ssh/id_rsa'
      provider.client_id = digital_ocean['client_id']
      provider.api_key = digital_ocean['api_key']
      provider.image = digital_ocean['image']
      provider.size = digital_ocean['size']
      provider.region = digital_ocean['region']
      provider.ssh_key_name = digital_ocean['ssh_key_name']
      provider.private_networking = digital_ocean['private_networking']
    end
  when 'aws'
    aws = settings['provider']['aws']
    config.vm.provider :aws do |provider, override|
      provider.access_key_id = aws['access_key_id']
      provider.secret_access_key = aws['secret_access_key']
      provider.keypair_name = aws['keypair_name']
      provider.ami = aws['ami']
      provider.tags = [config.vm.hostname.split('.').first]
      provider.region = aws['region']
      provider.availability_zone = aws['availability_zone']
      provider.instance_type = aws['instance_type']
      provider.security_groups = aws['security_groups']
      provider.block_device_mapping = [ { :DeviceName => "/dev/sda1", 'Ebs.VolumeSize' => aws['ebs_size'] } ]
      override.vm.box = "aws"
      override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
      override.ssh.username = "ubuntu"
      override.ssh.private_key_path = aws['private_key_path']
    end
  end


  # BASE bootsrap script
  config.vm.provision "shell" do |s|
    s.path = File.join(release_script_path,'base.sh')
    s.args = settings['puppet']['version'] + ' ' + settings['fqdn']
  end if settings['bootstrap']['base']

  # PUPPET Bootstrap script:
  config.vm.provision "shell" do |s|
    s.path = File.join(common_script_path,'puppet.sh')
    s.args = settings['puppet']['hiera_repo']
  end if settings['puppet']['masterless']

  # PUPPET apply run using run_puppet.sh wrapper
  if settings['puppet']['masterless']
    content = File.open('templates/default.pp').read
    content.gsub!(/SYSTEM_ROLE/,settings['puppet']['system_role'])
    content.gsub!(/SYSTEM_ENV/,settings['puppet']['system_env'])
    File.open('manifests/default.pp','w').puts content
    config.vm.provision "shell" do |s|
      s.path = File.join(common_script_path,'run_puppet_apply.sh')
      s.args = settings['puppet']['environment']
    end
  end

  # PUPPET agent run using run_puppet.sh wrapper
  if ! settings['puppet']['masterless']
    config.vm.provision "shell" do |s|
      s.path = File.join(common_script_path,'run_puppet_agent.sh')
      s.args = [settings['puppet']['server'],settings['puppet']['environment']]
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

  # Remove all the vagrant files unless if virtualbox:
  config.vm.provision 'shell' do |s|
    s.inline = 'cp /vagrant/bootstrap/common/run_puppet_apply.sh /usr/bin'
  end if settings['puppet']['masterless']

  # Remove all the vagrant files unless if virtualbox:
  config.vm.provision 'shell' do |s|
    s.inline = 'rm -rf /vagrant'
  end unless settings['bootstrap']['provider'] == 'virtualbox'

end

