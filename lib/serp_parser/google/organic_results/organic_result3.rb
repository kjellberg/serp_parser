module SerpParser
  module Google
    module OrganicResults
      # Variant matching the same card layout as OrganicResult2.
      # Kept separate to satisfy fixtures that expect this class name.
      class OrganicResult3 < OrganicResult2
        SELECTOR = OrganicResult2::SELECTOR
        REQUIRED_CHILDREN = OrganicResult2::REQUIRED_CHILDREN
        SCHEMA = OrganicResult2::SCHEMA
      end
    end
  end
end
