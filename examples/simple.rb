#!/usr/bin/env ruby
# coding: utf-8
#
# Simple example
#
APP_ROOT = File.dirname(__FILE__)
$LOAD_PATH << "#{APP_ROOT}/../lib"
require "rubypivot"

source_data = [
  { month: 'Jan', name: 'Wendy', value: 33},
  { month: 'Feb', name: 'Wendy', value: 45},
  { month: 'Feb', name: 'Wendy', value: 55},
  { month: 'Jan', name: 'John', value: 123},
  { month: 'Feb', name: 'John', value: 23},
  { month: 'Jan', name: 'David', value: 3},
]

pivot = Rubypivot::Pivot.new(source_data, :month, :name, :value, data_type: :integer)
pivot.column_titles = ['Jan', 'Feb', 'Mar']
pivot.options[:row_total] = 'Total'
# pivot.options[:header] = true
# pivot.options[:row_header] = false
# p pivot.row_titles
# p pivot.header_row('')
# p pivot.column_titles.sort! # sorting columns
p pivot.column_titles
puts "------------"
pivot.build_data.sort.each do |title, line|
  puts "#{title}: #{line.join(", ")}"
end

puts
puts "------------"
pivot.build.each do |line|
  p line
end
puts "------------"
p pivot.total_row('Total')
