require 'rspec'
require 'webmock/rspec'

Dir['spec/supports/**/*.rb'].each { |f| require File.expand_path(f) }

require 'carrierwave'
require 'carrierwave/webdav'

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end

RSpec.configure do |config|
  WebMock.disable_net_connect!
  config.include Helpers
end
