# frozen_string_literal: true

require "spec_helper"

describe Crystalball::ExampleGroupMap do
  subject(:example_group_map) { described_class.new(example, coverage) }

  let(:example) { double(id: "file_spec.rb:5", file_path: "file_spec.rb") }
  let(:coverage) { double }

  describe "#uid" do
    subject { example_group_map.uid }

    it { is_expected.to eq("file_spec.rb:5") }
  end

  describe "#file_path" do
    subject { example_group_map.file_path }

    it { is_expected.to eq "file_spec.rb" }
  end
end
