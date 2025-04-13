# print_options.rb
# (C) 2023 Masato Kokubo
# Hold output option values.
class PrintOptions
  # Initializes this object.
  # @param force_reflection (bool): If true, outputs using reflection even if it has a @_str__or @_repr__ method
  # @param output_private (bool): If true, also outputs private members when using reflection
  # @param output_method (bool): If true, also outputs method members when using reflection
  # @param collection_limit (Integer): Output limit of collection elements (overrides debugtarace.ini value)
  # @param string_limit (Integer): Output limit of string characters (overrides debugtarace.ini value)
  # @param bytes_limit (Integer): Output limit of byte array elements (overrides debugtarace.ini value)
  # @param reflection_nest_limit (Integer): Nest limits when using reflection (overrides debugtarace.ini value)
  def initialize(
    force_reflection, output_private, output_method,
    collection_limit, string_limit, bytes_limit, reflection_nest_limit)
    @force_reflection      = force_reflection
    @output_private        = output_private
    @output_method         = output_method
    @collection_limit      = collection_limit      == -1 ? @config.collection_limit      : collection_limit   
    @string_limit          = string_limit          == -1 ? @config.string_limit          : string_limit     
    @bytes_limit           = bytes_limit           == -1 ? @config.bytes_limit           : bytes_limit      
    @reflection_nest_limit = reflection_nest_limit == -1 ? @config.reflection_nest_limit : reflection_nest_limit
  end
end
