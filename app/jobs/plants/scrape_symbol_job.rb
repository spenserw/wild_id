module Plants
  class ScrapeSymbolJob < ApplicationJob
    queue_as :scrape

    def perform(symbol)
      scraper = Plants::Scraper.new(symbol)

      return if scraper.complete?

      scraper.scrape
    end
  end
end
