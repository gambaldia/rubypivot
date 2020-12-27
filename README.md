# Rubypivot

Rubypivot is a tool to make pivot table arrays for ruby.
It transforming a dataset or array of hashes into a spreadsheet-style array.

Suggestions and pull requests are welcome.

## Installation

```
gem install rubypivot
```
Not yet ready, please clone the repository for the moment.
## Usage

```ruby
require "rubypivot"
pivot = Rubypivot::Pivot.new(source_data, :month, :name, :value, data_type: :integer)
pivot.build.each do |line|
  p line
end
```
See sample scripts in examples folder.

Supported data aggregation is only SUM for numeric values.

Total calculation supported.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

