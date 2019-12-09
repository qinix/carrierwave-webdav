require 'spec_helper'
require 'uri'

describe CarrierWave::Storage::WebDAV do

  before do
    CarrierWave.configure do |config|
      config.storage = :webdav
      config.webdav_server = 'https://your.webdavserver.com/dav/'
      config.webdav_username = 'your_webdav_username'
      config.webdav_password = 'your_webdav_password'
    end

    @uploader = CarrierWave::Uploader::Base.new

    allow(@uploader).to receive(:store_path) { 'uploads/test.txt' }
    allow(@uploader).to receive(:cache_path) { 'uploads/tmp_test.txt' }

    @storage = CarrierWave::Storage::WebDAV.new(@uploader)
    @file = CarrierWave::SanitizedFile.new(file_path('test.txt'))
    @file.content_type = 'text/plain'

    # NOTE: specs fail with this options
    #
    # @uri.user = @uploader.webdav_username
    # @uri.password = @uploader.webdav_password

    @uri = URI(File.join(@uploader.webdav_server, @uploader.store_path))
    @cache_uri = URI(File.join(@uploader.webdav_server, @uploader.cache_path))
  end

  describe '#cache!' do
    it 'should cache from WebDAV' do
      stub_mkcol @cache_uri
      stub_put(@cache_uri, @file.path)
      webdav_file = @storage.cache!(@file)
      stub_get(@cache_uri, @file.path)
      expect(@file.read).to eq(webdav_file.read)
    end
  end

  describe '#retrieve_from_cache!' do
    it 'should retreive a cache file from WebDAV' do
      stub_get(@cache_uri, @file.path)
      webdav_file = @storage.retrieve_from_cache!('tmp_test.txt')
      expect(@file.read).to eq(webdav_file.read)
    end
  end

  describe '#delete_dir!' do
    it 'should delete cache directory' do
      stub_delete File.join(@uploader.webdav_server, 'uploads/')
      result = @storage.delete_dir!('uploads')
      expect(Net::HTTPOK).to eq(result.response.class)
    end
  end

  it 'should store from WebDAV' do
    stub_mkcol @uri
    stub_put(@uri, @file.path)
    webdav_file = @storage.store!(@file)
    stub_get(@uri, @file.path)
    expect(@file.read).to eq(webdav_file.read)
  end

  it 'should retrieve a file from WebDAV' do
    stub_mkcol @uri
    stub_put(@uri, @file.path)
    webdav_file = @storage.store!(@file)
    stub_get(@uri, @file.path)
    retrieved_file = @storage.retrieve!(webdav_file)
    expect(@file.read).to eq(retrieved_file.read)
    expect(File.basename(@file.path)).to eq(File.basename(retrieved_file.path))
  end

  it 'should delete a file from WebDAV' do
    stub_mkcol @uri
    stub_put(@uri, @file.path)
    webdav_file = @storage.store!(@file)
    stub_delete @uri
    expect(Net::HTTPOK).to eq(webdav_file.delete.response.class)
  end

  it 'should size equal' do
    stub_mkcol @uri
    stub_put(@uri, @file.path)
    webdav_file = @storage.store!(@file)
    stub_head(@uri, @file.path)
    expect(@file.size).to eq(webdav_file.size)
  end

  it 'assigns file content type to attribute' do
    stub_mkcol @uri
    stub_put(@uri, @file.path)
    webdav_file = @storage.store!(@file)
    stub_head(@uri, @file.path)
    expect(@file.content_type).to eq(webdav_file.content_type)
  end

  it 'should url equal' do
    stub_mkcol @uri
    stub_put(@uri, @file.path)
    webdav_file = @storage.store!(@file)
    expect("#{@uploader.webdav_server}/#{@uploader.store_path}").to eq(webdav_file.url)
  end

  context 'when use write server' do
    before do
      CarrierWave.configure do |config|
        config.webdav_write_server = 'https://secure.your.webdavserver.com/dav/'
      end
    end

    after do
      CarrierWave.configure do |config|
        config.webdav_write_server = nil
      end
    end

    it 'should save through secure server' do
      secure_uri = URI(File.join(@uploader.webdav_write_server, @uploader.store_path))

      # NOTE: specs fail with this options
      #
      # secure_uri.user = @uploader.webdav_username
      # secure_uri.password = @uploader.webdav_password

      stub_mkcol secure_uri
      stub_put(secure_uri, @file.path)
      webdav_file = @storage.store!(@file)

      stub_get(@uri, @file.path)
      expect(@file.read).to eq(webdav_file.read)
    end
  end

end
