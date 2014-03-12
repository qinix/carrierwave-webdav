require 'carrierwave'
require 'carrierwave/storage/webdav'

CarrierWave::Storage.autoload :WebDAV, 'carrierwave/storage/webdav'

class CarrierWave::Uploader::Base
  add_config :webdav_username
  add_config :webdav_password
  add_config :webdav_server
  add_config :webdav_write_server
  add_config :webdav_autocreates_dirs

  configure do |config|
    config.storage_engines[:webdav] = 'CarrierWave::Storage::WebDAV'
  end
end
