module Doure
  module Filterable
    def filter_class(klass)
      @filter_class = klass
    end

    def filter(params = {})
      @filter_class or raise "No filter model specified"
      @filter_class.new(self).apply(params)
    end
  end
end