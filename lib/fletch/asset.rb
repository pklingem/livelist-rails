require 'open-uri'
require 'uglifier'
require 'active_support'

module Fletch
  class Asset
    def initialize(library, attributes)
      @library         = library
      @url             = attributes['url']
      @path            = attributes['path']
      @minify          = attributes['minify']
      @output_filename = attributes['output_filename'] || File.basename(@url)
    end

    def content
      @content ||= open(@url).read
    end

    def output_file_path
      File.join(@path, @output_filename)
    end

    def minified_content
      Uglifier.compile(content)
    end

    def write
      log
      open(output_file_path, 'wb') do |file|
        file << (@minify ? minified_content : content)
      end
    rescue Exception => e
      puts "\tFAILED: #{e}"
    end

    def log
      puts "#{@library}:"
      puts "\tfetching  #{@url}"
      puts "\tminifying" if @minify
      puts "\twriting   #{output_file_path}"
    end
  end
end
