module Plants
  class Scraper
    ORIGIN = "https://plants.sc.egov.usda.gov".freeze
    COMPLETE_LIST = "#{ORIGIN}/DocumentLibrary/Txt/plantlst.txt"
    PLANT_PROFILE_PATH_PREFIX = "/plant-profile/".freeze

    def self.pull_complete_list
      response = Net::HTTP.get_response(URI(COMPLETE_LIST))
      output = File.join(__dir__, "data", "plantslst.txt")
      FileUtils.mkdir_p(File.dirname(output))
      File.write(output, response.body)
    end

    def initialize(symbol)
      @symbol = symbol
    end

    def scrape
      browser = Ferrum::Browser.new
      page = browser.create_page

      plant_profile_uri = plant_profile_uri(@symbol).to_s
      puts "Scraping: #{plant_profile_uri}"
      page.goto(plant_profile_uri)
      sleep 5
      page.body
    ensure
      browser&.quit
    end

    private

    def download_distribution
      # POST to /api/PlantProfile/getDownloadDistributionDocumentation
      # example payload: {"Text":"Salicaceae","Field":"Family","Locations":null,"Groups":null,"Durations":null,"GrowthHabits":null,"WetlandRegions":null,"NoxiousLocations":null,"InvasiveLocations":null,"Countries":null,"Provinces":null,"Counties":null,"Cities":null,"Localities":null,"ArtistFirstLetters":null,"ImageLocations":null,"Artists":null,"CopyrightStatuses":null,"ImageReferences":null,"ImageTypes":null,"SortBy":"sortSciName","Offset":null,"FilterOptions":null,"UnfilteredPlantIds":null,"Type":null,"TaxonSearchCriteria":null,"MasterId":67374}
    end

    def plant_profile_uri(symbol)
      URI.join(ORIGIN, PLANT_PROFILE_PATH_PREFIX, symbol)
    end
  end
end
