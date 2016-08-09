class FakeDocument < DigitChecksum::BaseDocument
  set_verify_digits_weights first:  %w(10 9 8 7 6 5 4 3 2),
                            second: %w(11 10 9 8 7 6 5 4 3 2)

  # remove any non digit from document number
  set_clear_number_regexp %r{[^(\d+)]}

  # MOD 11
  set_division_modulo 11

  # match format such as: XXX.XXX.XXX-XX | XXX-XXX-XXX-XX | XXXXXXXXX-XX | XXXXXXXXXXX
  set_format_regexp %r{(\d{3})[-.]?(\d{3})[-.]?(\d{3})[-.]?(\d{2})}

  # pretty formated as XXX.XXX.XXX-XX
  set_pretty_format_mask %(%s.%s.%s-%s)

  set_generator_numbers (0..9).to_a
end
