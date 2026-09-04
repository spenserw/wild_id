# frozen_string_literal: true

require "json"

module Datasets
  class JsonWriter
    def self.write(name, data, dest_dir:)
      dest_dir = Pathname(dest_dir)
      FileUtils.mkdir_p(dest_dir)
      filename = "#{name.gsub(/[^\w.]/, "_").downcase}.json"
      path = dest_dir.join(filename)
      File.write(path, JSON.pretty_generate(data))
      path
    end
  end
end
