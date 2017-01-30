require 'carrierwave/httparty_monkey'
require 'carrierwave/webdav/file'

module CarrierWave
  module Storage
    class WebDAV < Abstract
      # Store file in WebDAV cache directory
      #
      # === Parameters
      #
      # [ file (CarrierWave::SanitizedFile) ] the file to store
      #
      # === Returns
      #
      # [ CarrierWave::Storage::WebDAV::File ] a sanitized file
      #
      def cache!(file)
        cached = build_webdav_file(uploader.cache_path)
        cached.write(file.read)
        cached
      end

      # Retrieve file with given cache identifier from WebDAV
      #
      # === Parameters
      #
      # [ identifier (String) ] cache identifier
      #
      # === Returns
      #
      # [ CarrierWave::Storage::WebDAV::File ] a sanitized file
      #
      def retrieve_from_cache!(identifier)
        build_webdav_file(uploader.cache_path(identifier))
      end

      # Delete cache directory from WebDAV
      #
      # === Parameters
      #
      # [ path (String) ] cache path
      #
      # === Returns
      #
      # [ HTTParty::Response ] httparty response object
      #
      # === Raises
      #
      # [ CarrierWave::IntegrityError ]
      #
      def delete_dir!(path)
        cached = build_webdav_file(path)
        cached.delete_dir
      end

      # Store the file in WebDAV
      #
      # === Parameters
      #
      # [ file (CarrierWave::SanitizedFile) ] the file to store
      #
      # === Returns
      #
      # [ CarrierWave::Store::WebDAV::File ] a sanitized file
      #
      def store!(file)
        stored = build_webdav_file(uploader.store_path)
        stored.write(file.read)
        stored
      end

      # Retrieve the file from WebDAV
      #
      # === Parameters
      #
      # [ identifier (String) ] the filename of the file
      #
      # === Returns
      #
      # [ CarrierWave::Store::WebDAV::File ] a sanitized file
      #
      def retrieve!(identifier)
        build_webdav_file(uploader.store_path(identifier))
      end

      private

      def build_webdav_file(path)
        CarrierWave::WebDAV::File.new(uploader, path)
      end
    end # WebDAV
  end # Storage
end # CarrierWave
