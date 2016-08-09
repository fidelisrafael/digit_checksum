# This is one document type created to ilustrated how this library can
# be fully apropriate to manipulate custom documents types
class H4ck < DigitChecksum::BaseDocument

  PROGRAMMINGS_LANGUAGES = {
    '01' => 'C#',
    '02' => 'Javascript',
    '03' => 'Lua',
    '04' => 'Python',
    '05' => 'Ruby'
  }

  PROGRAMMINGS_LANGUAGES.default = 'Unknown'

  set_division_modulo 11

  set_verify_digits_weights first:  %w(17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2),
                            second: %w(18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2),
                            last:   %w(19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2)

  # remove any non digit and 0x character from document number
  set_clear_number_regexp %r{(0x)|[^\d+]}

  # 0101&&1111(0x01)||[16]<07>!29
  # Ex: 0101&&1111(0x01)||[16]<07>!29-110
  set_format_regexp %r{(\d{4})(\d{4})\(?[0x]?(\d{2})\)?\|?\|?\[?(\d{2})\]?\<?(\d{2})\>?\!?(\d{2})\-?(\d{3})}

  # XXXX&&XXXX(0xZZ)||[YY]<MM>!DD-VVV;
  set_pretty_format_mask %(%s&&%s(0x%s)||[%s]<%s>!%s-%s;)

  # numbers sampled to generate new document numbers
  set_generator_numbers (0..9).to_a

  def favorite_language
    languange_identifier = normalize[8..9].join

    PROGRAMMINGS_LANGUAGES[languange_identifier]
  end
end

root_doc_number = "0101&&1111(0x01)||[16]<07>!29"
valid_doc_number = "0101&&1111(0x01)||[16]<07>!29-840"
invalid_doc_number = "0101&&1111(0x01)||[16]<07>!29-841"

H4ck.generate
H4ck.valid?(H4ck.generate)
H4ck.strip(root_doc_number) # "0101111101160729"
H4ck.calculate_verify_digits(root_doc_number) # [8,4,0]
H4ck.valid?(root_doc_number) # false
H4ck.valid?(valid_doc_number) # true
H4ck.valid?(invalid_doc_number) # false

H4ck.new(valid_doc_number).favorite_language # C#
H4ck.new("0101&&1111(0x04)||[16]<07>!29-840").favorite_language # Python
