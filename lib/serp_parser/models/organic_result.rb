require "uri"

module SerpParser
  module Models
    class OrganicResult
      attr_reader :title, :date, :description, :url, :rating, :site_links
      attr_accessor :position

      def initialize(**args)
        @title = args[:title]
        @date = args[:date]
        @description = args[:description]
        @url = args[:url]
        @rating = args[:rating]
        # Wrap site_links in a Collection to assign positions
        @site_links = args[:site_links].is_a?(Array) ? SerpParser::Collection.new(args[:site_links]) : args[:site_links]
      end

      # Parse domain from url
      def domain
        return nil unless url
        _domain = URI.parse(url).host
        return nil unless _domain
        _domain.gsub(/www\./, "")
      end

      # Convert the object to a hash
      # @return [Hash]
      def to_h
        {
          "position" => @position,
          "title" => title,
          "description" => description,
          "domain" => domain,
          "url" => url,
          "date" => date,
          "rating" => (rating && rating.respond_to?(:to_h) && !rating.is_a?(NilClass)) ? (rating.to_h || nil) : rating,
          "site_links" => site_links ? site_links.map(&:to_h) : []
        }
      end
    end
  end
end
