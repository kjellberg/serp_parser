module SerpParser
  module Models
    module OrganicResults
      class SiteLink
        attr_reader :title, :url

        def initialize(title: nil, url: nil)
          @title = title
          @url = url
        end

        def to_h
          {
            title: title,
            url: url
          }
        end
      end
    end
  end
end
