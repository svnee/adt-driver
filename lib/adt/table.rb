module ADT
  class FileNotFoundError < StandardError
  end

  # ADT::Table is the primary interface to a single ADT file and provides
  # methods for enumerating and searching the records.
  class Table
    extend Forwardable
    
    def_delegator :header, :record_count
    def_delegator :header, :data_offset
    def_delegator :header, :record_length

    # Opens a ADT::Table
    # Examples:
    #   # working with a file stored on the filesystem
    #   table = ADT::Table.new 'data.adt'
    #
    # @param [String] data Path to the adt file
    def initialize(data)
      @data = open_data(data)
      yield self if block_given?
    end

    # Closes the table
    #
    # @return [TrueClass, FalseClass]
    def close
      @data.close
    end

    # @return [TrueClass, FalseClass]
    def closed?
      @data.closed?
    end

    def open_data(data) # :nodoc:
      File.open(data, 'rb')
    rescue Errno::ENOENT
      raise ADT::FileNotFoundError, "file not found: #{data}"
    end
  end
end