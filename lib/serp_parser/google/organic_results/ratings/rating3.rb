module SerpParser
  module Google
    module OrganicResults
      module Ratings
        class Rating3 < SerpParser::Google::Search
          include SerpParser::Helpers

          SELECTOR = ".yi40Hd"

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
            normalize_number(extract_number(@doc.text), decimals: true)
          end

          def max_score
            5
          end

          def number_of_ratings
            nil
          end

          def processed_data
            {
              "score" => score,
              "max_score" => max_score,
              "number_of_ratings" => number_of_ratings
            }
          end
        end
      end
    end
  end
end
