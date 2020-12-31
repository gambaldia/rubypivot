module Rubypivot
  class PivotRows
    attr_reader :rows, :data_type
    def initialize(options = {})
      @options = options
      @data_type = options[:data_type]
      @rows = {}
    end

    def get_row(row_title)
      @rows[row_title] ||= PivotRow.new(row_title, @data_type)
    end
    alias :add_row :get_row

    def total(column_titles = [], show_grand_total = false)
      return ['Total', 'row', 'can', 'not', 'create', "type :#{@data_type}"] unless [:integer, :float].include?(@data_type)
      grand_total = @data_type == :float ? 0.0 : 0
      data_array = []
      column_titles.each do |column_title|
          total = @data_type == :float ? 0.0 : 0
          @rows.each do |row_title, row|
            v = row.get(column_title)
            total += v if v
          end
          grand_total += total if show_grand_total
          data_array << total
      end
      data_array << grand_total if show_grand_total
      data_array
    end
  end

  class PivotRow
    attr_reader :title
    def initialize(title, data_type = nil)
      @title = title # Title of the row : String
      @data_type = data_type
      @data = {}
    end

    def add(column_title, value)
      return unless value
      case @data_type
      when :integer
        @data[column_title] = 0 unless @data[column_title]
        @data[column_title] += value.to_i
      when :float
        @data[column_title] = 0.0 unless @data[column_title]
        @data[column_title] += value.to_f
      when :string
        @data[column_title] = value.to_s
      else # raw data
        @data[column_title] = value
      end
    end

    def get(column_title)
      return nil if column_title.nil?
      @data[column_title]
    end

    def to_a(column_titles)
      column_titles.map{|column_title| @data[column_title] }
    end

    def total(column_titles)
      return unless [:integer, :float].include?(@data_type)
      total = @data_type == :float ? 0.0 : 0
      column_titles.each do |column_title|
        total += @data[column_title] if @data[column_title]
      end
      total
    end

  end
end