#!/usr/bin/env ruby

require 'dotenv/load'

if not Dir.exist?(ENV["FAKE_S3_MNT_DIR"])
  Dir.mkdir(ENV["FAKE_S3_MNT_DIR"])
end

pid = Process.fork do
  `fakes3 -r #{ENV['FAKE_S3_MNT_DIR']} -p #{ENV['FAKE_S3_PORT']} --license #{ENV['FAKE_S3_LICENSE_KEY']}`
end

Process.wait
