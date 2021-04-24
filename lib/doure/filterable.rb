# frozen_string_literal: true

module Doure
  module Filterable
    NoFilter = Class.new(StandardError)
    extend ActiveSupport::Concern

    class_methods do
      def filter_class(klass)
        self.doure_filter_klass = klass
      end
    end

    included do
      cattr_accessor :doure_filter_klass

      scope :doure_filter, lambda { |params = {}|
        doure_filter_klass || raise(NoFilter, "No filter model specified")
        doure_filter_klass.new(self).apply(params)
      }
    end
  end
end
