module Datasets
  class BirdLife < Dataset
    US_TAXA_ARTIFACT = "us_taxa".freeze

    class << self
      def birdlife_data_dir
        Rails.root.join("data", "birdlife")
      end

      def artifact_path(name)
        birdlife_data_dir.join("#{name}.json")
      end
    end
  end
end
