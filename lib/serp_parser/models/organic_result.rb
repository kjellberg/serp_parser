module SerpParser
  module Models
    class OrganicResult
      attr_reader :title, :description, :url, :site_links

      def initialize(title: nil, description: nil, url: nil, site_links: nil)
        @title = title
        @description = description
        @url = url
        @site_links = site_links
      end

      def to_h
        {
          "title" => title,
          "description" => description,
          "url" => url,
          "site_links" => site_links.map(&:to_h)
        }
      end
    end
  end
end
