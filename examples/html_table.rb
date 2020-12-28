#!/usr/bin/env ruby
# coding: utf-8
#
APP_ROOT = File.dirname(__FILE__)
$LOAD_PATH << "#{APP_ROOT}/../lib"
require "rubypivot/html_tag"
require "rubypivot/table"

DATA_SOURCE = [
  ["", "A", "B", "C"],
  ["Wendy", 1, 2, -3],
  ["John", 4, 0, 6],
  ["David", -2, 3, 0],
  ["Total", 3, 5, 3],
]

def cell_class(data)
  if data.to_i < 0
    "red"
  elsif data.to_i == 0
    "hide"
  else
    nil
  end
end

div = Rubypivot::HtmlTag.new('div', class: 'section-info', id: 'my_div1', name: 'division1')
div.add_key('data-bs-target', 'division2')
# puts div.build { "Block Content" }
# puts div.build(body: "Parameter Content", compact: true)

table = Rubypivot::Table.new(DATA_SOURCE, class: "table-striped")
table.tr_class("red", 1)
table.bottom_attributes("total-header")
table.row_attributes("data-cell", 1)
table.column_attributes("row-header", 0)
table.header_attributes("top-header")
# coloring depending on the data value, minus=red, zero=hide, plus=normal
DATA_SOURCE[1..DATA_SOURCE.size - 2].each_with_index do |line, i|
  y = i + 1
  line[1..DATA_SOURCE.first.size - 1].each_with_index do |cell, j|
    x = j + 1
    klass = cell_class(DATA_SOURCE[y][x])
    table.set_class(klass, y, x) if klass
  end
end
puts table.build
