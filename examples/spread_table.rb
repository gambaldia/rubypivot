#!/usr/bin/env ruby
# coding: utf-8
#
# Create spread sheet array, having row (tr) and cell (td) attributes
# to help HTML table
#
APP_ROOT = File.dirname(__FILE__)
$LOAD_PATH << "#{APP_ROOT}/../lib"
require "rubypivot"

DATA_SOURCE = [
  ["", "A", "B", "C"],
  ["Wendy", 1, 2, -3],
  ["John", 4, 0, 6],
  ["David", -2, 3, 0],
  ["Total", 3, 5, 3],
]
# Callback function to control cell class
# data is cell data, line_data is an array of the line cells
def cell_class_callback(data, line_data) 
  if data.to_i < 0
    "negative"
  elsif data.to_i == 0
    "zero"
  else
    nil
  end
end

# spread = DATA_SOURCE.to_spread(  # Alternate method to create new
spread = Rubypivot::SpreadTable.new(DATA_SOURCE,
  header: :first, # Consider the first row as header row
  title: :first, # Consider the first column as row header
  total: :last, # Consider the last row as total row
  data_type: :integer, # or :float, :string, nil
  header_tr_class: 'header', # tr class for header and total row(s)
  header_title_class: 'header-title', # td class for title of header row
  data_tr_class: 'data-row', # tr class for data row(s)
  data_title_class: 'data-title', # td class for title of data row
)
# spread.each_header_line {|row| row.set_tr_class("header") }

spread.line(1).set_tr_class("data-girl")
spread.set_cell_class(method(:cell_class_callback))
# spread.each_data_line {|line| line.set_cell_class(method(:cell_class_callback)) } # Same effects like above line
# spread.set_cell_class('data-class')

puts "--- Created array ------------"
spread.rows.each do |row|
  puts row.to_s
end
puts "--- Some calculated attrib ---"
puts "Total width: #{spread.total_width}"
puts "Total height: #{spread.total_height}"
puts "Data width: #{spread.data_width}"
puts "Data height: #{spread.data_height}"

puts "--- HTML table ---------------"
puts spread.to_html(class: "table table-striped", line_end: :cr)

