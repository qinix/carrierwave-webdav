require 'mime/types'

module Helpers

  def file_path( *paths )
    File.expand_path(File.join(File.dirname(__FILE__), '../fixtures', *paths))
  end

  def mime_type(path)
    ::MIME::Types.type_for(path).first.to_s
  end

  def file_response(path)
    {
      :status => 200,
      :body => File.read(path),
      :headers => {
        'Content-Type' => mime_type(path),
        'Content-Length' => File.size(path).to_s
      }
    }
  end

  def stub_get(url, path)
    stub_request(:get, url.to_s).
        to_return(file_response(path))
  end

  def stub_head(url, path)
    stub_request(:head, url.to_s).
        to_return(file_response(path))
  end

  def stub_put(url, path)
    stub_request(:put, url.to_s).
        with(:body => File.read(path)).
        to_return(:status => 201, :body => '', :headers => {})
  end

  def stub_mkcol(url)
    split_url = url.to_s.split('/')
    split_url.pop

    stub_request(:mkcol, split_url.join('/')).
        to_return(:status => 200, :body => '', :headers => {})
  end

  def stub_delete(url)
    stub_request(:delete, url.to_s).
        to_return(:status => 200, :body => '', :headers => {})
  end
end
