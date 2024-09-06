module SerpParser
  module Models
    module OrganicResults
      class SiteLink
        attr_reader :title, :url
        attr_accessor :position

        def initialize(**args)
          @title = args[:title]
          @url = args[:url]
        end

        # Convert the object to a hash
        # @return [Hash]
        def to_h
          {
            "position" => position,
            "title" => title,
            "url" => url
          }
        end
      end
    end
  end
end
