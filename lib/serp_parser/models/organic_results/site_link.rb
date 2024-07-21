module SerpParser
  module Models
    module OrganicResults
      class SiteLink
        attr_reader :title

        def initialize(title: nil, url: nil)
          @title = title
          @url = url
        end
      end
    end
  end
end
