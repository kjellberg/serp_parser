module SerpParser
  module Google
    module OrganicResults
      class OrganicResult4 < SerpParser::Google::Search
        include SerpParser::Helpers

        # Matches the card-style organic result with sitelinks list
        SELECTOR = "div.Ww4FFb.vt6azd.xpd.EtOod.pkphOe"
        REQUIRED_CHILDREN = [ ".F0FGWb" ]

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
              SerpParser::Google::OrganicResults::SiteLinks::SiteLink3
            ]
          },
          rating: {
            type: :instance_method
          }
        }

        def title
          element = @doc.at_css(".F0FGWb span")
          clean_text(element&.text)
        end

        def description
          element = @doc.at_css(".VwiC3b")
          clean_text(element&.text)
        end

        def url
          element = @doc.at_css("a.rTyHce")
          return unless element

          clean_google_url(element["href"])
        end

        def date
          nil
        end

        def rating
          nil
        end

        def processed_data
          SerpParser::Models::OrganicResult.new(**@data)
        end
      end
    end
  end
end

