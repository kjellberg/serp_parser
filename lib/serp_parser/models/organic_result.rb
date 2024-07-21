module SerpParser
  module Models
    class OrganicResult
      attr_reader :title, :site_links

      def initialize(title: nil, site_links: nil)
        @title = title
        @site_links = site_links
      end

      def to_h
        {
          title: title,
          site_links: site_links.map(&:to_h)
        }
      end
    end
  end
end
