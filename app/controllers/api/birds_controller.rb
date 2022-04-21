class Api::BirdsController < ApplicationController
  require 'cgi'

  def species
    if params[:species]
      @species = BirdSpecies.where(scientific_name: params[:species])
    elsif params[:species_name]
      @species = BirdSpecies.find_by(scientific_name: params[:species_name])
    else
      @species = BirdSpecies.all
    end

    results = {}
    @species.each do |s|
      family = BirdFamily.find_by(id: s.bird_family_id).scientific_name
      results[family] = { "species" => {} } if not results[family]
      results[family]["species"][s.scientific_name] = s
    end

    render json: results
  end

  def families
    if params[:families]
      @families = BirdFamily.where(scientific_name: params[:families]).order(:scientific_name)
    elsif params[:family_name]
      @families = BirdFamily.find_by(scientific_name: params[:family_name])
    else
      @families = BirdFamily.all.order(:scientific_name)
    end

    render json: @families
  end
end
