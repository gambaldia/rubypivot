module Rubypivot

  class Table
    DEFAULT_OPTIONS = {
    }.freeze

    attr_accessor :options
    attr_reader :x_size, :y_size
    def initialize(data_array, options = {})
      raise StandardError, "Data source must be an two dimension array" if !data_array.is_a?(Array) || !data_array.first.is_a?(Array)
      @options = options
      @data_array = data_array
      @attributes = []
      @data_array.each do |line|
        @attributes << [options[:tr_class]]
      end
      @x_size = @data_array.first.size
      @y_size = @data_array.size
    end

    def build(options = {})
      tr_classes(options[:tr_class]) if options[:tr_class]
      res = open
      @data_array.each_with_index do |line, y|
        tr = HtmlTag.new("tr", class: @attributes[y][0])
        res << tr.open
        line.each_with_index do |td_data, x|
          res << HtmlTag.new("td", class: @attributes[y][x + 1]).build{ td_data }
        end
        res << tr.close + "\n"
      end
      # res << "\n"
      res << close
      res
    end
  
    def open
      res = HtmlTag.new('table', @options).open
      res << "\n"
      res 
    end

    def close(options = {})
      "</table>\n"
    end

    def range_check(y)
      if y.is_a?(Symbol)
        if y == :bottom
          return @y_size - 1
        else
          return 0
        end
      end
      raise StandardError, "Class set out of range: #{y} > #{@y_size}" if y > @y_size
      y
    end
    
    def tr_class(klass, y)
      return unless klass
      y = range_check(y)
      @attributes[y][0] = klass
    end

    def tr_classes(klass)
      return unless klass
      0.upto(@attributes.size - 1) do |y|
        @attributes[y][0] = klass
      end
    end

    def set_class(klass, y, x)
      return unless klass
      y = range_check(y)
      raise StandardError, "Class set out of range: #{} > #{@x_size}" if x >= @x_size
      @attributes[y][x + 1] = klass
    end

    def row_attributes(klass, y)
      return unless klass
      y = range_check(y)
      1.upto(@x_size) do |pos|
        @attributes[y][pos] = klass
      end
    end

    def column_attributes(klass, x)
      return unless klass
      0.upto(@attributes.size - 1) do |y|
        @attributes[y][x + 1] = klass
      end
    end
  end
end