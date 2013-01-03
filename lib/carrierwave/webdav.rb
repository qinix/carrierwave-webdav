require 'carrierwave'
require 'carrierwave/storage/webdav'

CarrierWave::Storage.autoload :WebDAV, 'carrierwave/storage/webdav'

class CarrierWave::Uploader::Base
  add_config :webdav_username
  add_config :webdav_password
  add_config :webdav_server

  configure do |config|
    config.storage_engines[:webdav] = 'CarrierWave::Storage::WebDAV'
  end
end

