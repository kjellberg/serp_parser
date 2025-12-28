module SerpParser
  module Models
    module OrganicResults
      class Rating
        attr_reader :score, :max_score, :number_of_ratings

        def initialize(score: nil, max_score: 5, number_of_ratings: nil)
          @score = score
          @max_score = max_score || 5
          @number_of_ratings = number_of_ratings
        end

        # Convert the object to a hash
        # @return [Hash, nil]
        def to_h
          # Return nil if we only have max_score (which is just a default)
          return nil unless score || number_of_ratings

          result = {
            "max_score" => max_score
          }
          result["score"] = score if score
          result["number_of_ratings"] = number_of_ratings if number_of_ratings
          result
        end
      end
    end
  end
end
