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
      if uppercase_first_letter
        string = string.sub(/^[a-z\d]*/) { |match| match.capitalize }
      else
        string = string.sub(/^(?:(?=\b|[A-Z_])|\w)/) { |match| match.downcase }
      end
      string.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }.gsub("/", "::")
    end
  end
end