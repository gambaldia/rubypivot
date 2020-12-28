module Rubypivot
  class HtmlTag
    def initialize(tag_name, options = {})
      @tag_name = tag_name
      @options = options
      @class_strings = []
    end

    def add_key(key, value)
      @options[key] = value
      self
    end
  
    def sanitize(value)
      return nil unless value
      array = value.split(/ +/)
      array.uniq!
      array.join(" ")
    end
  
    def add_class(class_string)
      if class_string
        class_string.to_s.split(/ +/).each do |str|
          next if str.nil? || @class_strings.include?(str)
          @class_strings << str
        end
      end
      self
    end
  
    def build_class
      return '' if @class_strings.empty?
      " class=\"#{@class_strings.join(' ')}\""
    end

    def open
      add_class(@options[:class])
      res = "<#{@tag_name}"
      res << build_class
      @options.each do |key, value|
        next if value.nil?
        case key
        when :class
          # class was handled first
        else
          res << " #{key}=\"#{value}\""
        end
      end
      res << ">"
      res
    end
  
    def close
      "</#{@tag_name}>"
    end
  
    def build(options = {})
      res = open
      # res << "\n" unless options[:compact]
      if block_given?
        res << yield.to_s
        # res << "\n" unless options[:compact]
        res << close
        # res << "\n" unless options[:compact]
      elsif options[:body]
        res << options[:body]
        # res << "\n" unless options[:compact]
        res << close
        # res << "\n" unless options[:compact]
      end
      res
    end
    alias :to_html :build
  
    def self.to_html(tag_name, options = {})
      instance = self.new(tag_name, body, options = {})
      instance.build(body)
    end
  
  end
end