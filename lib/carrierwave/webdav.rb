require 'carrierwave'
require 'carrierwave/store/webdav'

CarrierWave::Storage.autoload :WebDAV, 'carrierwave/store/webdav'

class CarrierWave::Uploader::Base
  add_config :webdav_username
  add_config :webdav_password
  add_config :webdav_server

  configure do |config|
    config.storage_engines[:webdav] = 'CarrierWave::Storage::WebDAV'
  end
end

