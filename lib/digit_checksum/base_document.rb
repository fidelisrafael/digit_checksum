module DigitChecksum
  class BaseDocument

    CONSTANTS_MAP = [
      :root_numbers_count,
      :verify_digits_positions,
      :digits_ignore_positions,
      :division_modulo,
      :verify_digits_weights,
      :clear_number_regexp,
      :format_regexp,
      :pretty_format_mask,
      :generator_numbers,
      :document_length
    ]

    class << self
      def generate(pretty_formatted = true)
        number = append_verify_digits(generate_root_numbers)

        pretty_formatted ? pretty(number) : number
      end

      def append_verify_digits(number)
        number = normalize(number)
        verify_digits = verify_digits(number)

        obtain_verify_digits_positions.each_with_index {|position, index|
          number.insert(position + index, verify_digits.shift)
        }

        stripped_number(number.compact)
      end

      def generate_root_numbers
        root_document_digits_count.times.map { get_generator_numbers.sample }
      end

      def valid?(number)
        # remove all non digits and return an string to be matched with mask
        number = stripped_number(number)

        # if document is empty
        return false if number.nil? || number.empty?

        # if document dont match the exact size, it's invalid
        return false unless valid_length?(number)

        # remove verify digits to be verified
        verify_digits = remove_verify_digits!(number)

        # calculate the new digits based on root document number
        digits = verify_digits(number)

        verify_digits == digits
      end

      def remove_verify_digits!(number)
        number.gsub!(get_clear_number_regexp, '')

        obtain_verify_digits_positions.each_with_index.flat_map {|position, index|
          number.slice!((position - index), 1)
        }.map(&:to_i)
      end

      def obtain_verify_digits_positions
        begin
          get_verify_digits_positions
        # when value its not set
        rescue NameError => e
          default_verify_digits_position
        end
      end

      def default_verify_digits_position
        verify_digits_count.times.map {|i| root_document_digits_count + i  }
      end

      def invalid?(number)
        !valid?(number)
      end

      def verify_digits(number)
        return [] unless correct_length_based_on_first_mask?(number)

        number = normalize(number)
        division_modulo = get_division_modulo
        digits_positions = obtain_verify_digits_positions.dup
        digits = []

        get_verify_digits_weights.each_with_index do |data, index|
          position, mask = *data
          current_document = root_number(number, mask)
          verify_digit = calculate_verify_digit(current_document, mask, division_modulo)

          digits << verify_digit
          digit_position = digits_positions.shift + index

          # just update ref
          number.insert(digit_position, verify_digit)
        end

        digits
      end

      def root_number(number, mask = nil)
        mask ||= get_verify_digits_weights.values[0]

        normalize(number, mask.size)
      end

      def root_number_to_s(number, mask = nil)
        root_number(number, mask).join
      end

      def normalize(number, length = nil)
        number = stripped(number).split(//).map(&:to_i)

        length.nil? ? number : number[0, length]
      end

      def stripped_number(number, length = nil)
        normalize(number, length).join
      end

      def stripped(number)
        number.to_s.gsub(get_clear_number_regexp, '')
      end

      def pretty(number)
        number = stripped_number(number)

        return "" if number.empty?

        numbers = number.to_s.scan(get_format_regexp).flatten

        # document has a value but it's not valid
        return "" if numbers.empty?

        get_pretty_format_mask % numbers
      end

      def calculate_verify_digit(number, mask, modulo)
        digits = calculate_digits_data(number, mask, modulo)

        digits[:verify_digit].to_i
      end

      def calculate_digits_data(number, mask, modulo)
        sum = reduce_digits_weights(number, mask)
        quotient = (sum / modulo)
        rest = calculate_rest(sum, quotient, modulo)

        { sum: sum, quotient: quotient, rest: rest, verify_digit: calc_verify_digit(rest, modulo) }
      end

      def calculate_rest(sum, quotient, modulo)
        (sum % modulo)
      end

      def reduce_digits_weights(number, mask)
        normalized_number = normalize(number)

        normalized_number.each_with_index.map {|n,i|
          n.to_i * mask[i].to_i
        }.reduce(:+).to_f
      end

      def calc_verify_digit(quotient_rest, modulo)
        rest = (modulo - quotient_rest).to_i

        # if rest has two digits(checkdigit must be a single digit), force 0
        return 0 if rest >= 10

        rest
      end

      def first_verify_mask
        get_verify_digits_weights.values[0]
      end

      def verify_digits_count
        get_verify_digits_weights.size
      end

      def root_document_digits_count
        begin
          get_root_numbers_count
        rescue NameError => e
          first_verify_mask.size
        end
      end

      def correct_length_based_on_first_mask?(number)
        normalize(number).size == root_document_digits_count
      end

      def valid_length?(number)
        normalize(number).size == root_document_digits_count + verify_digits_count
      end

      alias :as_array :normalize
      alias :cleared :stripped
      alias :formatted :pretty

      CONSTANTS_MAP.each do |const_name|
        define_method "get_#{const_name}" do
          self.const_get(const_name.to_s.upcase)
        end

        define_method "set_#{const_name}" do |value|
          self.const_set(const_name.to_s.upcase, value)
        end
      end
    end
  end
end
