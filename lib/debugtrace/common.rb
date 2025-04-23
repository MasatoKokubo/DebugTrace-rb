# common.rb
# (C) 2025 Masato Kokubo
module Common
  def self.check_type(value_name, value, type)
    if !(value_name.is_a? String); raise "Argument value_name (=#{value_name}) must be a String"; end
    if !(type.is_a? Class); raise "Argument type (=#{type}) must be a Class"; end

    error = false
    if type == FalseClass || type == TrueClass
      # false or true
      if value.class != FalseClass && value.class != TrueClass
        check_error = true
      end
    else
        error = value.class != type
    end

    if error
      value_string = value.class == String ? "\"#{value}\"" : "#{value}"
      top_type_name = type.name.slice(0).upcase
      a = top_type_name == 'A' || top_type_name == 'I' || top_type_name == 'U' ||
        top_type_name == 'E' || top_type_name == 'O' ? 'an' : 'a'
      raise "Argument #{value_name} (=#{value_string}) must be #{a} #{type}"
    end
    value
  end
end
