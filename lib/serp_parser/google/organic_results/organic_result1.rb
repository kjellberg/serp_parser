module SerpParser
  module Google
    module OrganicResults
      class OrganicResult1 < SerpParser::Google::Search
        include SerpParser::Google::OrganicResults::Shared
        include SerpParser::Helpers

        # @return [String]
        SELECTOR = "div.g.Ww4FFb"
        REQUIRED_CHILDREN = ["h3"]

        # The schema for the organic result.
        # @return [Hash]
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
              SerpParser::Google::OrganicResults::SiteLinks::SiteLink1
            ]
          },
          rating: {
            type: :hash,
            parsers: [
              SerpParser::Google::OrganicResults::Ratings::Rating1
            ]
          }
        }

        # Returns the date of the result
        # @return [Date] iso8601
        def date
          element = @doc.css("span.LEwnzc span")
          return nil unless element.any?

          text = element.text
          Date.parse(text).iso8601
        rescue
          nil
        end

        # Returns the description of the result
        # @return [String]
        def description
          element = @doc.css(".VwiC3b")
          element = remove_span_elements(element)
          clean_text element.text
        end
      end
    end
  end
end
