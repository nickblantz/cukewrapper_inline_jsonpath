# CukewrapperInlineJsonpath

This plugin allows you to modify your data from JSONPath in Datatables

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cukewrapper'

group :cukewrapper_plugins do
  gem 'cukewrapper_inline_jsonpath'
  # ...
end
```

## Usage

Add a Datatable to your scenario where the headers are `JSONPath` and `Value`. 

```gherkin
Scenario: My scenario
    Given ...
        | JSONPath                           | Value              |
        # Each item's price                  # Overriding a value #
        | $.items[*].price                   | 10.00              |
        # The item at index 1                # Merging a Hash     #
        | $.items[1]                         | ~#{'price'=>20.00} |
        # Each item named Tito's kind        # Does nothing       #
        | $.items[?(@.name == 'Lays')].kind  | ~"Chips"           |
```

### Values

Values have two basic forms: as valid JSON, or as valid ruby prefixxed with `#`.
Values can also be merged into the existing value by prefixxing with `~`. 
Merging only applies for Dictionaries and Lists, or if provided by itself, no
action is taken upon the existing value.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nickblantz/cukewrapper_inline_jsonpath. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/nickblantz/cukewrapper_inline_jsonpath/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CukewrapperInlineJsonpath project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/nickblantz/cukewrapper_inline_jsonpath/blob/master/CODE_OF_CONDUCT.md).
