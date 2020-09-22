module ADT
  # The Schema module is mixin for the Table class
  module Schema
    FORMATS = [:activerecord, :json].freeze

    OTHER_DATA_TYPES = {
      1 => ':boolean',
      3 => ':date',
      6 => ':binary',
      10 => ':decimal, precision: 6',
      11 => ':integer',
      12 => ':integer',
      14 => ':datetime',
      15 => ':integer', # In reality an "autoinc" but we don't deal with that
      17 => ':decimal, precision: 6'
    }.freeze

    # Generate an ActiveRecord::Schema
    #
    # ADT data types are converted to generic types as follows:
    # - Number columns with no decimals are converted to :integer
    # - Number columns with decimals are converted to :decimal
    # - Date columns are converted to :date
    # - DateTime columns are converted to :datetime
    # - Logical columns are converted to :boolean
    # - Binary columns are converted to :text
    # - Character columns are converted to :string and the :limit option is set
    #   to the length of the character column
    #
    # Example:
    #   create_table "mydata" do |t|
    #     t.column :name, :string, :limit => 30
    #     t.column :last_update, :datetime
    #     t.column :is_active, :boolean
    #     t.column :age, :integer
    #     t.column :notes, :text
    #   end
    #
    # @param [Symbol] format Valid options are :activerecord and :json
    # @return [String]
    def schema(format = :activerecord, table_only = false)
      schema_method_name = schema_name(format)
      send(schema_method_name, table_only)
    rescue NameError
      raise ArgumentError, ":#{format} is not a valid schema. Valid schemas are: #{FORMATS.join(', ')}."
    end

    def schema_name(format) # :nodoc:
      "#{format}_schema"
    end

    def activerecord_schema(_table_only = false) # :nodoc:
      s = "ActiveRecord::Schema.define do\n"
      s << "  create_table \"#{name}\"#{', {id: false}' if columns.map(&:downcase).include?('id')} do |t|\n"
      columns.each do |column|
        s << "    t.column #{activerecord_schema_definition(column)}"
      end
      s << "  end\nend"
      s
    end

    def json_schema(_table_only = false) # :nodoc:
      columns.map(&:to_hash).to_json
    end

    # ActiveRecord schema definition
    #
    # @param [ADT::Column]
    # @return [String]
    def activerecord_schema_definition(column)
      "\"#{column.underscored_name}\", #{schema_data_type(column)}\n"
    end

    def schema_data_type(column) # :nodoc:
      case column.type.to_s
      when *%w[1 3 6 10 11 12 14 15 17]
        OTHER_DATA_TYPES[column.type]
      else
        string_data_format(column)
      end
    end

    def string_data_format(column)
      ":string, :limit => 255" ##{column.length}
    end
  end
end
