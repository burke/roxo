Gem::Specification.new do |gem|
  gem.name    = 'roxo'
  gem.version = "0.0.1"

  gem.author, gem.email = 'Burke Libbey', "burke@burkelibbey.org"

  gem.summary     = "A simpler way to interact with XML in Ruby"
  gem.description = "ROXO is a simple library for dealing with small XML documents with a nice API."

  gem.required_ruby_version = '>= 1.8.7'

  gem.add_dependency("libxml-ruby")
  gem.add_dependency("active_support")
  
  gem.has_rdoc = false

  gem.files = %w[
    MIT-LICENSE
    lib
    lib/roxo.rb
    roxo.gemspec
  ]
end
