# Create spread sheet array of row objects (SpreadTableLine) from array
# having row (tr) and cell (td) attributes
# to help HTML table
#
# 2020-12-31
#

class Array
  def to_spread(options = {})
    spread_array = SpreadTable.new(self, options)
  end
end

module Rubypivot
  class SpreadTableError < StandardError; end

  class SpreadTableLine
    LINE_TYPES = {
      header: 'Header',
      data:   'Data  ',
      total:  'Total ',
    }.freeze

    attr_reader :line_type, :options
    attr_accessor :line_data, :title, :attribut
    def initialize(line_type, line_data = [], options = {})
      @options = options
      @attribute = {}
      @attribs = []
      set_line_type(line_type, @options)
      # Desparate to have an array, convert it if not
      if line_data.is_a?(Array)
        @line_data = line_data
      elsif line_data.is_a?(Hash)
        @line_data = []
        line_data.each do |key, value|
          @line_data << value
        end
      elsif line_data.is_a?(String)
        @line_data = line_data.split(/[ \t]+/)
      else
        @line_data = [line_data]
      end
      if options[:title]
        if options[:title] == :first
          @title = @line_data.shift
        else
          @title = options[:title].to_s
        end
      end
    end

    def set_line_type(line_type, options = {})
      @line_type = line_type
      @line_type = :data unless LINE_TYPES[@line_type] # at least vaid must be set
      if @line_type == :data
        @attribute[:line_class] = options[:data_line_class] if options[:data_line_class]
        @attribute[:title_class] = options[:data_title_class] if options[:data_title_class]
      else
        @attribute[:line_class] = options[:header_line_class] if options[:header_line_class]
        @attribute[:title_class] = options[:header_title_class] if options[:header_title_class]
      end
      if @line_type == :header
        #
      else
        @attribute[:data_format] = options[:data_format] if options[:data_format]
      end
    end

    def data_width
      @line_data.size
    end

    def set_line_class(klass)
      @attribute[:line_class] = klass
    end

    def set_td_class(klass)
      @attribute[:cell_class] = klass
    end

    def set_title_class(klass)
      @attribute[:cell_class] = klass
    end

    def set_cell_class(callback)
      return unless callback
      if callback.is_a?(Method)
        @line_data.each_with_index do |cell_data, idx|
          klass = callback.call(cell_data, @title)
          @attribs[idx] = klass if klass
        end
      else
        @line_data.each_with_index do |cell_data, idx|
          @attribs[idx] = callback.to_s
        end
      end
    end

    def set_cell_callback(callback)
      return if callback.nil? || !callback.is_a?(Method) 
      if @line_type == :header
        @attribute[:cell_callback] = callback
      else
        @attribute[:cell_callback] = callback
      end
    end

    def line_data_formatted
      return @line_data if @line_type == :header || @attribute[:data_format].nil?
      res = []
      @line_data.each do |data|
        res << @attribute[:data_format] % data
      end
      res
    end

    def to_s
      res = ""
      res << "#{LINE_TYPES[@line_type]}: "
      res << "#{@title}: " if @title
      res << line_data_formatted.join(', ')
      res << " : Line Class: #{@attribute[:line_class]}"
      res << " : Cell Class: #{@attribute[:cell_class]}"
      res << " : Title Class: #{@attribute[:title_class]}"
      res
    end

    def to_html(options = {})
      tr = Rubypivot::HtmlTag.new('tr', class: @attribute[:line_class])
      td_str = ""
      if @title
        td = Rubypivot::HtmlTag.new('td', class: @attribute[:title_class] || @attribute[:cell_class])
        td_str << td.build{ @title } 
      end
      line_data_formatted.each_with_index do |cell_data, idx|
        if @attribute[:cell_callback]
          td_str << @attribute[:cell_callback].call(cell_data, @title)
        else
          td = Rubypivot::HtmlTag.new('td', class: @attribs[idx])
          td_str << td.build{ cell_data }
        end
      end
      res = tr.build { td_str }
      res << "\n" if options[:line_end] == :cr
      res
    end

    def make_col_class(options = {})
      klass = "col"
      klass << "-#{@attribute[:line_class]}" if @attribute[:line_class]
      klass << "-#{options[:width]}" if options[:width]
      # klass << " #{options[:klass]}" if options[:klass]
      klass
    end

    def to_grid(framework = :bootstrap, widths = [], options = {})
      res = "<div class=\"row\">"
      if @title
        div = Rubypivot::HtmlTag.new('div', class: make_col_class(width: widths[0])) # klass: @attribute[:title_class]
        res << div.build{ @title } 
      end
      line_data_formatted.each_with_index do |cell_data, idx|
        div = Rubypivot::HtmlTag.new('div', class: make_col_class(width: widths[idx + 1])) # klass: @attribute[:title_class]
        res << div.build{ cell_data }
      end
      res << "</div>/n"
      res
    end
  end

  class SpreadTable
    attr_reader :data_width, :data_height, :total_width
    attr_accessor :options, :rows
    def initialize(data_source, options = {})
      @rows = []
      @options = {}
      @options_for_line = {}
      options.each do |k, v|
        if [:title, :data_line_class, :header_line_class, :data_title_class, :header_title_class, :data_format].include?(k)
          @options_for_line[k] = v
        else
          @options[k] = v
        end
      end
      @attribs = []

      if data_source.is_a? Array
        data_source.each do |line|
          @rows << SpreadTableLine.new(:data, line, @options_for_line)
        end
      elsif data_source.is_a? Hash
        data_source.each do |title, values|
          @rows << SpreadTableLine.new(:data, values, title: title)
        end
      else
        @rows << SpreadTableLine.new(:data, line, line_options)
      end
      set_line_type(:header, @options[:header], false)
      set_line_type(:total, @options[:total], false)
      calc_data_size
    end

    def set_line_type(line_type, position = nil, recalc = true)
      return if line_type.nil? || position.nil?
      return unless SpreadTableLine::LINE_TYPES[line_type]
      case position
      when :first, :top
        @rows.first.set_line_type(line_type, @options_for_line)
      when :last, :bottom
        @rows.last.set_line_type(line_type, @options_for_line)
      else
        row = get_row(position)
        if row
          @rows[pos].set_line_type(line_type, @options_for_line)
        end
      end
      calc_data_size if recalc
    end

    def add_line(line_type = :data, line = [], line_options = {})
      @rows << SpreadTableLine.new(line_type, line, line_options)
      calc_data_size
    end

    def get_row(position)
      if position.is_a?(Symbol)
        if position == :last
          @rows.last
        else
          @rows.first
        end
      else
        pos = position.to_i
        @rows[pos] if pos >= 0 && pos < @rows.size - 1
      end
    end
    alias :line :get_row

    def total_height
      @rows.size
    end

    def calc_data_size
      @total_width = 0
      @data_width = 0
      @data_height = 0
      @rows.each do |row|
        w = row.data_width
        @total_width = w if @total_width < w
        next if row.line_type != :data
        @data_width = w if @data_width < w
        @data_height += 1
      end
      @total_width += 1 # Including title column
      self
    end

    def set_cell_class(callback)
      return unless callback
      each_data_line do |line|
        line.set_cell_class(callback)
      end
    end

    def set_line_class(klass)
      return unless klass
      each do |line|
        line.set_line_class(klass)
      end
    end

    def set_cell_callback(callback)
      return if callback.nil? || !callback.is_a?(Method)
      each_non_header_line do |line|
        line.set_cell_callback(callback)
      end
    end

    def each
      @rows.each do |row|
        yield row
      end
    end
  
    def each_data_line
      @rows.each do |row|
        next if row.line_type != :data
        yield row
      end
    end
  
    def each_header_line
      @rows.each do |row|
        next if row.line_type == :data
        yield row
      end
    end
  
    def each_non_header_line
      @rows.each do |row|
        next if row.line_type == :header
        yield row
      end
    end
  
    def to_s
      @rows.each do |row|
        puts row.to_s
      end
    end

    def to_html(options = {})
      line_end = options.delete(:line_end)
      res = HtmlTag.new('table', options).open
      res << "\n" if line_end == :cr
      @rows.each do |row|
        res << row.to_html(line_end: line_end)
      end
      res << "</table>\n"
      res
    end
    # Bootstrap grid
    def to_grid(framework = :bootstrap, widths = [], options = {})
      res = ""
      @rows.each do |row|
        res << row.to_grid(framework, widths)
      end
      res
    end
  
  end

end
