require 'spec_helper'
require 'documents/fake_document'

describe DigitChecksum do
  it 'has a version number' do
    expect(DigitChecksum::VERSION).not_to be nil
  end

  it 'normalize document number' do
    document_number = '123.456.789-10'
    expected_normalized = [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 0]

    normalized_document_number = FakeDocument.normalize_document_number(document_number)

    expect(normalized_document_number).to eq(expected_normalized)
    expect(normalized_document_number).to be_a(Array)
  end

  it 'clear the document number formatting' do
    document_number = '123.456.789-10'
    document_number = '123.456.789-10'
    expected_stripped = '12345678910'

    stripped_document_number = FakeDocument.clear_document_number(document_number)

    expect(stripped_document_number).to eq(expected_stripped)
    expect(stripped_document_number).to be_a(String)
  end

  it 'pretty format the document number' do
    document_number = 12345678910
    expected_formatted = '123.456.789-10'

    formatted_document_number = FakeDocument.pretty_formatted(document_number)

    expect(formatted_document_number).to eq(expected_formatted)
    expect(formatted_document_number).to match(FakeDocument.get_valid_format_regexp)
  end

  it 'calculates digits sum based on mask' do
    document_number = FakeDocument.normalize_document_number('123456789')

    mask = FakeDocument.get_digits_verify_mask[:first]
    sum = FakeDocument.calculate_digits_sum(document_number, mask)

    expect(sum).to eq(210.0)
    expect(sum).to be_a(Float)
  end

  it 'normalize document number when calculate sum based on mask' do
    document_number = '123456789'

    mask = FakeDocument.get_digits_verify_mask[:first]
    sum = FakeDocument.calculate_digits_sum(document_number, mask)

    expect(sum).to eq(210.0)
    expect(sum).to be_a(Float)
  end

  it 'calculates digit data' do
    document_number = '123456789'
    division_factor = FakeDocument.get_division_factor_modulo

    mask = FakeDocument.get_digits_verify_mask[:first]

    data = FakeDocument.calculate_digits_data(document_number, mask, division_factor)

    expect(data).to be_a(Hash)
    expect(data.size).to eq(4)
    expect(data[:sum]).to eq(210.0)
    expect(data[:rest]).to eq(1.0)
    expect(data[:verify_digit]).to eq(0)
  end

  it 'calculate each verify digit based on mask' do
    document_number = '123.456.789'
    masks = FakeDocument.get_digits_verify_mask
    division_factor = FakeDocument.get_division_factor_modulo

    first_mask = masks[:first]
    second_mask = masks[:second]

    first_digit = FakeDocument.calculate_verify_digit(document_number, first_mask, division_factor)
    document_number << first_digit.to_s
    second_digit = FakeDocument.calculate_verify_digit(document_number, second_mask, division_factor)
    document_number << second_digit.to_s

    expect(first_digit).to eq(0)
    expect(second_digit).to eq(9)
    expect(document_number).to eq('123.456.78909')
    expect(FakeDocument.pretty_formatted(document_number)).to eq('123.456.789-09')
  end

  it 'calculates all verify digits for document' do
    document_number = '123.456.789'

    verify_digits = FakeDocument.calculate_verify_digits(document_number)

    expect(verify_digits).to be_a(Array)
    expect(verify_digits).to eq([0, 9])
    expect(verify_digits.size).to eq(2)
    expect(verify_digits[0]).to eq(0)
    expect(verify_digits[1]).to eq(9)
  end

  it 'calculates all verify digits for normalized document' do
    document_number = FakeDocument.normalize_document_number('123.456.789')

    verify_digits = FakeDocument.calculate_verify_digits(document_number)

    expect(verify_digits).to be_a(Array)
    expect(verify_digits.size).to eq(2)
    expect(verify_digits).to eq([0, 9])
  end

  it 'returns only root of document number' do
    document_number = '123.456.789-20'
    root_document_number = '123456789'
    root_document_number_arry = [1, 2, 3, 4, 5, 6, 7, 8, 9]

    root_string = FakeDocument.root_document_number_to_s(document_number)
    root_array = FakeDocument.root_document_number(document_number)

    expect(root_string).to eq(root_document_number)
    expect(root_string).to be_a(String)
    expect(root_array).to eq(root_document_number_arry)
    expect(root_array).to be_a(Array)
  end

  it 'must be invalid if document length inst the same of the first verify mask' do
    document_number = '123.456.789-111'

    expect(FakeDocument.correct_length_based_on_first_mask?(document_number)).to eq(false)
    expect(FakeDocument.valid?(document_number)).to eq(false)
    expect(FakeDocument.invalid?(document_number)).to eq(true)
  end

  # it 'ignore exceding document numbers when calculating verify digits' do
  #   document_number = '123.456.789-2000'

  #   verify_digits = FakeDocument.calculate_verify_digits(document_number)

  #   expect(verify_digits).to be_a(Array)
  #   expect(verify_digits.size).to eq(2)
  #   expect(verify_digits).to eq([0, 9])
  # end

  it 'correctly validate document number' do
    document_number = '123.456.789-09'

    expect(FakeDocument.valid?(document_number)).to be true
    expect(FakeDocument.invalid?(document_number)).to be false
  end

  it 'correctly mark document number as invalid' do
    document_number = '123.456.789-10'

    expect(FakeDocument.valid?(document_number)).to be false
    expect(FakeDocument.invalid?(document_number)).to be true
  end

  it 'dinamyc set constants inside document class' do
    expect(FakeDocument::DIGITS_VERIFY_MASK).to eq(FakeDocument.get_digits_verify_mask)
    expect(FakeDocument::DIVISION_FACTOR_MODULO).to eq(FakeDocument.get_division_factor_modulo)
    expect(FakeDocument::VALID_FORMAT_REGEXP).to eq(FakeDocument.get_valid_format_regexp)
    expect(FakeDocument::CLEAR_NUMBER_REGEXP).to eq(FakeDocument.get_clear_number_regexp)
    expect(FakeDocument::PRETTY_FORMAT_MASK).to eq(FakeDocument.get_pretty_format_mask)
  end

  it 'allow to use different modulos division to calculate verify digits' do
    document_number = 123456789

    # in base 10 verify digits will be [0, 5]
    # in base 13 verify digits will be [11, 3]
    # in base 3 verify digits will be [0, 0]

    class FakeDocumentModulo10 < FakeDocument
      division_factor_modulo 10
    end

    class FakeDocumentModulo13 < FakeDocument
      division_factor_modulo 13
    end

    class FakeDocumentModulo3 < FakeDocument
      division_factor_modulo 3
    end

    modulo10_verify_digits = FakeDocumentModulo10.calculate_verify_digits(document_number)
    modulo13_verify_digits = FakeDocumentModulo13.calculate_verify_digits(document_number)
    modulo3_verify_digits = FakeDocumentModulo3.calculate_verify_digits(document_number)

    expect(modulo10_verify_digits).to eq([0, 5])
    expect(modulo13_verify_digits).to eq([11, 3])
    expect(modulo3_verify_digits).to eq([0, 0])
  end

  it 'correctly clear document number based on clear_number_regexp' do
    class CustomDocument < DigitChecksum::BaseDocument
      # keep only letters (this dont make sense, the only purpose is for tests)
      clear_number_regexp %r{[^(\D+)]}
    end

    document_number = '1A2B3C4D5E6F7G8H9I'
    expected_cleared = 'ABCDEFGHI'

    cleared_document_number = CustomDocument.clear_document_number(document_number)

    expect(cleared_document_number).to eq(expected_cleared)
  end

  it 'consider nil document_number as invalid document' do
    expect(FakeDocument.valid?(nil)).to eq(false)
  end

  it 'consider blank document_number as invalid document' do
    expect(FakeDocument.valid?('')).to eq(false)
  end

  it 'must generate valid document numbers' do
    10.times do
      generated_doc = FakeDocument.generate

      expect(FakeDocument.valid?(generated_doc)).to eq(true)
    end
  end

  it 'must respond to alias methods' do
    expect(FakeDocument.respond_to?(:stripped)).to eq(true)
    expect(FakeDocument.respond_to?(:formatted)).to eq(true)
    expect(FakeDocument.respond_to?(:pretty)).to eq(true)
    expect(FakeDocument.respond_to?(:normalize_number_to_s)).to eq(true)
    expect(FakeDocument.respond_to?(:normalize_number)).to eq(true)
  end
end
