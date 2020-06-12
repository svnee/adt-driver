module ADT
  class Header
    attr_reader :record_count
    attr_reader :data_offset
    attr_reader :record_length
    attr_reader :column_count

    def initialize(data)
      @data = data
      @record_count, @data_offset, @record_length = unpack_header
      @column_count = (@data_offset-400)/200
    end

    def unpack_header
      @data.unpack("@24 I x4 I I")
    end
  end
end