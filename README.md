# DigitCheckSum

[![Build Status](https://travis-ci.org/fidelisrafael/digit_checksum.svg)](https://travis-ci.org/fidelisrafael/digit_checksum)

Hi there, I'm glad you're looking in this gem!
The aim of this gem is to allow **any kind** of document to be validated e generated through calculation of [**Check Digit/Digit Checksum**](https://en.wikipedia.org/wiki/Check_digit).

What this mean? This mean that you can **validate** and **generate fake numbers** of any kind of documents such: **Passport numbers**, **Federal ID number**, **Books ISBN**, or even **create your own document** number, check `examples/` for more details.
One of the greatest abilitys of this library is allowing to check digit checksum of digits in **ANY POSITION** of the document, not only for the last digits.

**Tip**: Check [`examples/h4ck.rb`](examples/h4ck.rb) to see `h4ck` document specification, this is a sample document who can be manipulated using this library!

---

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'digit_checksum', '~> 0.2.3'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install digit_checksum

---

## Usage

This gem by yourself don't do anything unless you create a class that inherit from `DigitChecksum::BaseDocument` class, but when properly inherited and configured, believe me, you gain **awesomeness**!

Don't you believe me? See for yourself an example:


```ruby
require 'digit_checksum'

class CNPJ < DigitChecksum::BaseDocument
  set_verify_digits_weights first:  %w(5 4 3 2 9 8 7 6 5 4 3 2),
                            second: %w(6 5 4 3 2 9 8 7 6 5 4 3 2)

  # MOD 11
  set_division_modulo 11

  # remove any non digit from document number
  set_clear_number_regexp %r{[^(\d+)]}

  # match format such as: 99.999.999/9999-99 | 99-999-999/9999-99 | 99999999/999999 | 99999999999999
  set_format_regexp %r{(\d{2})[-.]?(\d{3})[-.]?(\d{3})[\/]?(\d{4})[-.]?(\d{2})}

  set_pretty_format_mask %(%s.%s.%s/%s-%s)

  # numbers sampled to generate new document numbers
  set_generator_numbers (0..9).to_a
end
```

The example below it's intent to validated brazilian `CNPJ` documents, equivalent to `Corporate Taxpayer Registry Number`, so this can be used to:

#### Generate fake document numbers

```ruby
CNPJ.generate # "79.552.921/0786-55"

# without pretty formating
CNPJ.generate(false)  # 85215313606778

# You can generate only random root numbers
root_numbers = CNPJ.generate_root_numbers
# => [3, 8, 9, 3, 2, 5, 9, 5, 0, 2, 6, 6]

CNPJ.calculate_verify_digits(root_numbers) # [6,7]

# To insert the verify digits in the CORRECT positions
# Remember: The correct position MAY NOT be the last positions
# So use `append_verify_digits` to handle this

CNPJ.pretty(CNPJ.append_verify_digits!(root_numbers))
=> "38.932.595/0266-67"
```


#### Calculate check digits
```ruby
# valid format
CNPJ.calculate_verify_digits("123.456.78/0001") # [9,5]

# invalid format
CNPJ.calculate_verify_digits("123.456.78/00001") # []

CNPJ.pretty(CNPJ.append_verify_digits!("12.345.678/0001")) # "12.345.678/0001-95

document = "123.456.78/0001-95"
CNPJ.remove_verify_digits!(document) => # [9,5]
document # => 123456780001

CNPJ.pretty(CNPJ.append_verify_digits!(document)) # => "12.345.678/0001-95"

```

#### Validate documents numbers
```ruby
# convenience methods to check if document is valid

# invalid format
CNPJ.valid?("123.456.78/0001") # => false
CNPJ.invalid?("123.456.78/0001") # => true

# valid format
CNPJ.valid?("123.456.78/0001-95") # => true
CNPJ.valid?(12345678000195) # => true

```

#### Normalize and format documents number

```ruby

# Get a array representation of document number
CNPJ.normalize("123.456.78/0001-95")
# => [1, 2, 3, 4, 5, 6, 7, 8, 0, 0, 0, 1, 9, 5]

# also aliased as CNPJ.pretty_formatted(number) or CNPJ.formatted(number)
CNPJ.pretty("12345678000195") # "123.456.78/0001-95"

# also aliased as CNPJ.clear_number(number)
CNPJ.strip("123.456.78/0001-95") # => "12345678000195"
```

See `examples/`for more detailed samples.

---

### Custom verify digits positions

In **most**(*but not necessarily all*) documents formats the check digits positions are the last characters, but this library also allow you
to calculate check digits in any position in the middle of the document number, see an example:

```ruby
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


MyDocument.get_verify_digits_positions # [8, 11]

# document number without check digits
MyDocument.calculate_verify_digits("110.042.49.11") # => [1, 3]

document = MyDocument.append_verify_digits!("110.042.49.11")
# => "110042491113"

MyDocument.pretty(document) # => "110.042.491.113"

MyDocument.remove_verify_digits!(document) # => [1, 3]

document # => "1100424911"
document = MyDocument.append_verify_digits!(document)

# => "110042491113"
MyDocument.pretty(document) # => "110.042.491.113"

# document number with check digits in the right positions(8, 11)
MyDocument.valid?("110.042.491.113") # => true

# document number with wrong check digits in the right positions
MyDocument.valid?("110.042.492.113") # => false

MyDocument.pretty(MyDocument.append_verify_digits!("110.042.49.11"))
# => "110.042.491.113"

doc = MyDocument.generate # => "286.670.374.780"

MyDocument.valid?(doc) # =: true
```

---

## PORO - Plain Old Ruby Objects API

All API demonstrated in this documentation (mostly class methods call) are **simple instance methods delegations to a Ruby object instance**, you can work directly with objects in this way:

```ruby
object = CNPJ.new("53.091.177/2847-09")

object.valid? # true

# Try to get verify digits without calculating
# Just search in the right positions in number
object.current_verify_digits # [0, 9]

# Permanently remove verify digits from number
object.remove_verify_digits! # [0, 9]

# Try to get verify digits without calculating
object.current_verify_digits # []

object.number # object.to_s => "530911772847"

object.valid? # false

# Just calculate the verify digits, dont append to number
object.calculate_verify_digits # [0, 9]

# Use the `calculate_verify_digits` methods and append the digits in the RIGHT positions
object.append_verify_digits! # "53091177284709"

object.pretty # => "53.091.177/2847-09"

object.normalize
# => [5, 3, 0, 9, 1, 1, 7, 7, 2, 8, 4, 7, 0, 9]

object.strip # "53091177284709"

object.size # 14

object.root_digits_count # 12

object.verify_digits_count # 2

# root_digits_count + verify_digits_count
object.full_size # 14

object.verify_digits_positions # [12, 13]
```

---

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fidelisrafael/digit_checksum.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
