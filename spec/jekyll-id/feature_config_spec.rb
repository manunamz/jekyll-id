# frozen_string_literal: true

RSpec.describe Jekyll::ID do

  it "has a version number" do
    expect(Jekyll::ID::VERSION).not_to be nil
  end

end

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
  let(:config_overrides)     { {} }

  let(:site)                 { Jekyll::Site.new(config) }
  let(:doc_root)             { find_by_title(site.collections["docs"].docs, "Root") }

  # makes markdown tests work
  subject                    { described_class.new(site.config) }

  before(:each) do
    site.reset
    site.process
  end

  after(:each) do
    # cleanup _site/ dir
    FileUtils.rm_rf(Dir["#{site_dir()}"])
  end

  # context "configs options" do

  #   it "are saved" do
  #     expect(subject.config).to eql(site.config)
  #   end

  #   context "'disable' turns off the plugin" do
  #     let(:config_overrides) { { "ids" => { "enabled" => false } } }

  #     it "does not process ids" do
  #       expect(site).to be_nil
  #     end

  #   end

  #   context "'exclude' does not process jekyll types that are listed" do
  #     let(:config_overrides) { { "ids" => { "exclude" => [ "pages", "posts" ] } } }

  #     it "does not process name.spaces for those types" do
  #       expect(doc_root['children']).to_not include("/one-page/")
  #       expect(doc_root['children']).to_not include("/2020/12/08/one-post/")
  #     end

  #   end

  # end

end
