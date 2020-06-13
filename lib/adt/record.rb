module ADT
  # An instance of ADT::Record represents a row in the ADT file
  class Record
    # Initialize a new DBF::Record
    #
    # @data [String, StringIO] data
    # @columns [Column]
    def initialize(data, columns)
      @data = ::StringIO.new(data)
      @data.seek(4) # We don't know what the first 5 bytes are
      @columns = columns
    end

    # Record attributes
    #
    # @return [Hash]
    def attributes
      @attributes ||= Hash[attribute_map]
    end

    # Maps a row to an array of values
    #
    # @return [Array]
    def to_a
      @columns.map { |column| attributes[column.name] }
    end

    # Do all search parameters match?
    #
    # @param [Hash] options
    # @return [Boolean]
    def match?(options)
      options.all? { |key, value| self[key] == value }
    end

    # Reads attributes by column name
    #
    # @param [String, Symbol] key
    def [](name)
      key = name.to_s
      if attributes.key?(key)
        attributes[key]
      elsif index = underscored_column_names.index(key)
        attributes[@columns[index].name]
      end
    end

    # Equality
    #
    # @param [ADT::Record] other
    # @return [Boolean]
    def ==(other)
      other.respond_to?(:attributes) && other.attributes == attributes
    end

    private

    def attribute_map # :nodoc:
      @columns.map { |column| [column.name, init_attribute(column)] }
    end

    def get_data(column) # :nodoc:
      @data.read(column.length)
    end

    def init_attribute(column) # :nodoc:
      value = get_data(column)
      column.type_cast(value)
    end

    def method_missing(method, *args) # :nodoc:
      if (index = underscored_column_names.index(method.to_s))
        attributes[@columns[index].name]
      else
        super
      end
    end

    def respond_to_missing?(method, *) # :nodoc:
      underscored_column_names.include?(method.to_s) || super
    end

    def underscored_column_names # :nodoc:
      @underscored_column_names ||= @columns.map(&:underscored_name)
    end
  end
end
