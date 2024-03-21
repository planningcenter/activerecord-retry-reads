$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require_relative 'lib/activerecord-retry-reads/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'activerecord-retry-reads'
  s.version     = ActiverecordRetryReads::VERSION
  s.authors     = ['ben@planningcenter.com']
  s.email       = ['ben@planningcenter.com']
  s.homepage    = 'https://github.com/planningcenter/activerecord-retry-reads'
  s.description = 'Retry read queries automatically when disconnected from the database'
  s.summary     = s.description
  s.files       = Dir['{lib}/**/*', 'README.md']
  s.test_files  = Dir['spec/**/*']
  s.license     = "MIT"

  s.add_dependency 'rails', '>= 7.1.0'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'rake'
end
