module SerpParser
  module Google
    module OrganicResults
      module Shared
        SCHEMA = {
          title: {
            type: :instance_method
          },
          description: {
            type: :instance_method
          },
          url: {
            type: :instance_method
          },
          date: {
            type: :instance_method
          },
          site_links: {
            type: :collection,
            parsers: [
              SerpParser::Google::OrganicResults::SiteLinks::SiteLink1,
              SerpParser::Google::OrganicResults::SiteLinks::SiteLink2
            ]
          }
        }

        def title
          clean_text @doc.css("h3").text
        end

        # Returns the URL of the result
        # @return [String]
        def url
          clean_google_url @doc.css("a").first["href"]
        end

        # Returns the description of the result
        # @return [Date] iso8601
        def date
          element = @doc.css("span.LEwnzc span")
          return nil unless element.any?

          text = element.text
          Date.parse(text).iso8601
        rescue
          nil
        end

        def processed_data
          SerpParser::Models::OrganicResult.new(**@data)
        end
      end
    end
  end
end
