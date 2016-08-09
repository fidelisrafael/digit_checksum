module DigitChecksum
  class BaseDocument

    CLASS_METHODS = [
      :verify_digits_positions,
      :digits_ignore_positions,
      :verify_digits_weights,
      :clear_number_regexp,
      :root_digits_count,
      :pretty_format_mask,
      :generator_numbers,
      :division_modulo,
      :document_length,
      :format_regexp
    ]

    CLASS_METHODS.each do |const_name|
      define_singleton_method "get_#{const_name}" do
        self.const_get(const_name.to_s.upcase)
      end

      define_singleton_method "set_#{const_name}" do |value|
        self.const_set(const_name.to_s.upcase, value).freeze
      end

      define_method "get_#{const_name}" do
        self.class.const_get(const_name.to_s.upcase)
      end
    end

    attr_accessor :number

    def initialize(number)
      @number = stripped(number)
    end

    def valid?
      # if document is empty or dont match the exact size, it's invalid
      return false if (empty? || !valid_length?)

      # match current verify digits with calculate through modulo operation
      current_verify_digits == calculate_verify_digits
    end

    def invalid?
      !valid?
    end

    def empty?
      @number.nil? || @number.empty?
    end

    def valid_length?
      length == full_number_length
    end

    def full_number_length
      (root_digits_count + verify_digits_count)
    end

    def length
      normalize.length
    end

    alias :size :length

    def current_verify_digits
      remove_verify_digits(@number.dup)
    end

    def calculate_verify_digits
      number = without_verify_digits(@number)
      digits = []
      digits_positions = verify_digits_positions.dup

      get_verify_digits_weights.each_with_index do |data, index|
        position, mask = *data

        current_number = normalized(number, mask.size)
        verify_digit = calculate_verify_digit(current_number, mask)

        # just update ref to calculate next digit
        number.insert((digits_positions.shift + index), verify_digit)

        digits << verify_digit
      end

      digits
    end

    def remove_verify_digits!
      remove_verify_digits(@number)
    end

    def append_verify_digits!
      # return @number if current_verify_digits.size == verify_digits_counta

      digits = calculate_verify_digits
      @number = normalize

      verify_digits_positions.each_with_index.flat_map {|position, index|
        # position + index
        @number.insert(position, digits.shift)
      }

      @number = stripped(@number)
    end

    def normalize
      normalized(@number)
    end

    def pretty
      numbers = @number.to_s.scan(get_format_regexp).flatten
      numbers.empty? ? '' : (get_pretty_format_mask % numbers)
    end

    def strip
      stripped(@number)
    end

    def to_s
      @number
    end

    def verify_digits_count
      get_verify_digits_weights.size
    end

    def root_digits_count
      self.class.root_digits_count
    end

    def verify_digits_positions
      begin
        get_verify_digits_positions
      # when value its not set
      rescue NameError => e
        default_verify_digits_position
      end
    end

    alias :as_array :normalize
    alias :clear :strip
    alias :formatted :pretty

    private
    def stripped(number)
      number.to_s.gsub(get_clear_number_regexp, '')
    end

    def normalized(number, length = nil)
      number = stripped(number).split(//).map(&:to_i)

      length.nil? ? number : number[0, length]
    end

    def remove_verify_digits(number)
      verify_digits_positions.each_with_index.flat_map {|position, index|
        number.slice!(position - index, 1)
      }.map(&:to_i)
    end

    def without_verify_digits(number)
      number = normalized(number)

      return number unless number.length == full_number_length

      remove_verify_digits(number) and number
    end

    def default_verify_digits_position
      verify_digits_count.times.map {|i| root_digits_count + i  }
    end

    def calculate_verify_digit(current_number, mask)
      self.class.calculate_verify_digit(current_number, mask, get_division_modulo)
    end

  end
end
