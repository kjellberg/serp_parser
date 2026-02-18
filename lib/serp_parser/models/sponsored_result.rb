require "uri"

module SerpParser
  module Models
    class SponsoredResult
      attr_reader :title, :advertiser, :description, :url, :site_links
      attr_accessor :position

      def initialize(**args)
        @title = args[:title]
        @advertiser = args[:advertiser]
        @description = args[:description]
        @url = args[:url]
        @site_links = args[:site_links].is_a?(Array) ? SerpParser::Collection.new(args[:site_links]) : args[:site_links]
      end

      def domain
        return nil unless url
        host = URI.parse(url).host
        return nil unless host
        host.gsub(/www\./, "")
      end

      def to_h
        {
          "position" => @position,
          "advertiser" => advertiser,
          "title" => title,
          "description" => description,
          "domain" => domain,
          "url" => url,
          "site_links" => site_links ? site_links.map(&:to_h) : []
        }
      end
    end
  end
end
