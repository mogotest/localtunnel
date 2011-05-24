require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('mogotest', '0.9.1') do |p|
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

task :build_jar do
  dist_dir = File.join('.', 'dist')
  unless File.directory?(dist_dir)
    FileUtils.mkdir_p(dist_dir)
  end

  FileUtils.cd(dist_dir) do
    jruby_version = '1.6.1'

    unless File.exists?("jruby-complete-#{jruby_version}.jar")
      system("wget http://jruby.org.s3.amazonaws.com/downloads/#{jruby_version}/jruby-complete-#{jruby_version}.jar")
    end

    # We're going to modify the JRuby JAR in-place, so make a copy to our final JAR name.
    FileUtils.copy_file("jruby-complete-#{jruby_version}.jar", 'mogotest.jar')

    # Copy over dependencies.
    dependencies = %w[json net-ssh net-ssh-gateway rest-client mogotest]
    dependencies.each do |dependency|
      #system("gem fetch #{dependency}")
      system("gem unpack #{dependency}")
      system("jar -uf mogotest.jar #{dependency}-*/lib/*")
    end

    # Add our bootstrap file to start executing as the main class.
    FileUtils.copy_file(File.join('..', 'bin', 'mogotest'), 'jar-bootstrap.rb')
    system('jar -ufe mogotest.jar org.jruby.JarBootstrapMain jar-bootstrap.rb')
  end
end