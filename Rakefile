
desc "clean up"
task :clean do
  sh "gem cleanup clog --verbose"
  sh "gem uninstall clog"
end

desc "build clog gem"
task :build do
  sh "gem build clog.gemspec"
end

desc "install"
task :install, [:version] do |t, args|
  sh "gem install clog-#{args.version}.gem"
end