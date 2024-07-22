module SerpParser
  module Google
    module OrganicResults
      module SiteLinks
        class SiteLink2 < SerpParser::Google::Search
          include SerpParser::Helpers

          SELECTOR = ".BNeawe.s3v9rd.AP7Wnd .BNeawe a"
          SCHEMA = {
            title: {
              type: :instance_method
            },
            url: {
              type: :instance_method
            }
          }

          def title
            @doc.text
          end

          def url
            clean_google_url @doc["href"]
          end

          def processed_data
            SerpParser::Models::OrganicResults::SiteLink.new(**@data)
          end
        end
      end
    end
  end
end
