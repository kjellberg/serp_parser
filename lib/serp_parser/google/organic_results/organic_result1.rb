module SerpParser
  module Google
    module OrganicResults
      class OrganicResult1 < SerpParser::Google::Search
        SELECTOR = "div.g.Ww4FFb"
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
          site_links: {
            type: :collection,
            parsers: [
              SerpParser::Google::OrganicResults::SiteLinks::SiteLink1
            ]
          }
        }

        def title
          clean_text @doc.css("h3").text
        end

        def description
          clean_text @doc.css(".VwiC3b").text
        end

        def url
          @doc.css("a").first["href"]
        end

        def processed_data
          SerpParser::Models::OrganicResult.new(**@data)
        end

        private

        # Clean text from extra spaces
        # @param text [String]
        # @return [String]
        def clean_text(text)
          text.gsub(/\s+/, " ").strip
        end
      end
    end
  end
end
