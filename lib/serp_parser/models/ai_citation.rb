require "uri"

module SerpParser
  module Models
    class AiCitation
      attr_reader :title, :url
      attr_accessor :position

      def initialize(**args)
        @title = args[:title]
        @url = args[:url]
      end

      def domain
        return nil unless url
        host = URI.parse(url).host
        return nil unless host
        host.gsub(/www\./, "")
      rescue
        nil
      end

      def to_h
        {
          "position" => @position,
          "title" => title,
          "domain" => domain,
          "url" => url
        }
      end
    end
  end
end
