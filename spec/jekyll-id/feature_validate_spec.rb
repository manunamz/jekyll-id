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
  # path to file
  let(:has_id_rel_path)              { fixtures_dir(has_id.relative_path) }
  # file
  let(:has_id_md)                    { File.read(has_id_rel_path) }

  before(:each) do
    site.reset
    site.process
  end

  after(:each) do
    # cleanup _site/ dir
    FileUtils.rm_rf(Dir["#{site_dir()}"])
  end

  context "VALIDATE ID" do

    it "leaves original id untouched" do
      # document data
      expect(has_id.data['id']).to eq("3b8abac659")
      # file frontmatter
      expect(has_id_md).to include("---\nid: 3b8abac659")
    end

  end
      
end
