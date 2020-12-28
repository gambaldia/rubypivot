#!/usr/bin/env ruby
# coding: utf-8
#
# Active record example
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

class ActiveRecordLikeRecord
  def initialize(data) @data = data; end
  def method_missing(name, *_args) @data[name.to_sym]; end
end

class ActiveRecordLike
  SOURCE_DATA = [
    { month: 1, name: 1, value: 33},
    { month: 2, name: 1, value: 45},
    { month: 2, name: 1, value: 55},
    { month: 1, name: 2, value: 123},
    { month: 2, name: 2, value: 23},
    { month: 1, name: 3, value: 3},
  ]
  def self.all
    res = []
    SOURCE_DATA.each do |data|
      res << ActiveRecordLikeRecord.new(data)
    end
    res
  end
end

records = ActiveRecordLike.all
pivot = Rubypivot::Pivot.new(records, :month, :name, :value)
pivot.options[:data_type] = :integer
pivot.options[:column_lookup] = MONTHS
pivot.options[:row_lookup] = NAMES
pivot.build.each do |line|
  p line
end
