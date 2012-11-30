require 'erb'
require 'fletch'

class Assets < Thor
  desc 'fetch', 'fetch assets as defined in fletch.json'
  def fetch
    fetch_files
  end

  no_tasks do
    def fetch_files
      config.each do |library, options|
        Fletch::Asset.new(library, options).write
      end
    end

    def config
      @config ||= YAML.load(ERB.new(File.read("fletch.yml")).result)
    end
  end
end
