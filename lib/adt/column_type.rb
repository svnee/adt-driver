module ADT
  module ColumnType
    class Base; end

    class Nil < Base
      def type_cast(_value)
        nil
      end

      def flag
        ''
      end
    end

    class Boolean < Base
      def type_cast(value)
        value.strip != 'F'
      end

      def flag
        ''
      end
    end

    class Integer < Base
      def type_cast(value)
        return nil if value.strip.empty?

        value.unpack('L').dig(0).to_i == 2_147_483_648 ? nil : value.unpack('L').dig(0).to_i
      end

      def flag
        'i'
      end
    end

    class Date < Base
      def type_cast(value)
        int = value.unpack('L').dig(0).to_i
        int == 0 ? nil : ::Date.jd(int)
      rescue StandardError
        nil
      end

      def flag
        '?'
      end
    end

    class DateTime < Base
      def type_cast(value)
        val = value.unpack('L L')
        date = ::Date.jd(val.dig(0))
        ::Time.at(date.to_time + val.dig(1) / 1000).to_datetime
      end

      def flag
        '?'
      end
    end

    class CurDouble < Base
      def type_cast(value)
        value.unpack('D').dig(0) < 0.001 ? nil : value.unpack('D').dig(0)
      end

      def flag
        'D'
      end
    end

    class String < Base
      def type_cast(value)
        value = value.strip
        value.force_encoding('UTF-8').encode('UTF-8', undef: :replace, invalid: :replace)
      end
      
      def flag
        'A'
      end
    end
  end
end

# TYPES = {17 => 'curdouble', 4 => 'character', 10 => 'double', 11 => 'integer', 12 => 'short', 20 => 'cicharacter', 3 => 'date', 13 => 'time', 14 => 'timestamp', 15 => 'autoinc'}
# FLAGS = {'character' => 'A', 'double' => 'D', 'integer' => 'i', 'short' => 'S', 'cicharacter' => 'A', 'date' => '?', 'time' => '?', 'timestamp' => '?', 'autoinc' => 'I'}
