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
          @write_server = uploader.webdav_write_server
          @write_server.sub!(/\/$/, '') if @write_server
          @username = uploader.webdav_username
          @password = uploader.webdav_password || ''
          @options = {}
          @options = { basic_auth: { username: @username, password: @password } } if @username
          @create_dirs = !uploader.webdav_autocreates_dirs
        end

        def read
          HTTParty.get(url, options).body
        end

        def headers
          HTTParty.get(url, options).headers
        end

        def write(file)
          if @create_dirs
            mkcol
          end

          HTTParty.put(write_url, options.merge({ body: file }))
        end

        def length
          read.bytesize
        end

        def content_type
          headers.content_type
        end

        def delete
          HTTParty.delete(write_url, options)
        end

        def url
          "#{server}/#{path}"
        end

        alias :content_length :length
        alias :file_length :length
        alias :size :length

      private

        def write_url
          @write_server ? "#{@write_server}/#{path}" : url
        end

        def mkcol
          dirs = []
          path.split('/')[0...-1].each do |dir|
            dirs << "#{dirs[-1]}/#{dir}"
          end # Make path like a/b/c/t.txt to array ['/a', '/a/b', '/a/b/c']
          use_server = @write_server ? @write_server : server
          dirs.each do |dir|
            HTTParty.mkcol("#{use_server}#{dir}", options)
          end # Make collections recursively
        end
      end # File
    end # WebDAV
  end # Storage
end # CarrierWave
