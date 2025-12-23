module SerpParser
  module Google
    module OrganicResults
      module SiteLinks
        class SiteLink3 < SerpParser::Google::Search
          include SerpParser::Helpers

          SELECTOR = ".KTAFWb a.dM1Yyd"
          SCHEMA = {
            title: {
              type: :instance_method
            },
            url: {
              type: :instance_method
            }
          }

          def title
            text = @doc.css(".qXOWAb").text
            text = text.strip.empty? ? @doc.text : text
            clean_text(text)
          end

          def url
            clean_google_url(@doc["href"])
          end

          def processed_data
            SerpParser::Models::OrganicResults::SiteLink.new(**@data)
          end
        end
      end
    end
  end
end
