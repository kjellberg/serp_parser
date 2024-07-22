require "serp_parser"
require "json"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec.shared_examples "matches the expected output" do |file_path|
  context "#{file_path}.html" do
    let(:html) { File.read("spec/files/#{file_path}.html") }
    let(:expected_output) { JSON.parse(File.read("spec/files/#{file_path}.json")) }
    let(:doc) { Nokogiri::HTML::DocumentFragment.parse(html) }
    let(:parser) { described_class.new(html) }
    let(:processed_data) { parser.processed_data }

    it "initializes without error" do
      expect { parser }.not_to raise_error
    end

    it "matches output in #{file_path}.json" do
      expect(processed_data.to_h).to match(expected_output)
    end
  end
end
