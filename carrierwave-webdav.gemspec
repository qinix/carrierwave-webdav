# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carrierwave/webdav/version'

Gem::Specification.new do |gem|
  gem.name          = "carrierwave-webdav"
  gem.version       = Carrierwave::WebDAV::VERSION
  gem.authors       = ["Qinix"]
  gem.email         = ["i@qinix.com"]
  gem.description   = %q{WebDAV support for CarrierWave}
  gem.summary       = %q{WebDAV support for CarrierWave}
  gem.homepage      = "https://github.com/qinix/carrierwave-webdav"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'carrierwave'
  gem.add_dependency 'httparty'

end
