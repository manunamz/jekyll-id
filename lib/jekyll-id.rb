# frozen_string_literal: true
require 'jekyll'
require 'nanoid'

require_relative "jekyll-id/patch/url_drop"
require_relative "jekyll-id/version"

module Jekyll
  module ID

    class Generator < Jekyll::Generator
      priority :highest

      # for testing
      attr_reader :config
      
      CONVERTER_CLASS = Jekyll::Converters::Markdown
      # config
      CONFIG_KEY = "ids"
      ENABLED_KEY = "enabled"
      EXCLUDE_KEY = "exclude"
      FORMAT_KEY = "format"
      ALPHA_KEY = "alpha"
      SIZE_KEY = "size"

      def initialize(config)
        @config ||= config
        @testing ||= config['testing'].nil? ? false : config['testing']
      end

      def generate(site)
        return if disabled?

        @site = site
        @yesall = false # for writing strict ids to file frontmatter

        markdown_converter = site.find_converter_instance(CONVERTER_CLASS)
        # filter docs based on configs
        docs = []
        docs += site.docs_to_write.filter { |d| !exclude?(d.type) }
        @md_docs = docs.filter { |doc| markdown_converter.matches(doc.extname) }
        if @md_docs.nil? || @md_docs.empty?
          Jekyll.logger.debug("No documents to process.")
        end

        @md_docs.each do |cur_doc|
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
          new_id = generate_id
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
        
                        # 0   == is strict
                        # nil == isn't strict
        is_strict_id = (alpha_formatted?(doc.data['id']) && size_formatted?(doc.data['id']))

        if strict? && !(doc.data.keys.include?('id') && is_strict_id)
          new_id = generate_id
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
            # insert after first frontmatter "---"
            lines.insert(1, "id: #{new_id}\n")
            File.open(doc.path, 'w') do |file|
              file.puts lines
            end
            doc.data['id'] = new_id
          end
        end
      end

      # 'getters'

      def alpha
        return option_format(ALPHA_KEY).nil? ? '' : option_format(ALPHA_KEY)
      end

      def size
        return option_format(SIZE_KEY).nil? ? '' : option_format(SIZE_KEY)
      end

      # helpers
      
      def alpha_formatted?(id)
        return true if !option_format(ALPHA_KEY)
        return id.chars.all? { |char| alpha.include?(char) }
      end

      def size_formatted?(id)
        return true if !option_format(SIZE_KEY)
        return id.size == size
      end

      def strict?
        return option(FORMAT_KEY) && (option_format(SIZE_KEY) || option_format(ALPHA_KEY))
      end

      def generate_id
        has_size  = (size.size != 0)
        has_alpha = (alpha.size != 0)
        return Nanoid.generate                              if !strict?
        return Nanoid.generate(size: size, alphabet: alpha) if has_size && has_alpha
        return Nanoid.generate(size: size)                  if has_size && !has_alpha
        return Nanoid.generate(alphabet: alpha)             if !has_size && has_alpha
      end

      # config helpers

      def disabled?
        option(ENABLED_KEY) == false
      end

      def exclude?(type)
        return false unless option(EXCLUDE_KEY)
        return option(EXCLUDE_KEY).include?(type.to_s)
      end

      def option(key)
        @config[CONFIG_KEY] && @config[CONFIG_KEY][key]
      end

      def option_format(key)
        @config[CONFIG_KEY] && @config[CONFIG_KEY][FORMAT_KEY] && @config[CONFIG_KEY][FORMAT_KEY][key]
      end

    end

  end
end
