require 'net/http'
require 'uri'

node.reverse_merge!({
  password: 'ubuntu',
  vmx_root: '/',
  source_vmdk_path: '',
  ip_prefix: '127.0.0',
  gateway: "127.0.0.254",
  restore: false,
  instance: {
    cpu: 1,
    mhz: 2560,
    mem: 4096,
    hdd: "8g",
  },
  admins: [],
})

ssh_keys = node[:admins].map do |username|
  Net::HTTP.get(URI.parse("https://github.com/#{username}.keys")).strip.split("\n").map(&:strip)
end.flatten

module VMHelper
  def vms
    node[:machines].map { |vm| [vm[:name], vm] }.to_h
  end

  def get_vm_id(name)
    vms[name][:id] || begin
      id = run_command(get_vm_id_cmd(name)).stdout.strip
      id.empty? ? nil : id
    end
  end

  def get_vm_id_cmd(name)
    "vim-cmd vmsvc/getallvms | grep '#{name}' | cut -d' ' -f1"
  end

  def parse_vmx(vmx)
    vmx.lines.map do |line|
      key, val = *line.strip.split(' = ')
      next if line.strip == '"'
      [key, val.delete_suffix('"').delete_prefix('"')]
    end.reject(&:nil?).to_h
  end
end

Itamae::Recipe::EvalContext.include(VMHelper)
Itamae::Resource::Base::EvalContext.include(VMHelper)


node[:machines].each do |machine|
  execute "Reload: #{machine[:name]}" do
    command "vim-cmd vmsvc/reload #{get_vm_id(machine[:name])}"
    action :nothing
  end

  vm_dir = "#{node[:vmx_root]}/#{machine[:name]}"
  vmx = "#{vm_dir}/#{machine[:name]}.vmx"
  vm_data = {}
  run_command("cat #{vmx} | sort").stdout.strip.split("\n").each do |line|
    parts = line.split(' = ')
    key = parts.shift
    val = parts.join(' = ').gsub(/^"|"$/, '')
    vm_data[key] = val
  end
  vm_ip = "#{node[:ip_prefix]}.#{machine[:name].sub(/^[a-z0-9]+-/, '').to_i + 10}"

  vm_data['guestOS'] = 'ubuntu-64'
  vm_data['numvcpus'] = node[:instance][:cpu]
  vm_data['sched.cpu.shares'] = node[:instance][:mhz]
  vm_data['sched.cpu.max'] = node[:instance][:mhz]
  vm_data['sched.cpu.min'] = 0
  vm_data['sched.cpu.units'] = 'mhz'
  vm_data['memSize'] = node[:instance][:mem]
  vm_data['ethernet0.addressType'] = "generated"
  vm_data['ethernet0.generatedAddress'] = "00:0c:29:4d:08:7f"
  vm_data['ethernet0.generatedAddressOffset'] = "0"
  vm_data['ethernet0.networkName'] = "VM-v4002"
  vm_data['ethernet0.pciSlotNumber'] = "160"
  vm_data['ethernet0.present'] = "TRUE"
  vm_data['ethernet0.uptCompatibility'] = "TRUE"
  vm_data['ethernet0.virtualDev'] = "vmxnet3"
  vm_data['ethernet0.wakeOnPcktRcv'] = "FALSE"

  if node[:restore]
    vm_data['ide1:0.deviceType'] = 'cdrom-image'
    vm_data['ide1:0.fileName'] = './cloud-init.iso'
    vm_data['ide1:0.present'] = 'TRUE'
  else
    vm_data.keys.each do |key|
      # vm_data.delete(key) if key.start_with?('ide1:')
    end
  end

  execute "Restore VMDK: #{machine[:name]}" do
    command <<-EOS
    rm #{vm_dir}/#{machine[:name]}*.vmdk
    vmkfstools -i #{node[:source_vmdk_path]} #{vm_dir}/#{machine[:name]}.vmdk
    vmkfstools -X #{node[:instance][:hdd]} #{vm_dir}/#{machine[:name]}.vmdk
    EOS

    notifies :run, "execute[Reload: #{machine[:name]}]"
  end if node[:restore]

  file "#{vm_dir}/user-data" do
    content <<-EOS.rstrip + "\n"
#cloud-config
user: isuadmin
password: #{node[:password]}
chpasswd: {expire: False}
ssh_pwauth: False
ssh_authorized_keys:
#{ssh_keys.sort.map {|key| "  - #{key}" }.join("\n")}
    EOS

    notifies :run, "execute[Cloud Init: #{machine[:name]}]"
  end

  file "#{vm_dir}/meta-data" do
    content <<-EOS.rstrip + "\n"
instance-id: #{machine[:name]}
local-hostname: #{machine[:name]}
network-interfaces: |
  auto ens160
  iface ens160 inet static
  address #{vm_ip}
  gateway #{node[:gateway]}
  dns-nameservers 8.8.8.8 8.8.4.4
    EOS

    notifies :run, "execute[Cloud Init: #{machine[:name]}]"
  end

  execute "Cloud Init: #{machine[:name]}" do
    action :nothing

    command <<-EOS
      genisoimage -output cloud-init.iso -volid cidata -joliet -rock user-data meta-data
    EOS
    cwd vm_dir

    notifies :run, "execute[Reload: #{machine[:name]}]"
  end

  file vmx do
    content vm_data.keys.sort.map { |k| %{#{k} = "#{vm_data[k]}"} }.join("\n") + "\n"

    notifies :run, "execute[Reload: #{machine[:name]}]"
  end
end
