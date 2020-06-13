module ADT
  class Column
    extend Forwardable

    class LengthError < ADT::Error; end
    class NameError < ADT::Error; end
    
    attr_reader :name, :type, :length

    def_delegator :type_cast_class, :type_cast

    TYPE_CAST_CLASS = {
      1 => ADT::ColumnType::Boolean,
      3 => ADT::ColumnType::Date,
      4 => ADT::ColumnType::String,
      11 => ADT::ColumnType::Integer,
      14 => ADT::ColumnType::DateTime,
      17 => ADT::ColumnType::CurDouble
    }.freeze
    TYPE_CAST_CLASS.default = ADT::ColumnType::String
    TYPE_CAST_CLASS.freeze

    # Initialize a new ADT::Column
    #
    # @param [String] name
    # @param [String] type
    # @param [Integer] length
    def initialize(name, type, length)
      @name = clean(name)
      @type = type
      @length = length

      validate_length
      validate_name
    end

    # Return the flag to decode the data
    #
    # @param [Integer] length
    def flag(length = 0)
      flag = type_cast_class.flag
      return flag + length.to_s if flag.eql? 'A'

      flag
    end

    # Returns a Hash with :name, :type, :length, and :decimal keys
    #
    # @return [Hash]
    def to_hash
      {name: name, type: type, length: length}
    end

    # Underscored name
    #
    # This is the column name converted to underscore format.
    # For example, MyColumn will be returned as my_column.
    #
    # @return [String]
    def underscored_name
      @underscored_name ||= begin
        name.gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
      end
    end

    private

    def clean(value) # :nodoc:
      truncated_value = value.strip.partition("\x00").first
      truncated_value.gsub(/[^\x20-\x7E]/, '')
    end

    def validate_length # :nodoc:
      raise LengthError, 'field length must be 0 or greater' if length < 0
    end

    def validate_name # :nodoc:
      raise NameError, 'column name cannot be empty' if @name.empty?
    end

    def type_cast_class # :nodoc:
      @type_cast_class ||= begin
        klass = @length == 0 ? ColumnType::Nil : TYPE_CAST_CLASS[type]
        klass.new
      end
    end
  end
end
