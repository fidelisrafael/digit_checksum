class CPF < DigitChecksum::BaseDocument
  digits_verify_mask first:  %w(10 9 8 7 6 5 4 3 2),
                     second: %w(11 10 9 8 7 6 5 4 3 2)

  # MOD 11
  division_factor_modulo 11

  # remove any non digit from document number
  clear_number_regexp %r{[^(\d+)]}

  # match format such as: 999.999.999-99 | 999-999-999-99 | 99999999999
  valid_format_regexp %r{(\d{3})[-.]?(\d{3})[-.]?(\d{3})[-.]?(\d{2})}

  pretty_format_mask %(%s.%s.%s-%s)
end

CPF.valid?(nil) # false
CPF.valid?(31777259185) # true
CPF.valid?("315.844.227-26") # true

CPF.calculate_verify_digits("315.844.227") # [2, 6]
CPF.pretty_formatted("31777259185") # "315.844.227-26"
CPF.clear_document_number("315.844.227-26")
