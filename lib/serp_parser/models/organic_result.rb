module SerpParser
  module Models
    class OrganicResult
      attr_reader :title, :date, :description, :url, :site_links

      def initialize(**args)
        @title = args[:title]
        @date = args[:date]
        @description = args[:description]
        @url = args[:url]
        @site_links = args[:site_links]
      end

      def to_h
        {
          "title" => title,
          "description" => description,
          "url" => url,
          "date" => date,
          "site_links" => site_links.map(&:to_h)
        }
      end
    end
  end
end
