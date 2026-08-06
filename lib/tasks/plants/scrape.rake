require "csv"

module Plants
  module ScrapeTasks
    module_function

    def enqueue_symbols_from(list_path)
      symbols = CSV.read(list_path, headers: true)
        .select { |row| row["Synonym Symbol"].to_s.strip.empty? }
        .map { |row| row["Symbol"].to_s.strip.upcase }
        .uniq
        .reject(&:empty?)

      puts "Enqueueing #{symbols.size} symbols from #{list_path.basename}"

      symbols.each do |symbol|
        Scrape::Plants::SymbolJob.perform_later(symbol)
      end

      puts "Done."
    end
  end
end

namespace :plants do
  desc "Download the complete USDA plants list to data/plants/plantlst.txt"
  task pull_complete_list: :environment do
    output = Plants::Scraper.pull_complete_list
    puts "Wrote #{output}"
  end

  desc "Download a state USDA plants list to data/plants/STATE_plantlst.txt"
  task :pull_state_list, [ :state ] => :environment do |_task, args|
    state = args[:state].presence
    abort "Usage: bin/rails plants:pull_state_list[Oregon]" if state.blank?

    output = Plants::Scraper.pull_state_list(state)
    puts "Wrote #{output}"
  end

  desc "Enqueue Solid Queue scrape jobs for accepted symbols in the complete plant list"
  task schedule_full_scrape: :environment do
    list_path = Plants::Scraper.data_dir.join("plantlst.txt")
    unless list_path.exist?
      abort "Missing plant list: #{list_path}\nRun: bin/rails plants:pull_complete_list"
    end

    Plants::ScrapeTasks.enqueue_symbols_from(list_path)
  end

  desc "Enqueue Solid Queue scrape jobs for accepted symbols in a state plant list"
  task :schedule_state_scrape, [ :state ] => :environment do |_task, args|
    state = args[:state].presence
    abort "Usage: bin/rails plants:schedule_state_scrape[Oregon]" if state.blank?

    list_path = Plants::Scraper.data_dir.join("#{state}_plantlst.txt")
    unless list_path.exist?
      abort "Missing plant list: #{list_path}\nRun: bin/rails plants:pull_state_list[#{state}]"
    end

    Plants::ScrapeTasks.enqueue_symbols_from(list_path)
  end
end
