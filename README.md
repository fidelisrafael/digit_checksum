# DigitCheckSum

Hi there, I'm glad you're looking in this gem!
The aim of this gem is to allow **any kind** of document to be validated e generated through calculation of [**Check Digit/Digit Checksum**](https://en.wikipedia.org/wiki/Check_digit).

What this mean? This mean that you can **validate** and **generate fake numbers** of any kind of documents such: **Passport numbers**, **Federal ID number**, **Books ISBN**, or even **create your own document** number, check `examples/` for more details.

**Tip**: Check [`examples/h4ck.rb`](examples/h4ck.rb) to see `h4ck` document specification, this is a sample document who can be manipulated using this library!

---

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'digit_checksum'
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
  # masks that will be used to calculate each check digit
  digits_verify_mask first:  %w(5 4 3 2 9 8 7 6 5 4 3 2),
                     second: %w(6 5 4 3 2 9 8 7 6 5 4 3 2)

  # remove any non digit from document number
  # this is the default value, feel free to override
  clear_number_regexp %r{[^(\d+)]}

  # use modulo 11 as algorithm (can be any value)
  division_factor_modulo 11

  # match format such as: 99.999.999/9999-99 | 99-999-999/9999-99 | 99999999/999999 | 99999999999999
  valid_format_regexp %r{(\d{2})[-.]?(\d{3})[-.]?(\d{3})[\/]?(\d{4})[-.]?(\d{2})}

  # mask utilized to prettify doc number
  pretty_format_mask %(%s.%s.%s/%s-%s)

  # numbers sampled to generate new document numbers
  generator_numbers (0..9).to_a
end
```

The example below it's intent to validated brazilian `CNPJ` documents, equivalent to `Corporate Taxpayer Registry Number`, so this can be used to:

#### Generate fake document numbers

```
CNPJ.generate # "79.552.921/0786-55"

CNPJ.generate(false)  # 85215313606778 -- without pretty formating

```


#### Calculate check digits
```ruby
# valid format
CNPJ.calculate_verify_digits("123.456.78/0001") # [9,5]

# invalid format
CNPJ.calculate_verify_digits("123.456.78/00001") # []
```

#### Validate documents numbers
```ruby
# convenience methods to check if document is valid

# invalid format
CNPJ.valid?("123.456.78/0001") # false
CNPJ.invalid?("123.456.78/0001") # true

# valid format
CNPJ.valid?("123.456.78/0001-95") # true
CNPJ.valid?(12345678000195) # true

```

#### Normalize and format documents number

```ruby
# belows returns [1, 2, 3, 4, 5, 6, 7, 8, 0, 0, 0, 1, 9, 5]
CNPJ.normalize_number("123.456.78/0001-95") 

CNPJ.normalize_number_to_s("123.456.78/0001-95") # "12345678000195"

CNPJ.pretty_formatted("123456780001") # "123.456.78/0001-95" -- also aliased as CNPJ.pretty(number) or CNPJ.formatted(number)

CNPJ.clear_number("123.456.78/0001-95") # "12345678000195" -- also aliased as CNPJ.stripped(number)
```

See `examples/`for more detailed samples.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.   
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fidelisrafael/digit_checksum.   
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

