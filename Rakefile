require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('mogotest', '0.10.0') do |p|
  p.description    = "Test your local Web servers on Mogotest without poking a hole in your firewall."
  p.url            = "http://mogotest.com"
  p.author         = "Jeff Lindsay"
  p.email          = "kevin@mogotest.com [Please don't bother Jeff]"
  p.has_rdoc       = false
  p.rdoc_pattern   = //
  p.rdoc_options   = []
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.executable_pattern = ["bin/*"]
  p.runtime_dependencies = ["json >=1.2.4", "net-ssh >=2.0.22", "net-ssh-gateway >=1.0.1", "rest-client >=1.6.1"]
  p.development_dependencies = []
end
