module SerpParser
  module Google
    module OrganicResults
      module Ratings
        class Rating1 < SerpParser::Google::Search
          include SerpParser::Helpers

          SELECTOR = "div.smukrd"

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
            normalize_number extract_number(slices[0]), decimals: true
          end

          def number_of_ratings
            normalize_number extract_number(slices[1])
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
            @doc.text&.split(" · ")&.map { |slice| clean_text(slice) }
          end
        end
      end
    end
  end
end
