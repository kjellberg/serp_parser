module SerpParser
  module Google
    module OrganicResults
      module Ratings
        class Rating2 < SerpParser::Google::Search
          include SerpParser::Helpers

          SELECTOR = "div.BNeawe.s3v9rd.AP7Wnd span.r0bn4c.rQMQod.tP9Zud"

          SCHEMA = {
            score: {
              type: :instance_method
            },
            max_score: {
              type: :instance_method
            },
            number_of_ratings: {
              type: :instance_method
            }
          }

          def score
            normalize_number slices[0], decimals: true
          end

          def number_of_ratings
            normalize_number slices[1]
          end

          def max_score
            5
          end

          def processed_data
            {
              "score" => score,
              "max_score" => max_score,
              "number_of_ratings" => number_of_ratings
            }
          end

          private

          def slices
            text = clean_text(@doc.text)
            text.split(" ").map { |slice| extract_number(slice) }
          end
        end
      end
    end
  end
end
