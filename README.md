# CarrierWave for WebDAV

[![Build Status](https://travis-ci.org/qinix/carrierwave-webdav.png?branch=master)](https://travis-ci.org/qinix/carrierwave-webdav)

This gem adds support for WebDAV to
[CarrierWave](https://github.com/carrierwaveuploader/carrierwave/)

## Installation

Install the latest release:

    gem install carrierwave-webdav

Require it in your code:

    require 'carrierwave/webdav'

Or, in Rails you can add it to your Gemfile:

    gem 'carrierwave-webdav', :require => 'carrierwave/webdav'

## Getting Started

Follow the "Getting Started" directions in the main
[Carrierwave repository](https://github.com/carrierwaveuploader/carrierwave/).

## Using WebDAV store

In Rails, add WebDAV settings to `config/initializers/carrierwave.rb`

```ruby
CarrierWave.configure do |config|
  config.storage = :webdav
  config.webdav_server = 'https://your.webdav_server.com/dav' # Your WebDAV url.
  # config.webdav_write_server = 'https://secure.your.webdavserver.com/dav/' # This is an optional attribute. It can save on one server and read from another server. (Contributed by @eychu. Thanks)
  config.webdav_username = 'your webdav username'
  config.webdav_password = 'your webdav password'
end
```

In your uploader, set the storage to `:webdav`:

```ruby
class AvatarUploader < CarrierWave::Uploader::Base
  storage :webdav
end
```

Since WebDAV doesn't make the files available via HTTP, you'll need to stream
them yourself. In Rails for example, you could use the `send_data` method.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

