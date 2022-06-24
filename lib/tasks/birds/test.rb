require './reference_images.rb'
require 'dotenv'

Dotenv.load!('../../../.env')

file = File.open('./tmp.jpg', mode: 'w')
uri = URI('https://www.flickr.com/photos/amaizlish/50998538522/')
data = ReferenceImage::FlickrPhotos::get_photo_data(uri)
file.write(data)
