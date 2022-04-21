class HomeController < ApplicationController
  layout 'application'

  def index
    render inline: helpers.react_component("App", {}), layout: true
  end
end
