$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "hashids_activerecord/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hashids_activerecord"
  s.version     = HashidsActiverecord::VERSION
  s.authors     = ["sajan"]
  s.email       = ["sajan.sahoo@gmail.com"]
  s.homepage    = "https://github.com/sajan45/hashids_activerecord"
  s.summary     = "Use hashids.rb to obfuscate the ActiveRecord ID and save it to the table as the specified attribute and also uses it in URL."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4.2.5"
  s.add_dependency "hashids"

  s.add_development_dependency "sqlite3"
end
