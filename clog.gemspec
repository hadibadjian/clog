Gem::Specification.new do |spec|
  spec.name        = 'clog'
  spec.version     = '0.0.1'
  spec.date        = '2014-04-10'
  spec.summary     = "CLog the app!"
  spec.description = "A simple hello world gem"
  spec.authors     = ["Hadi Badjian"]
  spec.email       = 'hadi@hadibadjian.me'
  spec.files       = ["lib/clog.rb"]
  spec.homepage    = 'http://rubygems.org/gems/clog'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 1.9'

  spec.post_install_message = "Thanks for installing!"

  spec.add_runtime_dependency 'work_queue'
  spec.add_runtime_dependency 'colorize'
end