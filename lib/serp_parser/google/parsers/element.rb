module SerpParser
  module Google
    module Parsers
      class Element
        include Processors

        def initialize(element_doc, element_name, registry)
          @doc = element_doc
          @element_name = element_name
          @registry = registry
          @data = {}
          @matched_variant = nil
        end

        def parse
          find_matching_variant unless @matched_variant
          return nil unless @matched_variant

          extract_fields
          extract_components
          @data
        end

        def self.find_all(doc, element_name, registry)
          variants = registry.get_element_variants(element_name)
          return [] if variants.empty?

          # Collect all container selectors
          all_containers = variants.map { |v| v[:container] }.compact.uniq
          combined_selector = all_containers.join(", ")

          all_elements = doc.css(combined_selector)
          results = []

          # Process elements in document order, preserving their index
          all_elements.each_with_index do |element, index|
            # Try each variant to see which one matches this element
            matched_data = nil
            variants.each do |variant|
              # Check if this element matches this variant's container
              # We already found it via combined selector, but verify required children
              required = variant[:required_children] || []
              next unless required.empty? || required.all? { |child_selector| element.css(child_selector).any? }

              # This variant matches - parse with it
              parser = new(element, element_name, registry)
              parser.instance_variable_set(:@matched_variant, variant)
              data = parser.parse
              if data
                matched_data = data
                break # Use first matching variant
              end
            end

            results << { index: index, data: matched_data } if matched_data
          end

          # Sort by document order (using captured index instead of expensive index() lookup)
          sorted_results = results.sort_by { |r| r[:index] }
          sorted_results.map { |r| r[:data] }
        end

        private

        def find_matching_variant
          variants = @registry.get_element_variants(@element_name)

          @matched_variant = variants.find do |variant|
            next false unless variant[:container]

            # Check required children (primary validation)
            required = variant[:required_children] || []
            next false unless required.empty? || required.all? { |child_selector| @doc.css(child_selector).any? }

            # If we got here and we're checking variants, the container already matched
            # (since find_all pre-selected by container selectors)
            true
          end
        end

        def extract_fields
          return unless @matched_variant

          @matched_variant[:fields].each do |field_name, field_def|
            value = extract_field_value(field_def)
            @data[field_name] = value unless value.nil?
          end
        end

        def extract_field_value(field_def)
          selector = field_def[:selector]
          element = selector ? @doc.at_css(selector) : @doc

          return nil unless element

          processors = field_def[:processors] || []

          case field_def[:type]
          when :text
            value = element.text
            element_ref = element
            processors.each do |p|
              if p == :remove_span_elements || p == :find_description_node || p == :strip_inner_style
                element_ref = apply_processor(p, value, element_ref)
                value = element_ref.text if element_ref.respond_to?(:text)
              else
                value = apply_processor(p, value, element_ref)
              end
            end
            value
          when :url
            attr = field_def[:attribute] || "href"
            value = element[attr]
            processors.each { |p| value = apply_processor(p, value, element) }
            # Always clean Google URLs
            Processors.clean_google_url(value) if value
          when :date
            value = element.text
            processors.each { |p| value = apply_processor(p, value, element) }
            value
          else
            nil
          end
        end

        def apply_processor(processor_name, value, element = nil)
          case processor_name
          when :text
            element ? Processors.text(element) : value
          when :clean_text
            Processors.clean_text(value)
          when :clean_google_url
            Processors.clean_google_url(value)
          when :parse_date
            Processors.parse_date(value)
          when :remove_span_elements
            Processors.remove_span_elements(element) || element
          when :strip_inner_style
            Processors.strip_inner_style(element) || element
          when :extract_number
            Processors.extract_number(value)
          when :normalize_number
            Processors.normalize_number(value)
          when :normalize_number_with_decimals
            Processors.normalize_number(value, decimals: true)
          when :extract_score_from_text
            Processors.extract_score_from_text(value)
          when :extract_count_from_text
            Processors.extract_count_from_text(value)
          when :extract_rating_slices
            Processors.extract_rating_slices(value)
          when :find_description_node
            find_description_text_node(element) || element
          when :extract_from_ping_if_needed
            extract_from_ping_if_needed(value, element) || value
          when :take_first
            value.is_a?(Array) && value.any? ? value[0] : nil
          when :take_second
            value.is_a?(Array) && value.length > 1 ? value[1] : nil
          when :extract_title_with_fallback
            extract_title_with_fallback(element)
          when :extract_query_from_search_url
            Processors.extract_query_from_search_url(value)
          when :downcase
            value.is_a?(String) ? value.downcase : value
          else
            value
          end
        end

        def find_description_text_node(element)
          allowed = [ "r0bn4c rQMQod" ]
          element.reverse_each.find do |node|
            node.children.all? do |child|
              child.text? || (child.element? && child.name == "span" &&
                (child["class"].nil? || child["class"].strip.empty? || allowed.include?(child["class"])))
            end
          end
        end

        def extract_from_ping_if_needed(href, element)
          return href unless href&.start_with?("javascript")
          element["ping"]&.split(" ")&.first
        end

        def extract_title_with_fallback(element)
          special = element.at_css(".qXOWAb")
          text = special&.text&.strip
          text && !text.empty? ? text : element.text
        end

        def extract_components
          return unless @matched_variant

          @matched_variant[:components].each do |field_name, component_def|
            case component_def[:type]
            when :has_one
              @data[field_name] = extract_component(component_def[:component], single: true)
            when :has_many
              @data[field_name] = extract_component(component_def[:component], single: false)
            end
          end
        end

        def extract_component(component_name, single: false)
          variants = @registry.get_component_variants(component_name)
          return (single ? nil : []) if variants.empty?

          if single
            # Try each variant until one matches
            variants.each do |variant|
              element = @doc.at_css(variant[:match])
              next unless element

              data = extract_component_data(element, variant)
              return data if data
            end
            nil
          else
            # Collect all matches across all variants
            results = []
            variants.each do |variant|
              elements = @doc.css(variant[:match])
              elements.each do |element|
                data = extract_component_data(element, variant)
                results << data if data
              end
            end
            results
          end
        end

        def extract_component_data(element, variant)
          data = {}
          variant[:fields].each do |field_name, field_def|
            value = extract_component_field(element, field_def)
            data[field_name] = value unless value.nil?
          end

          # Use configured model class if available
          if variant[:model_class]
            model_class = variant[:model_class]

            # Check if we have minimum required data before instantiating
            # For ratings, need at least score or number_of_ratings
            if model_class == SerpParser::Models::OrganicResults::Rating
              return nil unless data[:score] || data[:number_of_ratings]
            # For sitelinks, need at least title or url
            elsif model_class == SerpParser::Models::OrganicResults::SiteLink
              return nil unless data[:title] || data[:url]
            # For related searches, need a query
            elsif model_class == SerpParser::Models::RelatedSearch
              return nil unless data[:query] && !data[:query].to_s.strip.empty?
            # For FAQ citations, need a non-internal URL
            elsif model_class == SerpParser::Models::FaqCitation
              return nil unless data[:url] && !data[:url].to_s.start_with?("/")
            # For AI citations, need a non-internal URL
            elsif model_class == SerpParser::Models::AiCitation
              return nil unless data[:url] && !data[:url].to_s.start_with?("/")
            end

            model_class.new(**data)
          else
            # Fallback: return raw data if no model configured
            data
          end
        end

        def extract_component_field(element, field_def)
          selector = field_def[:selector]
          target = selector && selector != "." ? element.at_css(selector) : element

          return nil unless target

          processors = field_def[:processors] || []

          case field_def[:type]
          when :text
            # Check if first processor needs the element itself
            if processors.first == :extract_title_with_fallback
              value = extract_title_with_fallback(target)
              # Process remaining processors
              processors[1..-1].each { |p| value = apply_processor(p, value, target) }
            else
              value = target.text
              processors.each { |p| value = apply_processor(p, value, target) }
            end
            value
          when :url
            attr = field_def[:attribute] || "href"
            value = target[attr]
            processors.each { |p| value = apply_processor(p, value, target) }
            # Always clean Google URLs for sitelinks
            Processors.clean_google_url(value) if value
          else
            target.text
          end
        end
      end
    end
  end
end
