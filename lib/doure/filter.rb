module Doure
  class Filter
    class_attribute :mapping
    self.mapping = ActiveSupport::HashWithIndifferentAccess.new

    class << self
      def inherited(subclass)
        subclass.mapping = self.mapping.dup
      end

      def filter(name, opts = {}, &apply)
        mapping[name] = [opts, apply]
      end

      def eq_filter(name, opts = {})
        block = lambda { |s, value| s.where(name => value) }
        mapping["#{name}_eq"] = [opts, block]
      end

      def not_eq_filter(name, opts = {})
        block = lambda { |s, value| s.where.not(name => value) }
        mapping["#{name}_not_eq"] = [opts, block]
      end

      def cont_filter(name, opts = {})
        block = lambda { |s, value| s.where(s.arel_table[name].matches("%#{value}%")) }
        mapping["#{name}_cont"] = [opts, block]
      end

      def present_filter(name, opts = {})
        block = lambda { |s, value| value ? s.where.not(name => nil) : s.where(name => nil) }
        mapping["#{name}_present"] = [opts.merge(as: :boolean), block]
      end

      %w(gt lt gteq lteq).each do |comparison|
        define_method("#{comparison}_filter") do |name, opts = {}|
          block = lambda { |s, value| s.where(s.arel_table[name].send(comparison, value)) }
          mapping["#{name}_#{comparison}"] = [opts, block]
        end
      end
    end

    def initialize(scope)
      @scope = scope.all # Force AR:Relation from possible AR:Base
    end

    def apply(params = {})
      params.each do |key, value|
        if !value.nil? && value != "" && mapping.key?(key)
          casted_value = mapping[key][0].key?(:as) ? cast_value(mapping[key][0][:as], value) : value
          @scope = mapping[key][1].call(@scope, casted_value)
        end
      end

      @scope
    end

    private

    def cast_value(type, value)
      case type
        when :boolean
          ActiveRecord::Type::Boolean.new.cast(value)
        when :date
          (String === value) ? Date.parse(value) : value
        when :datetime
          (String === value) ? Time.parse(value) : value
        else
          value
      end
    end
  end
end