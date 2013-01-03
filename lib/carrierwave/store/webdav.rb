require 'carrierwave/httparty_monkey'

module CarrierWave
  module Storage
    class WebDAV < Abstract

      # Store the file in WebDAV
      #
      # === Parameters
      #
      # [ file (CarrierWave::SanitizedFile) ] the file to store
      #
      # === Returns
      #
      # [ CarrierWave::SanitizedFile ] a sanitized file
      #
      def store!(file)
        stored = CarrierWave::Storage::WebDAV::File.new(uploader, uploader.store_path)
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
        CarrierWave::Storage::WebDAV::File.new(uploader, uploader.store_path(identifier))
      end

      class File
        attr_reader :path
        attr_reader :uploader
        attr_reader :options
        attr_reader :server # Like 'https://www.WebDAV.com/dav'

        def initialize(uploader, path)
          @path = path
          @path.sub! /^\//, ''
          @uploader = uploader
          @server = uploader.webdav_server
          @server.sub! /\/$/, ''
          @username = uploader.webdav_username
          @password = uploader.webdav_password || ''
          if @username
            @options = { basic_auth: { username: @username, password: @password }}
          else
            @options = {}
          end
        end

        def read
          HTTParty.get(fullurl, options).body
        end

        def write(file)
          mkcol
          HTTParty.put(fullurl, options.merge({ body: file }))
        end

        def length
        end

        def delete
        end

        def content_type
        end

        alias :content_length :length
        alias :file_length :length
        alias :size :length

      private
        def fullurl
          "#{server}/#{path}"
        end
        
        def mkcol
          dirs = []
          path.split('/')[0...-1].each do |dir|
            dirs << "#{dirs[-1]}/#{dir}"
          end # Make path like a/b/c/t.txt to array ['/a', '/a/b', '/a/b/c']
          dirs.each do |dir|
            HTTParty.mkcol("#{server}#{dir}", options)
          end # Make collections recursively
        end
      end # File
    end # WebDAV
  end # Storage
end # CarrierWave
