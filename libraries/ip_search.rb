# encoding: utf-8
# rubocop:disable CyclomaticComplexity
require 'ipaddr'

def private_ip?(given_ip)
  found = false
  begin
    ip = IPAddr.new(given_ip)
  rescue ArgumentError
    found
  end
  private_nets = ['192.168.0.0/16',
                  '172.16.0.0/12',
                  '10.0.0.0/8'].map { |ip_str| IPAddr.new(ip_str) }
  private_nets.each do |net|
    found = true if net.include?(ip)
  end

  found
end

def private_addresse_for_node(node_def)
  local_addresses = []
  return local_addresses if node_def['network'].nil? # node may have no ohai data yet

  if node_def['platform_family'] == 'debian'
    node_def['network']['interfaces']['eth0']['addresses'].each do |addr, addrdata|
      return addr if private_ip?(addr) if addrdata.family == 'inet'
    end
  end

  node_def['network']['interfaces'].each_pair do |ifname, ifdata|
    ifdata['addresses'].nil? && next
    ifdata['addresses'].keys.each do |ip_str|
      return ip_str if private_ip?(ip_str)
    end
  end
  nil
end
