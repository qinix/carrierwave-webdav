require 'net/http'
require 'net/https'
require 'httparty'

# Monkey patch for HTTParty
# Add MKCOL method
module HTTParty

  class Request
    SupportedHTTPMethods << Net::HTTP::Mkcol
    SupportedHTTPMethods << Net::HTTP::Propfind
  end

  module ClassMethods
    # Perform a MKCOL request to a path
    def mkcol(path, options = {}, &block)
      perform_request Net::HTTP::Mkcol, path, options, &block
    end

    # Perform a PROPFIND request to a path
    def propfind(path, options = {}, &block)
      perform_request Net::HTTP::Propfind, path, options, &block
    end
  end

  class Basement
    include HTTParty
  end

  def self.mkcol(*args, &block)
    Basement.mkcol(*args, &block)
  end

  def self.propfind(*args, &block)
    Basement.propfind(*args, &block)
  end
end # HTTParty
