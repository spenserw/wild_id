class SearchController < ApplicationController
  def quickfind
    search_term = params[:query]

    search_models = [ ::Species, ::Genus, ::Family, ::Order ]
    search_results = search_models.map { |model| model.search(search_term) }.flatten

    @results = search_results.map do |item|
      {
        scientific_name: item.scientific_name,
        common_names: item.common_names,
        url: item.href,
        class: item.class.name.split("::").first,
        type: item.class.name.demodulize
      }
    end

    render partial: "search/quickfind_results", locals: { results: @results }
  end
end
