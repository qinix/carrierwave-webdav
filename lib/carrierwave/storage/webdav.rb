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
          res = HTTParty.get(url, options)
          if res.code != 200
            raise CarrierWave::IntegrityError.new("Can't download a file: #{res.inspect}")
          end
          res.body
        end

        def headers
          res = HTTParty.head(url, options)
          if res.code != 200
            raise CarrierWave::IntegrityError.new("Can't headers for a file: #{res.inspect}")
          end
          res.headers
        end

        def write(file)
          if @create_dirs
            res = mkcol
          end

          res = HTTParty.put(write_url, options.merge({ body: file }))
          if res.code != 201 and res.code != 204
            raise CarrierWave::IntegrityError.new("Can't put a new file: #{res.inspect}")
          end
          res
        end

        def length
          read.bytesize
        end

        def content_type
          headers.content_type
        end

        def delete
          res = HTTParty.delete(write_url, options)
          if res.code != 200 and res.code != 204 and res.code != 404
            raise CarrierWave::IntegrityError.new("Can't delete a file: #{res.inspect}")
          end
          res
        end

        def url
          if host = uploader.asset_host
            host.respond_to?(:call) ? host.call(self) : [host, path].join('/')
          else
            "#{server}/#{path}"
          end
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
            res = HTTParty.mkcol("#{use_server}#{dir}", options)
            unless [200, 201, 207, 409].include? res.code
              raise CarrierWave::IntegrityError.new("Can't create a new collection: #{res.inspect}")
            end
          end # Make collections recursively
        end
      end # File
    end # WebDAV
  end # Storage
end # CarrierWave
