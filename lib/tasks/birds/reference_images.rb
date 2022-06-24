require 'securerandom'
require 'uri'
require 'json'
require 'pp'
require 'date'

module ReferenceImage
  def self.fetch_image(uri)
    conn = Faraday.new(url: "#{uri.scheme}://#{uri.host}")
    response = conn.get(uri.path)
    response.body
  end

  module FlickrPhotos
    require 'flickr'
    require 'faraday'

    @flickr = nil
    @license_table = nil

    def self.get_session
      # Authentication in `.env`
      @flickr ||= Flickr.new

      unless @license_table
        licenses = @flickr.photos.licenses.getInfo
        @license_table = {}
        licenses.each do |license|
          @license_table[license['id']] = {
            'name' => license['name'],
            'url' => license['url']
          }
        end
      end

      @flickr
    end

    def self.photo_id_from_uri(uri)
      uri.path.split('/').last()
    end

    def self.get_photo_info(uri)
      flickr = get_session()
      photo_id = photo_id_from_uri(uri)

      photo_info = {
        'author' => '',
        'upload_date' => nil,
        'licenses' => {}
      }

      info = flickr.photos.getInfo(photo_id: photo_id)
      photo_info['author'] = info['owner']['username']
      photo_info['upload_date'] = Time.at(info['dates']['posted'].to_i).to_datetime
      photo_info['license'] = @license_table[info['license']]

      photo_info
    end

    def self.get_photo_data(uri)
      flickr = get_session
      photo_id = photo_id_from_uri(uri)

      info = flickr.photos.getInfo(photo_id: photo_id)
      image_uri_large = URI(Flickr.url_b(info))
      image_uri_med = URI(Flickr.url(info))

      {
        large: ReferenceImage.fetch_image(image_uri_large),
        medium: ReferenceImage.fetch_image(image_uri_med)
      }
    end
  end

  module S3
    require 'aws-sdk-s3'
    @s3 = nil
    BUCKET_NAME = 'wild-id-reference-images'
    FOLDER_PREFIX = 'birds'

    def self.init()
      return @s3 if @s3

      # DEV: This envar must be undefined in production
      if ENV['AWS_FAKES3_ENABLED']
        @s3 = Aws::S3::Client.new(
          endpoint: "http://localhost:#{ENV['AWS_FAKES3_PORT']}"
        )
      else
        @s3 = Aws::S3::Client.new
      end

      @s3
    end

    def self.put_image(uuid, data)
      client = init
      client.put_object(
        {
          key: "#{FOLDER_PREFIX}/#{uuid}.jpg",
          body: data,
          bucket: BUCKET_NAME
        }
      )
    end
  end

  def self.create(url)
    uuid = SecureRandom.uuid

    image_uri = URI(url)
    if image_uri.host&.include?('flickr')
      image_info = FlickrPhotos.get_photo_info(image_uri)
      image_data = FlickrPhotos.get_photo_data(image_uri)

      # TODO 3-28-2022: Add failure case
      S3.put_image("#{uuid}-m", image_data[:medium])
      S3.put_image("#{uuid}-l", image_data[:large])

      ref_image = BirdSpeciesReferenceImage.new do |r|
        r.id = uuid
        r.license = image_info['license']
        r.author =  image_info['author']
        r.source_site = 'flickr'
        r.source_url = url
        r.asset_url = "https://#{S3::BUCKET_NAME}.s3.#{ENV['AWS_REGION']}.amazonaws.com/#{S3::FOLDER_PREFIX}/#{uuid}.jpg"
      end
      ref_image.save
    else
      puts "Unsupported website to pull reference image [#{url}]"
      return nil
    end

    uuid
  end
end
