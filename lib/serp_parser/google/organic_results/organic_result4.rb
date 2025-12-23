module SerpParser
  module Google
    module OrganicResults
      class OrganicResult4 < SerpParser::Google::Search
        include SerpParser::Helpers

        # Card-style organic result that may include sitelinks and/or rating
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
            type: :hash,
            parsers: [
              SerpParser::Google::OrganicResults::Ratings::Rating3
            ]
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
          link = @doc.at_css("a.rTyHce")
          return unless link

          href = link["href"]
          href = link["ping"].to_s.split(" ").first if href&.start_with?("javascript")
          clean_google_url(href)
        end

        def date
          nil
        end

        def processed_data
          SerpParser::Models::OrganicResult.new(**@data)
        end
      end
    end
  end
end
