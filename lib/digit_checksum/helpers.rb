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

    def root_number(number, mask = nil)
      mask ||= get_verify_digits_weights.values[0]

      new(number).normalize.slice(0, mask.size)
    end

    def root_number_to_s(number, mask = nil)
      root_number(number, mask).join
    end
  end
end
