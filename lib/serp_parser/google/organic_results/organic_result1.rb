module SerpParser
  module Google
    module OrganicResults
      class OrganicResult1 < SerpParser::Google::Search
        include SerpParser::Helpers
        include SerpParser::Google::OrganicResults::Shared

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

        def description
          clean_text @doc.css(".VwiC3b").text
        end
      end
    end
  end
end
