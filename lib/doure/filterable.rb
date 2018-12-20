# frozen_string_literal: true

module Doure
  module Filterable
    NoFilter = Class.new(StandardError)

    def filter_class(klass)
      @filter_class = klass
    end

    def filter(params = {})
      @filter_class or raise NoFilter, "No filter model specified"
      @filter_class.new(self).apply(params)
    end
  end
end