# frozen_string_literal: true

require "jekyll-id"

RSpec.describe Jekyll::ID do

  it "has a version number" do
    expect(Jekyll::ID::VERSION).not_to be nil
  end

end

RSpec.describe(Jekyll::ID::Generator) do
  let(:config) do
    Jekyll.configuration(
      config_overrides.merge(
        "collections"          => { 
          "valid"          => { "output" => true },
          "invalid_empty"  => { "output" => true },
          "invalid_format" => { "output" => true },
        },
        "permalink"            => "pretty",
        "skip_config_files"    => false,
        "source"               => fixtures_dir,
        "destination"          => site_dir,
        "url"                  => "garden.testsite.com",
        "testing"              => true,
        # "baseurl"              => "",
      )
    )
  end
  let(:config_overrides)             { {} }

  let(:site)                         { Jekyll::Site.new(config) }

  # jekyll document
  let(:has_id)                       { find_by_title(site.collections["valid"].docs, "Has ID") }
  let(:has_no_id)                    { find_by_title(site.collections["invalid_empty"].docs, "Has No ID") }
  let(:has_unformatted_id)           { find_by_title(site.collections["invalid_format"].docs, "Has Unformatted ID") }
  # path to file
  let(:has_no_id_rel_path)           { fixtures_dir(has_no_id.relative_path) }

  # for testing configs exist
  subject { described_class.new(site.config) }

  before(:each) do
    site.reset
    site.process
  end

  after(:each) do
    # cleanup _site/ dir
    FileUtils.rm_rf(Dir["#{site_dir()}"])
    # cleanup generated ids
    File.open(has_no_id_rel_path, 'w') { |f| f.write("---\ntitle: Has No ID\n---\n\nSome text.\n") }
  end

  context "CONFIG options" do

    it "are saved" do
      expect(subject.config).to eql(site.config)
    end

    context "'disable' turns off the plugin" do
      let(:config_overrides) { { "ids" => { "enabled" => false } } }

      it "does not process ids" do
        expect(has_id.data['id']).to eq('3b8abac659')
        expect(has_no_id.data.keys).to_not include('id')
        expect(has_unformatted_id.data['id']).to eq('invalid-format')
      end

    end

    context "'exclude' does not process jekyll doc types that are listed" do
      let(:config_overrides) { { "ids" => { "exclude" => [ "invalid_format" ] } } }

      it "does not process ids for those types" do
        expect(has_unformatted_id.data['id']).to eq('invalid-format')
      end

      it "does process ids for unexcluded types" do
        expect(has_no_id.data.keys).to include('id')
      end

    end

  end

end
