
desc "clean up"
task :clean do
  sh "gem cleanup gitstrider --verbose"
  sh "gem uninstall gitstrider"
end

desc "build gitstrider gem"
task :build do
  sh "gem build gitstrider.gemspec"
end

desc "install"
task :install => [:clean]
task :install => [:build]
task :install do |t, args|
  sh "gem install gitstrider-*.gem"
end