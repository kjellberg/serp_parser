module SerpParser
  module Google
    module OrganicResults
      module SiteLinks
        class SiteLink1 < SerpParser::Google::Search
          SELECTOR = "div.HiHjCd a"
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
            @doc["href"]
          end

          def processed_data
            SerpParser::Models::OrganicResults::SiteLink.new(**@data)
          end
        end
      end
    end
  end
end
