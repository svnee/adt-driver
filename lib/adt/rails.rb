module ADT
  # The Model module is mixin for the Table class
  # It provides generators for imported tables
  module Rails
    def model
      "class #{camelize(name)} < ApplicationRecord
        self.table_name = '#{name}'
      end"
    end

    private

    def camelize(string, uppercase_first_letter = true)
      string = if uppercase_first_letter
        string.sub(/^[a-z\d]*/, &:capitalize)
      else
        string.sub(/^(?:(?=\b|[A-Z_])|\w)/, &:downcase)
      end
      string.gsub(%r{(?:_|(/))([a-z\d]*)}) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
    end
  end
end
