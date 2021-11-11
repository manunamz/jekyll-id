# frozen_string_literal: true

require "jekyll-id"

RSpec.describe(Jekyll::ID::Generator) do
  let(:config) do
    Jekyll.configuration(
      config_overrides.merge(
        "collections"          => { "invalid_empty" => { "output" => true } },
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
  let(:has_no_id)                    { find_by_title(site.collections["invalid_empty"].docs, "Has No ID") }
  # path to file
  let(:has_no_id_rel_path)           { fixtures_dir(has_no_id.relative_path) }
  # file
  let(:has_no_id_md)                 { File.read(has_no_id_rel_path) }

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

  context "POPULATE ID" do

    context "lax (not strict)" do
      
      it "populates a new id" do
        # document data
        expect(has_no_id.data['id']).to_not be_nil
        # file frontmatter
        expect(has_no_id_md).to include("---\nid: ")
      end

    end

    context "strict" do
      let(:config_overrides)  { { 'ids' => { 'format' => { 'alpha' => '1234567890abcdef', 'size' => 10 } } } }

      it "populates a new id of desired format" do
        expect(has_no_id.data['id']).to_not be_nil
        # file frontmatter
        expect(has_no_id_md).to include("---\nid: ")
      end

      it "with desired 'alpha' setting" do
        id_chars_all_in_alpha = has_no_id.data['id'].chars.all? { |char| '1234567890abcdef'.include?(char) }
        expect(id_chars_all_in_alpha).to be_truthy
      end

      it "with desired 'size' setting" do
        expect(has_no_id.data['id'].size).to eq(10)
      end
    
    end

  end
      
end
