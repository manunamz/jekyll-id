# frozen_string_literal: true

require "jekyll"

module Jekyll
  module Drops

    class UrlDrop
      
      def id
        @obj.data['id']
      end

    end

  end
end
