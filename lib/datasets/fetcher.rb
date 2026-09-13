# frozen_string_literal: true

require "net/http"
require "securerandom"
require "uri"

module Datasets
  class Fetcher
    MAX_REDIRECTS = 5

    # Leading bytes each archive type must start with, used to reject error pages
    # that upstream CDNs hand back with a 200 status.
    ARCHIVE_MAGIC = {
      ".zip" => ["PK\x03\x04".b, "PK\x05\x06".b, "PK\x07\x08".b],
      ".7z" => ["7z\xBC\xAF\x27\x1C".b]
    }.freeze

    MAGIC_LENGTH = ARCHIVE_MAGIC.values.flatten.map(&:bytesize).max

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
      download unless downloaded?
      extract_archive if @extract
      filepath
    end

    private

    def filepath
      @dest_dir.join(@filename)
    end

    def extname
      File.extname(@filename).downcase
    end

    # Only treat a cached file as usable if it still looks like the archive we
    # expect, so a truncated or rejected download is retried instead of reused.
    def downloaded?
      filepath.exist? && archive?(filepath.binread(MAGIC_LENGTH))
    end

    def download
      body = get(@url)

      # census.gov sits behind a CDN that can serve a cached WAF rejection page
      # with a 200 status. A unique query string routes around the cached copy.
      body = get(cache_busting_url) unless archive?(body)

      unless archive?(body)
        raise "GET #{@url} did not return a #{extname} archive (got #{body.to_s.bytesize} bytes)"
      end

      File.binwrite(filepath, body)
    end

    def get(url)
      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)

      redirects = 0
      while response.is_a?(Net::HTTPRedirection) && redirects < MAX_REDIRECTS
        uri = URI.parse(response["location"])
        response = Net::HTTP.get_response(uri)
        redirects += 1
      end

      unless response.is_a?(Net::HTTPSuccess)
        raise "GET #{url} failed: #{response.code} #{response.message}"
      end

      response.body
    end

    def cache_busting_url
      uri = URI.parse(@url)
      uri.query = [uri.query, "cache_bust=#{SecureRandom.hex(8)}"].compact.join("&")
      uri.to_s
    end

    def archive?(bytes)
      magic = ARCHIVE_MAGIC[extname]
      return true if magic.nil?

      head = bytes.to_s.byteslice(0, MAGIC_LENGTH).b
      magic.any? { |signature| head.start_with?(signature) }
    end

    def extract_archive
      case extname
      when ".zip"
        system("unzip", "-od", @dest_dir.to_s, filepath.to_s, exception: true)
      when ".7z"
        system("7z", "x", "-o#{@dest_dir}", filepath.to_s, exception: true)
      end
    end
  end
end
