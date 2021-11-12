# frozen_string_literal: true

require "jekyll-id"

RSpec.describe(Jekyll::ID::Generator) do
  let(:config) do
    Jekyll.configuration(
      config_overrides.merge(
        "collections"          => { "valid" => { "output" => true } },
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

  before(:each) do
    site.reset
    site.process
  end

  after(:each) do
    # cleanup _site/ dir
    FileUtils.rm_rf(Dir["#{site_dir()}"])
  end

  context "PERMALINKs" do

    context "in 'default' frontmatter 'permalink' option, support ':id' key" do
      let(:config_overrides) { { "defaults" => [ { 
        "scope" => { "type" => "valid" }, 
        "values" => { "permalink" => "/valid/:id/" } 
      } ] } }

      it "sets 'url' with valid id" do
        expect(has_id.url).to eq('/valid/3b8abac659/')
      end

    end

  end

end
