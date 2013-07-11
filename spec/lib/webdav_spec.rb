require 'spec_helper'
require 'carrierwave/webdav'
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
    @uploader.stub! store_path: 'uploads/test.txt'

    @storage = CarrierWave::Storage::WebDAV.new(@uploader)
    @file = CarrierWave::SanitizedFile.new(file_path('test.txt'))

    @uri = URI(@uploader.webdav_server)
    @uri.user = @uploader.webdav_username
    @uri.password = @uploader.webdav_password
    @uri.merge! @uploader.store_path
  end

  it 'should store from WebDAV' do
    stub_mkcol @uri
    stub_put @uri
    webdav_file = @storage.store!(@file)
    stub_get @uri
    expect(@file.read).to eq(webdav_file.read)
  end

  it 'should retrieve a file from WebDAV' do
    stub_mkcol @uri
    stub_put @uri
    webdav_file = @storage.store!(@file)
    stub_get @uri
    retrieved_file = @storage.retrieve!(webdav_file)
    expect(@file.read).to eq(retrieved_file.read)
    expect(File.basename(@file.path)).to eq(File.basename(retrieved_file.path))
  end

  it 'should delete a file from WebDAV' do
    stub_mkcol @uri
    stub_put @uri
    webdav_file = @storage.store!(@file)
    stub_delete @uri
    expect(Net::HTTPOK).to eq(webdav_file.delete.response.class)
  end

  it 'should size equal' do
    stub_mkcol @uri
    stub_put @uri
    webdav_file = @storage.store!(@file)
    stub_get @uri
    expect(@file.size).to eq(webdav_file.size)
  end

  it 'should url equal' do
    stub_mkcol @uri
    stub_put @uri
    webdav_file = @storage.store!(@file)
    expect("#{@uploader.webdav_server}/#{@uploader.store_path}").to eq(webdav_file.url)
  end

  it 'should save through secure server' do
    CarrierWave.configure do |config|
      config.webdav_write_server = 'https://secure.your.webdavserver.com/dav/'
    end

    secure_uri = URI(@uploader.webdav_write_server)
    secure_uri.user = @uploader.webdav_username
    secure_uri.password = @uploader.webdav_password
    secure_uri.merge! @uploader.store_path

    stub_mkcol secure_uri
    stub_put secure_uri
    webdav_file = @storage.store!(@file)

    stub_get @uri
    expect(@file.read).to eq(webdav_file.read)
  end

end