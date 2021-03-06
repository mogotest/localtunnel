require 'rubygems'
require 'net/ssh'
require 'net/ssh/gateway'
require 'net/http'
require 'uri'
require 'json'

require 'localtunnel/net_ssh_gateway_patch'

module LocalTunnel; end

class LocalTunnel::Tunnel

  attr_accessor :tunnel_host, :reflected_host, :reflected_port, :key, :host

  def initialize(tunnel_host, reflected_host, reflected_port, key)
    @tunnel_host = tunnel_host
    @reflected_host = reflected_host
    @reflected_port = reflected_port
    @key  = key
    @host = ""
  end

  def register_tunnel(key=@key)
    url = URI.parse("http://#{tunnel_host}/")
    if key
      resp = JSON.parse(Net::HTTP.post_form(url, {"key" => key}).body)
    else
      resp = JSON.parse(Net::HTTP.get(url))
    end
    if resp.has_key? 'error'
      puts "   [Error] #{resp['error']}"
      exit
    end
    @ssh_host = resp['host'].split(':').first
    @tunnel = resp
    return resp
  rescue
    puts "   [Error] Unable to register tunnel. Perhaps service is down?"
    exit
  end

  def start_tunnel(mogotest)
    tunnel = @tunnel
    gateway = Net::SSH::Gateway.new(@ssh_host, tunnel['user'])
    gateway.open_remote(reflected_port.to_i, reflected_host, tunnel['through_port'].to_i) do |rp,rh|
      puts "   You're good to go. Any tests you run against '#{mogotest.test_host}' on Mogotest will now access the site running on #{reflected_host}:#{reflected_port}."
      begin
        sleep 1 while true
      rescue Interrupt
        gateway.close_remote(rp, rh)
      end
    end
  rescue Net::SSH::AuthenticationFailed
    possible_key = Dir[File.expand_path('~/.ssh/*.pub')].first
    puts "   Failed to authenticate. If this is your first tunnel, you need to"
    puts "   upload a public key using the -k option. Try this:\n\n"
    puts "   mogotest -k #{possible_key ? possible_key : '~/path/to/key'} #{mogotest.api_key} #{mogotest.test_host} #{port}"
    exit
  end
end
