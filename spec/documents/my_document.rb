class MyDocument < DigitChecksum::BaseDocument

  set_division_modulo 11

  set_clear_number_regexp %r{[^(\d+)]}

  set_root_digits_count 10

  set_verify_digits_positions [8, 11]

  set_verify_digits_weights first: %w(1 3 4 5 6 7 8 10),
                            last:  %w(3 2 10 9 8 7 6 5 4 3 2)

  set_format_regexp %r{(\d{3})[-.]?(\d{3})[-.]?(\d{3})[-.]?(\d{3})}

  set_pretty_format_mask %(%s.%s.%s.%s)

  set_generator_numbers (0..9).to_a
end
