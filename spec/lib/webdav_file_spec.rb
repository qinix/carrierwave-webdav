require 'spec_helper'

describe CarrierWave::WebDAV::File do
  describe '#url' do
    let(:webdav_server) { 'https://your.webdavserver.com/dav/' }

    before do
      CarrierWave.configure do |config|
        config.storage = :webdav
        config.cache_storage = :webdav
        config.webdav_server = webdav_server
        config.asset_host = host

        config.webdav_autocreates_dirs = true
      end

      @uploader = CarrierWave::Uploader::Base.new
      @file = File.open(file_path('test.txt'))

      stub_request(:put, %r{#{Regexp.escape(webdav_server)}}).to_return(status: 201)
    end

    context 'when asset_host is set' do
      let(:host) { 'http://asset.host' }

      it 'path contains asset_host' do
        @uploader.cache!(@file)
        expect(@uploader.file.url).to eq [host, @uploader.file.path].join('/')
      end
    end

    context 'when asset_host is not set' do
      let(:host) { nil }

      it 'path does not contain asset_host' do
        @uploader.cache!(@file)
        expect(@uploader.file.url).to eq [webdav_server, @uploader.file.path].join('/')
      end
    end
  end
end
