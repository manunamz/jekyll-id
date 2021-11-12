# frozen_string_literal: true
require 'jekyll'
require 'nanoid'

require_relative "jekyll-id/patch/url_drop"
require_relative "jekyll-id/version"

module Jekyll
  module ID

    class Generator < Jekyll::Generator
      priority :highest
      
      # CONVERTER_CLASS = Jekyll::Converters::Markdown
      # config
      CONFIG_KEY = "ids"
      ENABLED_KEY = "enabled"
      EXCLUDE_KEY = "exclude"
      FORMAT_KEY = "format"
      ALPHA_KEY = "alpha"
      SIZE_KEY = "size"

      def initialize(config)
        @config ||= config
        @testing = config['testing'].nil? ? false : config['testing']
      end

      def generate(site)
        @site = site
        @yesall = false # for writing strict ids to file frontmatter

        # 'instace_of?' is used to make sure we don't accidentally suck in static files that are stored in document directoreis
        # md_docs = @site.documents.filter { |d| (d.instance_of? Jekyll::Document) && (d.type == :posts || d.type == :entries || d.type == :states || d.type == :books) }
        md_docs = @site.documents
        md_docs.each do |cur_doc|
          # validation and sanitization
          prep_doc(cur_doc)
        end
      end

      def prep_doc(doc)
        # 
        # ID: if using strict ids, make sure ids are proper nano id format
        # 
        # generate
        if !doc.data.keys.include?('id')
          new_id = self.generate_id
          Jekyll.logger.info("\n> Generate frontmatter ID: '#{new_id}' for #{doc.inspect}.")
          if !@testing && !@yesall
            Jekyll.logger.info("Is that ok?")
            Jekyll.logger.info("(yes, no, or yesall)")
            cont = gets
            if cont.strip == "yesall"
              @yesall = true 
            end
          end
          if @testing || @yesall || cont.strip == "yes"
            lines = IO.readlines(doc.path)
            lines.delete_if { |l| l.include?("id: #{doc.data['id']}") }
            lines.insert(1, "id: #{new_id}\n")
            File.open(doc.path, 'w') do |file|
              file.puts lines
            end
            doc.data['id'] = new_id
          end
        end
        # verify format
        doc.data['id'] = doc.data['id'].to_s
        if strict_id? && !(doc.data['id'] =~ format)
          new_id = self.generate_id
          Jekyll.logger.info("\n> Replacing #{doc.inspect}'s frontmatter\n> ID:'#{doc.data['id']}' with new-ID:'#{new_id}'.")
          if !@testing && !@yesall
            Jekyll.logger.info("> Is that ok?")
            Jekyll.logger.info("> (yes, no, or yesall)")
            cont = gets
            if cont.strip == "yesall"
              @yesall = true 
            end
          end
          if @testing || @yesall || cont.strip == "yes"
            lines = IO.readlines(doc.path)
            lines.delete_if { |l| l.include?("id: #{doc.data['id']}") }
            lines.insert(1, "id: #{new_id}\n")
            File.open(doc.path, 'w') do |file|
              file.puts lines
            end
            doc.data['id'] = new_id
          end
        end
      end

      def generate_id
        return Nanoid.generate if !self.strict_id?
        return Nanoid.generate(size: @site.config['ids']['format']['size'], alphabet: @site.config['ids']['format']['alpha'])
      end

      def format
        return /^[#{@site.config['ids']['format']['alpha']}]{#{@site.config['ids']['format']['size']}}$/
      end

      def strict_id?
        if @site.config.keys.include?('ids')
          if @site.config['ids'].keys.include?('format')
            if @site.config['ids']['format'].keys.include?('alpha') && @site.config['ids']['format'].include?('size')
              return true
            end
          end
        end
        return false
      end

      # def generate(site)

    end

  end
end
