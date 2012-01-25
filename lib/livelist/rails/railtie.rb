require 'livelist/rails/active_record'

module Livelist
  module Rails

    class Railtie < ::Rails::Railtie
      initializer "livelist-rails" do |app|
        ActiveSupport.on_load :active_record do
          ::ActiveRecord::Base.send :extend, ActiveRecord
        end
      end

      if ::Rails.version < "3.1.0"
        config.before_configuration do
          if %W(production staging).include?(::Rails.env)
            livelist_filename = 'livelist.min'
          else
            livelist_filename = 'livelist'
          end

          config.action_view.javascript_expansions[:livelist_dependencies] = %W(mustache underscore.min)
          config.action_view.javascript_expansions[:livelist] = [livelist_filename]
        end
      end
    end

  end
end
