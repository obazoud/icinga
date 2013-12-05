# encoding: utf-8
require 'ipaddr'

def is_private_ip(given_ip)
  found = false
  ip = IPAddr.new(given_ip)
  private_nets = ['192.168.0.0/16',
                  '172.16.0.0/12',
                  '10.0.0.0/8'].map { |ip_str| IPAddr.new(ip_str) }
  private_nets.each do |net|
    found = true if net.include?(ip)
  end

  return found
end

def private_addresse_for_node(node_def)
  local_addresses = []
  return local_addresses if node_def['network'].nil? # node may have no ohai data yet
  return node_def['network']['interfaces']['eth0']['addresses'].keys[0] if is_private_ip(node_def['network']['interfaces']['eth0']['addresses'].keys[0])

  node_def['network']['interfaces'].each_pair do |ifname, ifdata|
    ifdata['addresses'].nil? && next
    ifdata['addresses'].keys.each do |ip_str|
      begin
        return ip_str if is_private_ip(ip_str)
      rescue ArgumentError
        nil # not all addresses are IP; ignore exceptions
      end
    end
  end
  nil
end
