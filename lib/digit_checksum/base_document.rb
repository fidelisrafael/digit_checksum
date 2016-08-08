module DigitChecksum
  class BaseDocument

    CONSTANTS_MAP = [
      :root_documents_digits_count,
      :verify_digits_positions,
      :digits_ignore_positions,
      :division_factor_modulo,
      :verify_digits_weights,
      :clear_number_regexp,
      :valid_format_regexp,
      :pretty_format_mask,
      :generator_numbers,
      :document_length
    ]

    class << self
      def generate(formatted = true)
        document_number = append_verify_digits(generate_root_numbers)

        formatted ? pretty_formatted(document_number) : document_number
      end

      def append_verify_digits(document_number)
        document_number = normalize_number(document_number)
        verify_digits = calculate_verify_digits(document_number)

        obtain_verify_digits_positions.each_with_index {|position, index|
          document_number.insert(position + index, verify_digits.shift)
        }

        normalize_number_to_s(document_number.compact)
      end

      def generate_root_numbers
        root_document_digits_count.times.map { get_generator_numbers.sample }
      end

      def valid?(document_number)
        # remove all non digits and return an string to be matched with mask
        normalized_document = normalize_number_to_s(document_number)

        # if document is empty
        return false if normalized_document.nil? || normalized_document.empty?

        # if document dont match the exact size, it's invalid
        return false unless valid_length?(normalized_document)

        # remove verify digits to be verified
        verify_digits = remove_verify_digits!(normalized_document)

        # calculate the new digits based on root document number
        digits = calculate_verify_digits(normalized_document)

        verify_digits == digits
      end

      def remove_verify_digits!(document_number)
        document_number.gsub!(get_clear_number_regexp, '')

        obtain_verify_digits_positions.each_with_index.flat_map {|position, index|
          document_number.slice!((position - index), 1)
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

      def invalid?(document_number)
        !valid?(document_number)
      end

      def calculate_verify_digits(document_number)
        return [] unless correct_length_based_on_first_mask?(document_number)

        document_number = normalize_number(document_number)
        division_modulo = get_division_factor_modulo
        digits_positions = obtain_verify_digits_positions.dup
        digits = []

        get_verify_digits_weights.each_with_index do |data, index|
          position, mask = *data
          current_document = root_document_number(document_number, mask)
          verify_digit = calculate_verify_digit(current_document, mask, division_modulo)

          digits << verify_digit
          digit_position = digits_positions.shift + index

          # just update ref
          document_number.insert(digit_position, verify_digit)
        end

        digits
      end

      def root_document_number(document_number, mask = nil)
        mask ||= get_verify_digits_weights.values[0]

        normalize_document_number(document_number, mask.size)
      end

      def root_document_number_to_s(document_number, mask = nil)
        root_document_number(document_number, mask).join
      end

      def normalize_document_number(document_number, length = nil)
        document_number = clear_document_number(document_number).split(//).map(&:to_i)

        length.nil? ? document_number : document_number[0, length]
      end

      def normalize_document_number_to_s(document_number, length = nil)
        normalize_document_number(document_number, length).join
      end

      def clear_document_number(document_number)
        document_number.to_s.gsub(get_clear_number_regexp, '')
      end

      def pretty_formatted(document_number)
        normalized_doc = normalize_number_to_s(document_number)

        return "" if normalized_doc.empty?

        numbers = normalized_doc.to_s.scan(get_valid_format_regexp).flatten

        # document has a value but it's not valid
        return "" if numbers.empty?

        get_pretty_format_mask % numbers
      end

      def calculate_verify_digit(document_number, mask, division_factor)
        digits = calculate_digits_data(document_number, mask, division_factor)

        digits[:verify_digit].to_i
      end

      def calculate_digits_data(document_number, mask, division_factor)
        sum = calculate_digits_sum(document_number, mask)
        quotient = (sum / division_factor)

        rest = calculate_digits_sum_rest(sum, quotient, division_factor)

        { sum: sum, quotient: quotient, rest: rest, verify_digit: digit_verify(rest, division_factor) }
      end

      def calculate_digits_sum_rest(sum, quotient, division_factor)
        (sum % division_factor)
      end

      def calculate_digits_sum(document_number, mask)
        normalized_document_number = normalize_document_number(document_number)

        normalized_document_number.each_with_index.map {|n,i| n.to_i * mask[i].to_i }.reduce(:+).to_f
      end

      def digit_verify(quotient_rest, division_factor)
        rest = (division_factor - quotient_rest).to_i

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
          get_root_documents_digits_count
        rescue NameError => e
          first_verify_mask.size
        end
      end

      def correct_length_based_on_first_mask?(document_number)
        normalize_document_number(document_number).size == root_document_digits_count
      end

      def valid_length?(document_number)
        normalize_document_number(document_number).size == root_document_digits_count + verify_digits_count
      end

      alias :normalize_number_to_s :normalize_document_number_to_s
      alias :normalize_number :normalize_document_number
      alias :clear_number :clear_document_number
      alias :stripped :clear_document_number
      alias :formatted :pretty_formatted
      alias :pretty :pretty_formatted

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
