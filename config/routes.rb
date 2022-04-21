Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :api, constraints: { format: 'json' } do
    get '/birds/species(/:species_name)', to: 'birds#species'
    get 'birds/families(/:family_name)', to: 'birds#families'
  end
  
  get '*path', controller: :home, action: :index
end
