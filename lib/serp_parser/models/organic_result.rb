module SerpParser
  module Models
    class OrganicResult
      attr_reader :title, :site_links

      def initialize(title: nil, site_links: nil)
        @title = title
        @site_links = site_links
      end
    end
  end
end
