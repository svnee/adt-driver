module ADT
  class FileNotFoundError < StandardError
  end

  # ADT::Table is the primary interface to a single ADT file and provides
  # methods for enumerating and searching the records.
  class Table
    extend Forwardable

    ADT_HEADER_SIZE = 400

    def_delegator :header, :record_count
    def_delegator :header, :data_offset
    def_delegator :header, :record_length
    def_delegator :header, :column_count

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

    # Retrieve a record by index number.
    # The record will be nil if it has been deleted, but not yet pruned from
    # the database.
    #
    # @param [Integer] index
    # @return [ADT::Record, NilClass]
    def record(index)
      seek_to_record(index)
      return nil if deleted_record?

      ADT::Record.new(@data.read(record_length), columns)
    end

    # All columns
    #
    # @return [Array]
    def columns
      @columns ||= build_columns
    end

    private

    def build_columns # :nodoc:
      safe_seek do
        #skip past header to get to column information
        @data.seek(ADT_HEADER_SIZE)
        # column names are the first 128 bytes and column info takes up the last 72 bytes.  
        # byte 130 contains a 16-bit column type
        # byte 136 contains a 16-bit length field
        @columns = []
        column_count.times do
          name, type, length = @data.read(200).unpack('A128 x S x4 S')
          if length > 0
            @columns << ADT::Column.new(name.strip, type, length)
          end
        end
        # Reset the column count in case any were skipped
        @column_count = @columns.size
        
        @columns
      end
    end

    def deleted_record? # :nodoc:
      flag = @data.read(1)
      flag ? flag.unpack1('a') == '*' : true
    end

    def header # :nodoc:
      @header ||= safe_seek do
        @data.seek(0)
        Header.new(@data.read(ADT_HEADER_SIZE))
      end
    end

    def open_data(data) # :nodoc:
      File.open(data, 'rb')
    rescue Errno::ENOENT
      raise ADT::FileNotFoundError, "file not found: #{data}"
    end

    def safe_seek # :nodoc:
      original_pos = @data.pos
      yield.tap { @data.seek(original_pos) }
    end

    def seek(offset) # :nodoc:
      @data.seek(data_offset + offset)
    end

    def seek_to_record(index) # :nodoc:
      seek(index * record_length)
    end
  end
end