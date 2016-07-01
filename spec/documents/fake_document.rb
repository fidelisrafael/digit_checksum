class FakeDocument < DigitChecksum::BaseDocument
  digits_verify_mask first: %w(10 9 8 7 6 5 4 3 2),
                     second: %w(11 10 9 8 7 6 5 4 3 2)

  # remove any non digit from document number
  clear_number_regexp %r{[^(\d+)]}

  # MOD 11
  division_factor_modulo 11

  # match format such as: XXX.XXX.XXX-XX | XXX-XXX-XXX-XX | XXXXXXXXX-XX | XXXXXXXXXXX
  valid_format_regexp %r{(\d{3})[-.]?(\d{3})[-.]?(\d{3})[-.]?(\d{2})}

  # pretty formated as XXX.XXX.XXX-XX
  pretty_format_mask %(%s.%s.%s-%s)
end
