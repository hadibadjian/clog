
desc "clean up"
task :clean do
  sh "gem cleanup git_strider --verbose"
  sh "gem uninstall git_strider"
end

desc "build git_strider gem"
task :build do
  sh "gem build git_strider.gemspec"
end

desc "install"
task :install => [:clean]
task :install => [:build]
task :install, [:version] do |t, args|
  sh "gem install git_strider-#{args.version}.gem"
end