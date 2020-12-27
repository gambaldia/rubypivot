#!/usr/bin/env ruby
# coding: utf-8
#
# Lookup example : column/row header can lookup hash table
#
APP_ROOT = File.dirname(__FILE__)
$LOAD_PATH << "#{APP_ROOT}/../lib"
require "rubypivot"

MONTHS = {
  1 => 'Jan',
  2 => 'Feb',
  3 => 'Mar',
}
NAMES = {
  1 => 'Wendy',
  2 => 'John',
  3 => 'David',
}
source_data = [
  { month: 1, name: 1, value: 33},
  { month: 2, name: 1, value: 45},
  { month: 2, name: 1, value: 55},
  { month: 1, name: 2, value: 123},
  { month: 2, name: 2, value: 23},
  { month: 1, name: 3, value: 3},
]

pivot = Rubypivot::Pivot.new(source_data, :month, :name, :value)
pivot.options[:data_type] = :integer # or :float or :string or nil for raw data
pivot.options[:column_lookup] = MONTHS
pivot.options[:row_lookup] = NAMES
pivot.options[:row_total] = 'Personal Total'
# pivot.options[:header] = false
# pivot.options[:row_header] = false
pivot.build.each do |line|
  p line
end
puts "------------"
p pivot.total_row('Total')

