require "livelist-rails/version"

module Livelist
  module Rails

    class Engine < ::Rails::Engine
    end

    # Rails 3.0
    #class Railtie < ::Rails::Railtie
    #  config.before_configuration do
    #    if ::Rails.root.join("public/javascripts/livelist.min.js").exist?
    #      livelist_filename = 'livelist.min'
    #      livelist_filename = 'livelist.min' if ::Rails.env.production?
    #    else
    #      livelist_filename = ::Rails.env.production? ? 'livelist.min' : 'livelist'
    #    end

    #    config.action_view.javascript_expansions[:defaults] << %W(mustache underscore)
    #    config.action_view.javascript_expansions[:defaults] << livelist_filename
    #  end
    #end

  end
end
