require 'rest-client'

require 'localtunnel/tunnel'

module Mogotest; end

class Mogotest::Tunnel
  attr_accessor :api_host, :api_key, :test_host, :tunnel_url

  def initialize(api_host, api_key, test_host, tunnel_url)
    @api_host = api_host
    @api_key = api_key
    @test_host = test_host
    @tunnel_url = tunnel_url
  end

  def notify_mogotest_of_tunnel
    RestClient.post "https://#{api_host}/api/v1/ssh_tunnels", { :user_credentials => api_key, :hostname => test_host, :tunnel_url => tunnel_url }
  rescue
    puts "   [Error] Unable to register tunnel location with Mogotest API.  Perhaps your credentials are bad."
    exit
  end

  def teardown_tunnel_in_mogotest
    RestClient.post "https://#{api_host}/api/v1/ssh_tunnels/destroy", { :user_credentials => api_key, :hostname => test_host }
  rescue
    puts "   [Error] Unable to delete tunnel location from Mogotest API.  Perhaps your credentials are bad."
    exit
  end
end