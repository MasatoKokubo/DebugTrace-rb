# common.rb
# (C) 2025 Masato Kokubo

#　Defines commonly used functions.
module Common
  # Check the value types.
  #
  # @param value_name [String] the value name
  # @param value [String] the value
  # @param type [Class] the type
  # @return [String] the value
  # @raise [TypeError] if the value is not an instance of the type or the subclass of the type
  def self.check_type(value_name, value, type)
    raise TypeError("Argument value_name (=#{value_name}) must be a String") unless value_name.is_a?(String)
    raise TypeError("Argument type (=#{type}) must be a Class") unless type.is_a?(Class)

    error = false
    if type == FalseClass || type == TrueClass
      # false or true
      if value.class != FalseClass && value.class != TrueClass
        error = true
      end
    else
      error = !value.is_a?(type)
    end

    if error
      value_string = value.instance_of?(String) ? "\"#{value}\"" : "#{value}"
      top_type_name = type.name.slice(0).upcase
      a = top_type_name == 'A' || top_type_name == 'I' || top_type_name == 'U' ||
        top_type_name == 'E' || top_type_name == 'O' ? 'an' : 'a'
      raise TypeError("Argument #{value_name} (=#{value_string}) must be #{a} #{type}")
    end
    return value
  end
end
