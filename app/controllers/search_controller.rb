class SearchController < ApplicationController
  def quickfind
    search_term = params[:query]
    return head :ok if search_term.nil? || search_term.empty?

    # TODO: Replace this with ts_ search
    search_results = Species.where("scientific_name LIKE ?", search_term + "%") +
      Genus.where("scientific_name LIKE ?", search_term + "%") +
      Family.where("scientific_name LIKE ?", search_term + "%") +
      Order.where("scientific_name LIKE ?", search_term + "%")

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
