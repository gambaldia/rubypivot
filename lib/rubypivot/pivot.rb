module Rubypivot
#
# 2020-12-28 First
# 2020-12-30 Build an hash instead array
#
  class Pivot
    DEFAULT_OPTIONS = {
      data_type: :integer, # :integer, :float or :string
      column_sort: true,
      row_sort: true,
      header: true,
      row_header: true,
      # column_lookup: HashName
      # row_lookup: HashName
      # row_total: 'Title for total column, if nil row total not calculated'
    }.freeze

    attr_accessor :options
    def initialize(source_data, column_name, row_name, value_name, options = {})
      @options = DEFAULT_OPTIONS.dup
      @options.merge! options if options
      raise PivotError, "Source Data must be an array of [hash|dataset]." if !source_data.is_a?(Array)
      raise PivotError, "Column name must be specified." if column_name.nil?
      raise PivotError, "Row name must be specified." if row_name.nil?
      raise PivotError, "Value name must be specified." if value_name.nil?
      # TODO: error checks for options
      @column_name = column_name.to_sym
      @row_name = row_name.to_sym
      @value_name = value_name.to_sym
      @source_data = source_data
      #
      @rows_parsed = nil # holds hash of DataRow instances
      @column_titles = nil # array of column titles
      @row_titles = nil # array of row titles
    end

    # Column title can be predefined by caller
    def column_titles= (new_array)
      raise PivotError, "Column title must be an array" unless new_array.is_a?(Array)
      @column_titles = new_array
    end
    # Scan source data and buide titles array
    def column_titles
      @column_titles ||= make_column_list
    end
    # Row title can be predefined by caller
    def row_titles= (new_array)
      raise PivotError, "Row title must be an array" unless new_array.is_a?(Array)
      @row_titles = new_array
    end
    # Scan source data and buide titles array
    def row_titles
      @row_titles || make_row_list
    end

    def column_head(row_title)
      @options[:row_lookup] ? @options[:row_lookup][row_title] : row_title
    end

    def make_column_list
      @column_titles = [] unless @column_titles
      @source_data.each do |each_line|
        title = Pivot.get_title(@column_name, each_line)
        @column_titles << title unless @column_titles.include?(title)
      end
      @column_titles.sort! if @options[:column_sort]
      @column_titles
    end
  
    def make_row_list
      @row_titles = [] unless @row_titles
      @source_data.each do |each_line|
        title = Pivot.get_title(@row_name, each_line)
        @row_titles << title unless @row_titles.include?(title)
      end
      @row_titles.sort! if @options[:row_sort]
      @row_titles
    end

    def parse_data
      make_column_list unless @column_titles
      make_row_list unless @row_titles
      @rows_parsed = PivotRows.new(@options)
      @source_data.each do |each_line|
        column_title = Pivot.get_title(@column_name, each_line)
        row_title = Pivot.get_title(@row_name, each_line)
        value = Pivot.get_value(@value_name, each_line)
        row = @rows_parsed.get_row(row_title) # create a new row if not exists
        row.add(column_title, value)
      end
      self
    end

    # return an pivot hash. data rows only
    def build_data
      parse_data unless @rows_parsed
      res = {}
      @row_titles.each do |row_title|
        row = @rows_parsed.get_row(row_title)
        title = column_head(row_title)
        res[title] = row.to_a(column_titles)
      end
      res
    end
    alias :build_hash :build_data

    # return an pivot array with titles
    def build
      parse_data unless @rows_parsed
      res = []
      res << header_row if @options[:header]
      @row_titles.each do |row_title|
        row = @rows_parsed.get_row(row_title)
        data_array = []
        data_array << column_head(row_title) if @options[:row_header] 
        data_array += row.to_a(column_titles)
        data_array << row.total(column_titles) if @options[:row_total]
        res << data_array
      end
      res
    end
    alias :build_array :build

    # Make an array
    def header_row(title = nil)
      res = []
      res << "#{title}" if @options[:row_header]
      if @options[:column_lookup]
        @column_titles.each do |column|
          res << @options[:column_lookup][column]
        end
      else
        res += @column_titles
      end
      res << @options[:row_total] if @options[:row_total]
      res
    end

    def total_row(title = nil)
      parse_data unless @rows_parsed
      # title: message at title row, third(3) param is grand total true/false
      res = []
      res << title if @options[:row_header]
      res += @rows_parsed.total(@column_titles, @options[:row_total])
    end
  
    # get column title or row title
    def self.get_title(name, line)
      if line.is_a?(Hash)
        res = line[name]
      else
        res = line.send(name)
      end
      res = 'Empty' if res.nil?
      res
    end

    def self.get_value(name, line)
      if line.is_a?(Hash)
        line[name]
      else
        line.send(name)
      end
    end

    def self.build(data, column_name, row_name, data_name, options = {})
      obj = self.new(data, column_name, row_name, data_name, options)
      obj.build
    end
  end
end