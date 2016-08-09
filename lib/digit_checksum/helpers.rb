module DigitChecksum
  module Helpers
    def generate(pretty = true)
      number = new(generate_root_numbers)
      number.append_verify_digits!

      pretty ? number.pretty : number.to_s
    end

    def generate_root_numbers
      root_digits_count.times.map { get_generator_numbers.sample }
    end

    def root_digits_count
      begin
        get_root_digits_count
      rescue NameError => e
        first_verify_mask = get_verify_digits_weights.values[0]
        first_verify_mask.size
      end
    end

    def reduce_digits_weights(number, mask)
      number = new(number).normalize

      number.each_with_index.map {|n,i|
        n.to_i * mask[i].to_i
      }.reduce(:+).to_f
    end

    def calculate_digits_data(number, mask, modulo)
      sum = reduce_digits_weights(number, mask)
      quotient = (sum / modulo)
      rest = calculate_rest(sum, quotient, modulo)

      { sum: sum, quotient: quotient, rest: rest, digit: calc_verify_digit(rest, modulo) }
    end

    def calculate_rest(sum, quotient, modulo)
      (sum % modulo)
    end

    def calc_verify_digit(quotient_rest, modulo)
      rest = (modulo - quotient_rest).to_i

      # if rest has two digits(checkdigit must be a single digit), force 0
      return 0 if rest >= 10

      rest
    end

    def calculate_verify_digit(number, mask, modulo)
      digits = calculate_digits_data(number, mask, modulo)

      digits[:digit].to_i
    end

    def root_number(number, mask = nil)
      mask ||= get_verify_digits_weights.values[0]

      new(number).normalize.slice(0, mask.size)
    end

    def root_number_to_s(number, mask = nil)
      root_number(number, mask).join
    end
  end
end
