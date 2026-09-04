# frozen_string_literal: true

require "net/http"
require "uri"

module Datasets
  class Fetcher
    def self.fetch(url, dest_dir:, filename: nil, extract: true)
      new(url, dest_dir:, filename:, extract:).fetch
    end

    def initialize(url, dest_dir:, filename: nil, extract: true)
      @url = url
      @dest_dir = Pathname(dest_dir)
      @filename = filename.presence || File.basename(URI.parse(url).path)
      @extract = extract
    end

    def fetch
      FileUtils.mkdir_p(@dest_dir)
      download unless filepath.exist?
      extract_archive if @extract
      filepath
    end

    private

    def filepath
      @dest_dir.join(@filename)
    end

    def download
      uri = URI.parse(@url)
      response = Net::HTTP.get_response(uri)

      redirects = 0
      while response.is_a?(Net::HTTPRedirection) && redirects < 5
        uri = URI.parse(response["location"])
        response = Net::HTTP.get_response(uri)
        redirects += 1
      end

      unless response.is_a?(Net::HTTPSuccess)
        raise "GET #{@url} failed: #{response.code} #{response.message}"
      end

      File.binwrite(filepath, response.body)
    end

    def extract_archive
      if @filename.end_with?(".zip")
        system("unzip", "-od", @dest_dir.to_s, filepath.to_s, exception: true)
      elsif @filename.end_with?(".7z")
        system("7z", "x", "-o#{@dest_dir}", filepath.to_s, exception: true)
      end
    end
  end
end
