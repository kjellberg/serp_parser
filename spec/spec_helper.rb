require "serp_parser"
require "json"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Helper to show only differences between actual and expected JSON
def compare_json(actual, expected, path = "")
  differences = []

  if actual.is_a?(Hash) && expected.is_a?(Hash)
    all_keys = (actual.keys + expected.keys).uniq
    all_keys.each do |key|
      current_path = path.empty? ? key.to_s : "#{path}.#{key}"

      if !actual.key?(key)
        differences << "Missing in actual: #{current_path} (expected: #{expected[key].inspect})"
      elsif !expected.key?(key)
        differences << "Extra in actual: #{current_path} (value: #{actual[key].inspect})"
      else
        differences.concat(compare_json(actual[key], expected[key], current_path))
      end
    end
  elsif actual.is_a?(Array) && expected.is_a?(Array)
    max_length = [ actual.length, expected.length ].max
    max_length.times do |i|
      current_path = "#{path}[#{i}]"

      if i >= actual.length
        differences << "Missing in actual: #{current_path} (expected: #{expected[i].inspect})"
      elsif i >= expected.length
        differences << "Extra in actual: #{current_path} (value: #{actual[i].inspect})"
      else
        differences.concat(compare_json(actual[i], expected[i], current_path))
      end
    end
  elsif actual != expected
    differences << "Mismatch at #{path}: expected #{expected.inspect}, got #{actual.inspect}"
  end

  differences
end

RSpec.shared_examples "matches the expected output" do |file_path|
  context "parsing #{File.basename(file_path)}" do
    let(:html) { File.read("spec/files/#{file_path}.html", encoding: 'UTF-8') }
    let(:expected_output) { JSON.parse(File.read("spec/files/#{file_path}.json", encoding: 'UTF-8')) }
    let(:parser) { described_class.new(html) }

    it "initializes without error" do
      expect { parser }.not_to raise_error
    end

    it "matches expected output in #{File.basename(file_path, '.html')}.json" do
      actual_output = parser.to_h
      # Convert keys to strings for comparison
      actual_output = actual_output.transform_keys(&:to_s)

      differences = compare_json(actual_output, expected_output)

      if differences.any?
        # Save actual output to a file for inspection
        actual_file = "spec/files/#{file_path}.actual.json"
        File.write(actual_file, JSON.pretty_generate(actual_output))

        message = "\n" + "="*80 + "\n"
        message += "JSON Differences Found:\n"
        message += "="*80 + "\n"
        differences.each_with_index do |diff, i|
          message += "#{i + 1}. #{diff}\n"
        end
        message += "\n" + "="*80 + "\n"
        message += "Full actual output saved to: #{actual_file}\n"
        message += "="*80 + "\n"

        fail message
      end
    end
  end
end
