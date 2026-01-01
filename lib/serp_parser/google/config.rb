module SerpParser
  module Google
    module Config
      def self.registry
        @registry ||= build_registry
      end

      def self.build_registry
        builder = Dsl::Builder.new
        builder.instance_eval(&config_block)
        builder.registry
      end

      def self.define(&block)
        @config_block = block
      end

      def self.config_block
        @config_block ||= proc do
          # --- COMPONENTS (Nested) ---

          component :rating do
            variant "standard", meta: { first_seen: "2024-09-06" } do
              match "div.smukrd"
              model SerpParser::Models::OrganicResults::Rating
              text :score, ".", processors: [ :text, :extract_score_from_text ]
              text :number_of_ratings, ".", processors: [ :text, :extract_count_from_text ]
            end

            variant "inline_spans", meta: { first_seen: "2024-09-06" } do
              match "div.BNeawe.s3v9rd.AP7Wnd span.r0bn4c.rQMQod.tP9Zud"
              model SerpParser::Models::OrganicResults::Rating
              text :score, ".", processors: [ :text, :extract_rating_slices, :take_first, :normalize_number_with_decimals ]
              text :number_of_ratings, ".", processors: [ :text, :extract_rating_slices, :take_second, :normalize_number ]
            end

            variant "simple_rating", meta: { first_seen: "2025-12-23" } do
              match ".yi40Hd"
              model SerpParser::Models::OrganicResults::Rating
              text :score, ".", processors: [ :text, :extract_number, :normalize_number_with_decimals ]
            end
          end

          component :sitelinks do
            variant "div_links", meta: { first_seen: "2024-09-06" } do
              match "div.HiHjCd a"
              model SerpParser::Models::OrganicResults::SiteLink
              text :title
              url :url, attribute: "href"
            end

            variant "inline_links", meta: { first_seen: "2024-09-06" } do
              match ".BNeawe.s3v9rd.AP7Wnd .BNeawe a"
              model SerpParser::Models::OrganicResults::SiteLink
              text :title
              url :url, attribute: "href"
            end

            variant "card_links", meta: { first_seen: "2025-12-23" } do
              match ".KTAFWb a.dM1Yyd"
              model SerpParser::Models::OrganicResults::SiteLink
              text :title, ".", processors: [ :extract_title_with_fallback, :clean_text ]
              url :url, attribute: "href"
            end

            variant "featured_links", meta: { first_seen: "2026-01-01" } do
              match "a.tNxQIb"
              model SerpParser::Models::OrganicResults::SiteLink
              text :title, ".lKeYrd span"
              url :url, attribute: "href"
            end
          end

          component :related_search do
            variant "filter_pill", meta: { first_seen: "2025-12-23" } do
              match "div.T3FoJb[role=\"listitem\"] a"
              model SerpParser::Models::RelatedSearch
              url :query, attribute: "href", processors: [ :extract_query_from_search_url ]
            end

            variant "question_link", meta: { first_seen: "2025-12-23" } do
              match "a.ocRFx.aXYP2e.DxAvsd.sG4dYe"
              model SerpParser::Models::RelatedSearch
              text :query, "span.dg6jd.JGD2rd", processors: [ :clean_text, :downcase ]
            end
          end

          # --- TOP LEVEL ELEMENTS ---

          element :organic_result do
            variant "classic", meta: { first_seen: "2024-09-06" } do
              container "div.g.Ww4FFb"
              required_children [ "h3" ]
              text :title, "h3"
              text :description, ".VwiC3b", processors: [ :remove_span_elements, :text, :clean_text ]
              url :url, "a", attribute: "href"
              date :date, "span.LEwnzc span"
              has_one :rating
              has_many :site_links, component: :sitelinks
            end

            variant "card", meta: { first_seen: "2024-09-06" } do
              container "div.Gx5Zad.xpd.EtOod.pkphOe"
              required_children [ ".egMi0.kCrYT" ]
              text :title, "h3"
              text :description, ".BNeawe.s3v9rd.AP7Wnd", processors: [ :find_description_node, :remove_span_elements, :text, :clean_text ]
              url :url, ".kCrYT a", attribute: "href"
              date :date, "div.BNeawe.s3v9rd.AP7Wnd span.r0bn4c.rQMQod"
              has_one :rating
              has_many :site_links, component: :sitelinks
            end

            variant "featured", meta: { first_seen: "2024-09-06" } do
              container "div.Gx5Zad.xpd.EtOod.pkphOe"
              required_children [ ".kCrYT div.BNeawe span.rQMQod.Xb5VRe" ]
              text :title, "span.rQMQod.Xb5VRe"
              text :description, ".PqksIc.nRlVm"
              url :url, ".kCrYT a", attribute: "href"
              has_one :rating
              has_many :site_links, component: :sitelinks
            end

            variant "modern_card", meta: { first_seen: "2025-12-23" } do
              container "div.Ww4FFb.vt6azd.xpd.EtOod.pkphOe"
              required_children [ ".F0FGWb" ]
              text :title, ".F0FGWb span"
              text :description, ".VwiC3b"
              url :url, "a.rTyHce", attribute: "href", processors: [ :extract_from_ping_if_needed ]
              has_one :rating
              has_many :site_links, component: :sitelinks
            end

            variant "featured_with_sitelinks", meta: { first_seen: "2026-01-01" } do
              container "div.Ww4FFb.vt6azd:not(.xxAJT):not(.eDSE7e)"
              required_children [ ".GkAmnd" ]
              text :title, ".GkAmnd"
              text :description, ".VwiC3b"
              url :url, "a.rTyHce", attribute: "href"
              has_one :rating
              has_many :site_links, component: :sitelinks
            end
          end

          element :related_searches do
            variant "filter_pills", meta: { first_seen: "2025-12-23" } do
              container "div.fBctee"
              has_many :related_searches, component: :related_search
            end

            variant "questions", meta: { first_seen: "2025-12-23" } do
              container "div.Wt5Tfe"
              has_many :related_searches, component: :related_search
            end
          end
        end
      end
    end
  end
end
