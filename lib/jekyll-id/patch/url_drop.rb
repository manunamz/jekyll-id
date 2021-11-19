# frozen_string_literal: true

require "jekyll"

module Jekyll
  module Drops

    class UrlDrop
      
      def id
        # 'to_s' is necessary for scenarios where all ID chars are numbers
        @obj.data['id'].to_s
      end

    end

  end
end
