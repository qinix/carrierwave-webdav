module Helpers

  def file_path( *paths )
    File.expand_path(File.join(File.dirname(__FILE__), '../fixtures', *paths))
  end

  def stub_get(url)
    stub_request(:get, url.to_s).
        to_return(:status => 200, :body => 'Hello, this is test data.', :headers => {})
  end

  def stub_put(url)
    stub_request(:put, url.to_s).
        with(:body => 'Hello, this is test data.').
        to_return(:status => 200, :body => '', :headers => {})
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
