$:.push File.expand_path('../lib', __FILE__)
require 'gitstrider/version'

Gem::Specification.new do |spec|
  spec.name        = 'gitstrider'
  spec.version     = GitStrider::VERSION
  spec.authors     = ["Hadi Badjian"]
  spec.email       = ['hadi at hadibadjian me']
  spec.homepage    = 'https://github.com/hadibadjian/git_strider'
  spec.license     = 'MIT'
  spec.description = %Q{Git contribution report}
  spec.summary     = spec.description
  spec.files       = `git ls-files lib`.split("\n")
  spec.require_paths = ['lib']

  spec.add_dependency 'parallel'

  spec.required_ruby_version = '>= 1.9'
end