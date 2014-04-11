Gem::Specification.new do |spec|
  spec.name        = 'git_strider'
  spec.version     = '0.0.1'
  spec.date        = '2014-04-10'
  spec.summary     = "Stride the app!"
  spec.description = "A simple hello world gem"
  spec.authors     = ["Hadi Badjian"]
  spec.email       = 'hadi@hadibadjian.me'
  spec.files       = ["lib/git_strider.rb", "lib/html_composer.rb", "lib/json_composer.rb"]
  spec.homepage    = 'http://rubygems.org/gems/git_strider'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 1.9'

  spec.post_install_message = "Thanks for installing!"

  spec.add_runtime_dependency 'parallel'
  spec.add_runtime_dependency 'colorize'
end