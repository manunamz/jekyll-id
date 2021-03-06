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
        @yesall = false
        @noall = false

        markdown_converter = site.find_converter_instance(CONVERTER_CLASS)
        # filter docs based on configs
        docs = []
        docs += site.docs_to_write.filter { |d| !exclude?(d.type) }
        @md_docs = docs.filter { |doc| markdown_converter.matches(doc.extname) }
        if @md_docs.nil? || @md_docs.empty?
          Jekyll.logger.warn("Jekyll-ID: No documents to process.")
        end

        @md_docs.each do |doc|
          prep_id(doc)
        end
      end

      # helpers

      def prep_id(doc)
        return if @noall
        has_id = doc.data.keys.include?('id')
        # 0   == is strict
        # nil == isn't strict
        is_strict_id = (alpha_formatted?(doc.data['id'].to_s) && size_formatted?(doc.data['id'].to_s))
        # cases where we would want to generate a new id
        case_1 = !has_id                   # no id exists
        case_2 = strict? && !is_strict_id  # id isn't formatted properly
        if (case_1 || case_2)
          new_id = generate_id.to_s 
          # populate missing id
          if case_1
            Jekyll.logger.info("\n> Generate frontmatter ID for \n> #{doc.inspect}\n>with new ID: '#{new_id}'")
          # replace invalid format id
          elsif case_2
            Jekyll.logger.info("\n> Replace frontmatter ID for:\n> #{doc.inspect}\n> from:'#{doc.data['id']}'\n> to:'#{new_id}'")
          # um...
          else
            Jekyll.logger.warn("Jekyll-ID: Invalid ID case")
          end
          resp = request if !@testing
          if @testing || ((@yesall || resp == "yes") && !@noall)
            write_id(doc, new_id)
            doc.data['id'] = new_id
          end
        end
      end

      def generate_id
        has_size  = (size.size != 0)
        has_alpha = (alpha.size != 0)
        return Nanoid.generate                              if !strict?
        return Nanoid.generate(size: size, alphabet: alpha) if has_size && has_alpha
        return Nanoid.generate(size: size)                  if has_size && !has_alpha
        return Nanoid.generate(alphabet: alpha)             if !has_size && has_alpha
      end

      def request
        if !@yesall && !@noall
          Jekyll.logger.info("\n> Is that ok?")
          Jekyll.logger.info("> (yes, no, yesall, or noall)")
          cont = gets
          if cont.strip == "yesall"
            @yesall = true
            Jekyll.logger.info("> Handle all IDs...")
          elsif cont.strip == "noall"
            @noall = true
            Jekyll.logger.info("> Leaving all IDs alone...")
          elsif cont.strip == "yes" 
            Jekyll.logger.info("> Handling ID...")
          elsif cont.strip == "no"
            Jekyll.logger.info("> Leaving ID alone...")
          else
            Jekyll.logger.error("Jekyll-ID: Invalid response. Skipping...")
          end
          return cont.strip
        end
      end

      def write_id(doc, id) 
        lines = IO.readlines(doc.path)
        lines.delete_if { |l| l.include?("id: #{doc.data['id']}") }
        lines.insert(1, "id: #{id}\n")
        File.open(doc.path, 'w') do |file|
          file.puts lines
        end
      end

      # descriptor methods
      
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

      # 'getters'

      def alpha
        return option_format(ALPHA_KEY).nil? ? '' : option_format(ALPHA_KEY)
      end

      def size
        return option_format(SIZE_KEY).nil? ? '' : option_format(SIZE_KEY)
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
