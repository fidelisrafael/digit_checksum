require 'spec_helper'
require 'documents/fake_document'
require 'documents/my_document'

describe DigitChecksum do
  it 'has a version number' do
    expect(DigitChecksum::VERSION).not_to be nil
  end

  it 'normalize document number' do
    number = '123.456.789-10'
    expected = [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 0]

    number = FakeDocument.normalize(number)

    expect(number).to eq(expected)
    expect(number).to be_a(Array)
  end

  it 'clear the document number formatting' do
    number = '123.456.789-10'
    number = '123.456.789-10'
    expected_stripped = '12345678910'

    stripped_number = FakeDocument.stripped(number)

    expect(stripped_number).to eq(expected_stripped)
    expect(stripped_number).to be_a(String)
  end

  it 'pretty format the document number' do
    number = 12345678910
    expected_formatted = '123.456.789-10'

    number = FakeDocument.pretty(number)

    expect(number).to eq(expected_formatted)
    expect(number).to match(FakeDocument.get_format_regexp)
  end

  it 'calculates digits sum based on weights mask' do
    number = FakeDocument.normalize('123456789')

    weights = FakeDocument.get_verify_digits_weights[:first]
    sum = FakeDocument.reduce_digits_weights(number, weights)

    expect(sum).to eq(210.0)
    expect(sum).to be_a(Float)
  end

  it 'normalize document number when calculate sum based on weights mask' do
    number = '123456789'

    weights = FakeDocument.get_verify_digits_weights[:first]
    sum = FakeDocument.reduce_digits_weights(number, weights)

    expect(sum).to eq(210.0)
    expect(sum).to be_a(Float)
  end

  it 'calculates digit data' do
    number = '123456789'
    division_modulo = FakeDocument.get_division_modulo

    weights = FakeDocument.get_verify_digits_weights[:first]
    data = FakeDocument.calculate_digits_data(number, weights, division_modulo)

    expect(data).to be_a(Hash)
    expect(data.size).to eq(4)
    expect(data[:sum]).to eq(210.0)
    expect(data[:rest]).to eq(1.0)
    expect(data[:verify_digit]).to eq(0)
  end

  it 'calculate each verify digit based on mask' do
    number = '123.456.789'
    weights = FakeDocument.get_verify_digits_weights
    division_modulo = FakeDocument.get_division_modulo

    first_weights = weights[:first]
    second_weights = weights[:second]

    first_digit = FakeDocument.calculate_verify_digit(number, first_weights, division_modulo)
    number << first_digit.to_s
    second_digit = FakeDocument.calculate_verify_digit(number, second_weights, division_modulo)
    number << second_digit.to_s

    expect(first_digit).to eq(0)
    expect(second_digit).to eq(9)
    expect(number).to eq('123.456.78909')
    expect(FakeDocument.pretty(number)).to eq('123.456.789-09')
  end

  it 'calculates all verify digits for document' do
    number = '123.456.789'

    verify_digits = FakeDocument.verify_digits(number)

    expect(verify_digits).to be_a(Array)
    expect(verify_digits).to eq([0, 9])
    expect(verify_digits.size).to eq(2)
    expect(verify_digits[0]).to eq(0)
    expect(verify_digits[1]).to eq(9)
  end

  it 'calculates all verify digits for normalized document' do
    number = FakeDocument.normalize('123.456.789')

    verify_digits = FakeDocument.verify_digits(number)

    expect(verify_digits).to be_a(Array)
    expect(verify_digits.size).to eq(2)
    expect(verify_digits).to eq([0, 9])
  end

  it 'returns only root of document number' do
    number = '123.456.789-20'
    root_number = '123456789'
    root_number_arry = [1, 2, 3, 4, 5, 6, 7, 8, 9]

    root_string = FakeDocument.root_number_to_s(number)
    root_array = FakeDocument.root_number(number)

    expect(root_string).to eq(root_number)
    expect(root_string).to be_a(String)
    expect(root_array).to eq(root_number_arry)
    expect(root_array).to be_a(Array)
  end

  it 'must be invalid if document length inst the same of the first verify mask' do
    number = '123.456.789-111'

    expect(FakeDocument.correct_length_based_on_first_mask?(number)).to be_falsey
    expect(FakeDocument.valid?(number)).to be_falsey
    expect(FakeDocument.invalid?(number)).to be_truthy
  end

  it 'correctly validate document number' do
    number = '123.456.789-09'

    expect(FakeDocument.valid?(number)).to be_truthy
    expect(FakeDocument.invalid?(number)).to be_falsey
  end

  it 'correctly mark document number as invalid' do
    number = '123.456.789-10'

    expect(FakeDocument.valid?(number)).to be_falsey
    expect(FakeDocument.invalid?(number)).to be_truthy
  end

  it 'dinamyc set instance veriables inside document class' do
    expect(FakeDocument::VERIFY_DIGITS_WEIGHTS).to eq(FakeDocument.get_verify_digits_weights)
    expect(FakeDocument::DIVISION_MODULO).to eq(FakeDocument.get_division_modulo)
    expect(FakeDocument::FORMAT_REGEXP).to eq(FakeDocument.get_format_regexp)
    expect(FakeDocument::CLEAR_NUMBER_REGEXP).to eq(FakeDocument.get_clear_number_regexp)
    expect(FakeDocument::PRETTY_FORMAT_MASK).to eq(FakeDocument.get_pretty_format_mask)
  end

  it 'allow to use different modulos division to calculate verify digits' do
    number = 123456789

    class FakeDocumentModulo10 < FakeDocument
      set_division_modulo 10
    end

    class FakeDocumentModulo7 < FakeDocument
      set_division_modulo 7
    end

    class FakeDocumentModulo3 < FakeDocument
      set_division_modulo 3
    end

    modulo10_verify_digits = FakeDocumentModulo10.verify_digits(number)
    modulo13_verify_digits = FakeDocumentModulo7.verify_digits(number)
    modulo3_verify_digits = FakeDocumentModulo3.verify_digits(number)

    # in base 10 verify digits will be [0, 5]
    # in base 13 verify digits will be [7, 4]
    # in base 3 verify digits will be [3, 3]

    expect(modulo10_verify_digits).to eq([0, 5])
    expect(modulo13_verify_digits).to eq([7, 4])
    expect(modulo3_verify_digits).to eq([3, 3])
  end

  it 'correctly clear document number based on clear_number_regexp' do
    class CustomDocument < DigitChecksum::BaseDocument
      # keep only letters (this dont make sense, the only purpose is for tests)
      set_clear_number_regexp %r{[^(\D+)]}
    end

    number = '1A2B3C4D5E6F7G8H9I'
    expected_cleared = 'ABCDEFGHI'

    cleared_number = CustomDocument.stripped(number)

    expect(cleared_number).to eq(expected_cleared)
  end

  it 'consider nil number as invalid document' do
    expect(FakeDocument.valid?(nil)).to be_falsey
  end

  it 'consider blank number as invalid document' do
    expect(FakeDocument.valid?('')).to be_falsey
  end

  it 'must generate valid document numbers' do
    10.times do
      generated_doc = FakeDocument.generate

      expect(FakeDocument.valid?(generated_doc)).to be_truthy
    end
  end

  it 'must respond to alias methods' do
    expect(FakeDocument.respond_to?(:as_array)).to be_truthy
    expect(FakeDocument.respond_to?(:cleared)).to be_truthy
    expect(FakeDocument.respond_to?(:formatted)).to be_truthy
  end

  it 'must returns the positions in setup' do
    positions = MyDocument.obtain_verify_digits_positions # [8, 11]

    expect(positions).to eq([8, 11])
  end

  it 'must calculate the correct digit based on position' do
    digits = MyDocument.verify_digits("110.042.49.11")

    expect(digits).to eq([1,3])
  end

  it 'must append verify digits in correct position' do
    number = "110.042.49.11"

    digits = MyDocument.verify_digits(number)
    document = MyDocument.append_verify_digits(number)

    positions = MyDocument.obtain_verify_digits_positions

    expect(document[positions[0]]).to eq(digits[0].to_s)
    expect(document[positions[1]]).to eq(digits[1].to_s)
  end

  it 'must remove verify digits from passed argument' do
    number = "110.042.491.113"
    expected = "1100424911"

    MyDocument.remove_verify_digits!(number)

    expect(number).to eq(expected)
  end

  it 'must be able to recalculate check digits after removing verify_digits' do
    number = "110.042.491.113"
    expected = "110042491113"

    digits = MyDocument.verify_digits(number) # [1,3]

    MyDocument.remove_verify_digits!(number)

    number = MyDocument.append_verify_digits(number)

    expect(number).to eq(expected)
    expect(MyDocument.valid?(number)).to be_truthy
  end

  it 'must generated valid document number for custom check digits positions' do
    expect(MyDocument.valid?(MyDocument.generate)).to be_truthy
  end
end
