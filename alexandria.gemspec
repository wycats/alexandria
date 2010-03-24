Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'alexandria'
  s.version     = '0.5'
  s.summary     = 'Tools for working with Google Data'
  s.description = 'The core utilities for working with the Google Data API'
  s.required_ruby_version = '>= 1.8.6'

  s.author            = 'Yehuda Katz'
  s.email             = 'wycats@gmail.com'
  s.homepage          = 'http://www.yehudakatz.com'
  s.rubyforge_project = 'alexandria'

  s.files              = Dir['README.markdown', 'LICENSE', 'lib/**/{*,.[a-z]*}']
  s.require_path       = 'lib'

  s.rdoc_options << '--exclude' << '.'
  s.has_rdoc = false

  require "bundler"

  Bundler.definition.dependencies.select {|d| d.groups.include?(:default) }.each do |d|
    s.add_dependency d.name, d.requirement.to_s
  end
end
