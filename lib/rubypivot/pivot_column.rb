# Not used at this moment
module Rubypivot
  class PivotColumn
    def self.get_title(name, line)
      if line.is_a?(Hash)
        res = line[name]
      else
        res = line.send(name)
      end
      res = 'Empty' if res.nil?
      res
    end
  end
end