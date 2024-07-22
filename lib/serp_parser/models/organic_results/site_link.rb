module SerpParser
  module Models
    module OrganicResults
      class SiteLink
        attr_reader :title, :url

        def initialize(**args)
          @title = args[:title]
          @url = args[:url]
        end

        def to_h
          {
            "title" => title,
            "url" => url
          }
        end
      end
    end
  end
end
