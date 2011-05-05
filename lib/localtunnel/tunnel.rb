require 'rubygems'
require 'net/ssh'
require 'net/ssh/gateway'
require 'net/http'
require 'uri'
require 'json'
require 'rest-client'

require 'localtunnel/net_ssh_gateway_patch'

module LocalTunnel; end

class LocalTunnel::Tunnel

  attr_accessor :tunnel_host, :api_key, :test_host, :port, :key, :host

  def initialize(tunnel_host, api_key, test_host, port, key)
    @tunnel_host = tunnel_host
    @test_host = test_host
    @port = port
    @key  = key
    @host = ""
  end

  def register_tunnel(key=@key)
    url = URI.parse("http://open.localtunnel.com/")
    if key
      resp = JSON.parse(Net::HTTP.post_form(url, {"key" => key}).body)
    else
      resp = JSON.parse(Net::HTTP.get(url))
    end
    if resp.has_key? 'error'
      puts "   [Error] #{resp['error']}"
      exit
    end
    @host = resp['host'].split(':').first
    @tunnel = resp
    return resp
  rescue
    puts "   [Error] Unable to register tunnel. Perhaps service is down?"
    exit
  end

  def start_tunnel
    port = @port
    tunnel = @tunnel
    gateway = Net::SSH::Gateway.new(@host, tunnel['user'])
    gateway.open_remote(port.to_i, '127.0.0.1', tunnel['through_port'].to_i) do |rp,rh|
      puts "   " << tunnel['banner'] if tunnel.has_key? 'banner'
      puts "   You're good to go. Any tests you run against '#{@test_host}' on Mogotest will now access your local server on port #{port}."
      begin
        sleep 1 while true
      rescue Interrupt
        gateway.close_remote(rp, rh)
        exit
      end
    end
  rescue Net::SSH::AuthenticationFailed
    possible_key = Dir[File.expand_path('~/.ssh/*.pub')].first
    puts "   Failed to authenticate. If this is your first tunnel, you need to"
    puts "   upload a public key using the -k option. Try this:\n\n"
    puts "   mogotest -k #{possible_key ? possible_key : '~/path/to/key'} #{@api_key} #{@test_host} #{port}"
    exit
  end

  def notify_mogotest_of_tunnel
    RestClient.post "https://#{@api_host}/api/v1/ssh_tunnels", { :user_credentials => @api_key, :hostname => @test_host, :tunnel_url => @tunnel['host'] }
  rescue
    puts "   [Error] Unable to register tunnel location with Mogotest API.  Perhaps your credentials are bad."
    exit
  end

  def teardown_tunnel_in_mogotest
    RestClient.post "https://#{@api_host}/api/v1/ssh_tunnels/destroy", { :user_credentials => @api_key, :hostname => @test_host }
  rescue
    puts "   [Error] Unable to delete tunnel location from Mogotest API.  Perhaps your credentials are bad."
    exit
  end
end
