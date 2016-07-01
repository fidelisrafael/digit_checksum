module DigitChecksum
  class BaseDocument

    CONSTANTS_MAP = [
      :digits_verify_mask,
      :division_factor_modulo,
      :valid_format_regexp,
      :clear_number_regexp,
      :pretty_format_mask,
    ]

    class << self
      def valid?(document_number, stop = true)
        # remove all non digits and return an array to be matched with mask
        normalized_document = normalize_document_number(document_number)

        # if document is empty
        return false if normalized_document.nil? || normalized_document.empty?

        # if document dont match the exact size, it's invalid
        return false unless valid_length?(document_number)

        # remove last two digits to be verified
        last_digits = normalized_document.slice!(-verify_digits_count,verify_digits_count).map(&:to_i)
        digits = calculate_verify_digits(normalized_document)

        last_digits == digits
      end

      def invalid?(document_number)
        !valid?(document_number)
      end

      def calculate_verify_digits(document_number)
        return [] unless correct_length_based_on_first_mask?(document_number)

        division_modulo = get_division_factor_modulo
        digits = []

        get_digits_verify_mask.each do |position, mask|
          document_number = root_document_number(document_number, mask)

          verify_digit = calculate_verify_digit(document_number, mask, division_modulo)

          digits << verify_digit
          document_number << verify_digit
        end

        digits
      end

      def root_document_number(document_number, mask = nil)
        mask ||= get_digits_verify_mask.values[0]

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
        return "" if normalize_document_number(document_number).empty?

        numbers = document_number.to_s.scan(get_valid_format_regexp).flatten

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
        rest = (sum % division_factor)

        { sum: sum, quotient: quotient, rest: rest, verify_digit: digit_verify(rest, division_factor) }
      end

      def calculate_digits_sum(document_number, mask)
        normalized_document_number = normalize_document_number(document_number)

        normalized_document_number.each_with_index.map {|n,i| n.to_i * mask[i].to_i }.reduce(:+).to_f
      end

      def digit_verify(quotient_rest, division_factor)
        # thats the rule, if quotient_rest < 2, so its became 0
        return 0 if quotient_rest < 2

        (division_factor - quotient_rest).to_i
      end

      def first_verify_mask
        get_digits_verify_mask.values[0]
      end

      def verify_digits_count
        get_digits_verify_mask.size
      end

      def root_document_digits_count
        first_verify_mask.size
      end

      def correct_length_based_on_first_mask?(document_number)
        normalize_document_number(document_number).size == root_document_digits_count
      end

      def valid_length?(document_number)
        normalize_document_number(document_number).size == root_document_digits_count + verify_digits_count
      end

      CONSTANTS_MAP.each do |const_identifier|
        define_method "get_#{const_identifier}" do
          const_name = const_identifier.to_s.upcase

          self.const_get(const_identifier.upcase)
        end

        define_method const_identifier do |arg|
          const_name = const_identifier.to_s.upcase

          self.const_set(const_name, arg)
        end
      end
    end
  end
end
