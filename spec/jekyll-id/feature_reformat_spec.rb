# frozen_string_literal: true

require "jekyll-id"

RSpec.describe(Jekyll::ID::Generator) do
  let(:config) do
    Jekyll.configuration(
      config_overrides.merge(
        "collections"          => { "docs" => { "output" => true } },
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
  let(:has_unformatted_id)           { find_by_title(site.collections["docs"].docs, "Has Unformatted ID") }
  # path to file
  let(:has_unformatted_id_rel_path)  { fixtures_dir(has_unformatted_id.relative_path) }
  # file
  let(:has_unformatted_id_md)        { File.read(has_unformatted_id_rel_path) }

  before(:each) do
    site.reset
    site.process
  end

  after(:each) do
    # cleanup _site/ dir
    FileUtils.rm_rf(Dir["#{site_dir()}"])
    # cleanup generated ids
    File.open(has_unformatted_id_rel_path, 'w') { |f| f.write("---\nid: invalid-format\ntitle: Has Unformatted ID\n---\n\nSome text.\n") }
  end

  context "REFORMAT ID" do

    context "lax (not strict)" do
      
      it "does not reformat id if one exists" do
        # document data
        expect(has_unformatted_id.data['id']).to_not be_nil
        # file frontmatter
        expect(has_unformatted_id_md).to include("---\nid: ")
        expect(has_unformatted_id_md).to include(has_unformatted_id.data['id'])
      end

    end

    context "strict" do
      let(:config_overrides)  { { 'ids' => { 'format' => { 'alpha' => '1234567890abcdef', 'size' => 10 } } } }

      it "reformats id to desired format" do
        expect(has_unformatted_id.data['id']).to_not eq("invalid-format")
        # file frontmatter
        expect(has_unformatted_id_md).to include("---\nid: ")
        expect(has_unformatted_id_md).to include(has_unformatted_id.data['id'])
      end

      it "with desired 'alpha' setting" do
        id_chars_all_in_alpha = has_unformatted_id.data['id'].chars.all? { |char| '1234567890abcdef'.include?(char) }
        expect(id_chars_all_in_alpha).to be_truthy
      end

      it "with desired 'size' setting" do
        expect(has_unformatted_id.data['id'].size).to eq(10)
      end
    
    end

  end
      
end
