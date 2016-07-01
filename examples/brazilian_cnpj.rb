class CNPJ < DigitChecksum::BaseDocument
  digits_verify_mask first:  %w(5 4 3 2 9 8 7 6 5 4 3 2),
                     second: %w(6 5 4 3 2 9 8 7 6 5 4 3 2)

  # MOD 11
  division_factor_modulo 11

  # remove any non digit from document number
  clear_number_regexp %r{[^(\d+)]}

  # match format such as: 99.999.999/9999-99 | 99-999-999/9999-99 | 99999999/999999 | 99999999999999
  valid_format_regexp %r{(\d{2})[-.]?(\d{3})[-.]?(\d{3})[\/]?(\d{4})[-.]?(\d{2})}

  pretty_format_mask %(%s.%s.%s/%s-%s)
end


CNPJ.valid?(nil) # false
CNPJ.valid?(69739073000104) # true
CNPJ.valid?("38.485.271/0001-57") # true

CNPJ.calculate_verify_digits("423.819.53/0001") # [9,7]
CNPJ.pretty_formatted("69739073000104") # "69.739.073/0001-04"
CNPJ.clear_document_number("38.485.271/0001-57") # 38485271000157
