module SerpParser
  module Dsl
    class Builder
      attr_reader :registry

      def initialize
        @registry = Registry.new
        @current_component = nil
        @current_element = nil
        @current_variant = nil
      end

      def component(name, &block)
        @current_component = name
        instance_eval(&block) if block
        @current_component = nil
      end

      def element(name, &block)
        @current_element = name
        instance_eval(&block) if block
        @current_element = nil
      end

      def variant(name, meta: {}, &block)
        @current_variant = {
          name: name,
          meta: meta,
          fields: {},
          components: {},
          container: nil,
          match: nil,
          required_children: []
        }
        instance_eval(&block) if block
        variant_def = @current_variant.dup

        if @current_component
          @registry.add_component_variant(@current_component, variant_def)
        elsif @current_element
          @registry.add_element_variant(@current_element, variant_def)
        end

        @current_variant = nil
      end

      def container(selector)
        @current_variant[:container] = selector
      end

      def match(selector)
        @current_variant[:match] = selector
      end

      def text(field_name, selector = nil, **options)
        @current_variant[:fields][field_name] = {
          type: :text,
          selector: selector,
          processors: options[:processors] || [ :text, :clean_text ]
        }
      end

      def url(field_name, selector = nil, **options)
        attr = options[:attribute] || "href"
        @current_variant[:fields][field_name] = {
          type: :url,
          selector: selector,
          attribute: attr,
          processors: options[:processors] || [ :url, :clean_google_url ]
        }
      end

      def date(field_name, selector = nil, **options)
        @current_variant[:fields][field_name] = {
          type: :date,
          selector: selector,
          processors: options[:processors] || [ :text, :parse_date ]
        }
      end

      def has_one(component_name, **options)
        field_name = options[:as] || component_name
        @current_variant[:components][field_name] = {
          type: :has_one,
          component: component_name
        }
      end

      def has_many(component_name, component: nil, **options)
        field_name = options[:as] || component_name
        component_name = component if component
        @current_variant[:components][field_name] = {
          type: :has_many,
          component: component_name
        }
      end

      def required_children(selectors)
        @current_variant[:required_children] = Array(selectors)
      end
    end

    class Registry
      attr_reader :elements, :components

      def initialize
        @elements = {}
        @components = {}
      end

      def add_element_variant(element_name, variant)
        @elements[element_name] ||= []
        @elements[element_name] << variant
      end

      def add_component_variant(component_name, variant)
        @components[component_name] ||= []
        @components[component_name] << variant
      end

      def get_element_variants(element_name)
        @elements[element_name] || []
      end

      def get_component_variants(component_name)
        @components[component_name] || []
      end
    end
  end
end
