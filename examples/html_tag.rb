#!/usr/bin/env ruby
# coding: utf-8
#
# Make HTML table from spread sheet array
#
APP_ROOT = File.dirname(__FILE__)
$LOAD_PATH << "#{APP_ROOT}/../lib"
require "rubypivot/html_tag"

div = Rubypivot::HtmlTag.new('div', class: 'section section-info', name: 'title-header')
div.add_key('data-bs-target', 'target')
puts div.build { "HTML Tag generator" }
puts div.build(body: "HTML Tag generator")

tr = Rubypivot::HtmlTag.new('tr', class: 'header')
