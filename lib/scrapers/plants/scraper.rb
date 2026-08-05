module Plants
  class Scraper
    ORIGIN = "https://plants.sc.egov.usda.gov".freeze
    SERVICES_ORIGIN = "https://plantsservices.sc.egov.usda.gov".freeze
    COMPLETE_LIST = "#{ORIGIN}/DocumentLibrary/Txt/plantlst.txt"

    # Tab/resource payloads keyed off PlantProfile Has* flags.
    # Images are gated separately via include_images:.
    RESOURCES = {
      synonyms: {
        flag: "HasSynonyms",
        path: ->(id) { "/api/PlantSynonyms/#{id}" },
        file: "synonyms.json"
      },
      subordinate_taxa: {
        flag: "HasSubordinateTaxa",
        path: ->(id) { "/api/PlantSubordinateTaxa/#{id}?offset=-1" },
        file: "subordinate_taxa.json"
      },
      wetland: {
        flag: "HasWetlandData",
        path: ->(id) { "/api/PlantWetland/#{id}" },
        file: "wetland.json"
      },
      related_links: {
        flag: "HasRelatedLinks",
        path: ->(id) { "/api/PlantRelatedLinks/#{id}" },
        file: "related_links.json"
      },
      sources: {
        flag: "HasDocumentation",
        path: ->(id) { "/api/PlantDocumentation/#{id}?orderBy=DataSourceString&offset=-1" },
        file: "sources.json"
      },
      characteristics: {
        flag: "HasCharacteristics",
        path: ->(id) { "/api/PlantCharacteristics/#{id}" },
        file: "characteristics.json"
      },
      images: {
        flag: "HasImages",
        path: ->(id) { "/api/PlantImages?plantId=#{id}" },
        file: "images.json",
        optional: :images
      }
    }.freeze

    def self.data_dir
      Rails.root.join("data", "plants")
    end

    def self.pull_complete_list
      response = Net::HTTP.get_response(URI(COMPLETE_LIST))
      output = data_dir.join("plantlst.txt")
      FileUtils.mkdir_p(data_dir)
      File.binwrite(output, response.body)
    end

    def initialize(symbol, include_images: false)
      @symbol = symbol.to_s.upcase
      @include_images = include_images
    end

    def scrape
      FileUtils.mkdir_p(raw_dir)

      profile = fetch_json(services_uri("/api/PlantProfile", symbol: @symbol))
      write_json("profile.json", profile)

      plant_id = profile.fetch("Id")
      scrape_resources(profile, plant_id)
      download_distribution(plant_id) if profile["HasDistributionData"]
    end

    private

    def raw_dir
      self.class.data_dir.join("raw", @symbol)
    end

    def scrape_resources(profile, plant_id)
      RESOURCES.each do |name, resource|
        next unless profile[resource[:flag]]
        next if resource[:optional] == :images && !@include_images

        puts "Fetching #{name}"
        data = fetch_json(services_uri(resource[:path].call(plant_id)))
        write_json(resource[:file], data)
      end
    end

    def download_distribution(plant_id)
      puts "Downloading distribution data (MasterId=#{plant_id})"
      csv = post_json(
        services_uri("/api/PlantProfile/getDownloadDistributionDocumentation"),
        { MasterId: plant_id },
        accept: "text/csv"
      )
      File.binwrite(raw_dir.join("distribution.csv"), csv)
    end

    def write_json(filename, data)
      File.write(raw_dir.join(filename), JSON.pretty_generate(data))
    end

    def services_uri(path, query = {})
      uri = URI.join(SERVICES_ORIGIN, path)
      uri.query = URI.encode_www_form(query) if query.any?
      uri
    end

    def fetch_json(uri)
      response = Net::HTTP.get_response(uri)
      raise "GET #{uri} failed: #{response.code} #{response.message}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    def post_json(uri, body, accept: "application/json")
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Post.new(uri)
        request["Content-Type"] = "application/json"
        request["Accept"] = accept
        request.body = body.to_json
        http.request(request)
      end

      raise "POST #{uri} failed: #{response.code} #{response.message}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end
  end
end
