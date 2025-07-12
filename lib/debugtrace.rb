# frozen_string_literal: true
# debugtrace.rb
# (C) 2025 Masato Kokubo
require 'logger'
require 'set'
require 'date'

# Require necessary files
require_relative 'debugtrace/version'
require_relative 'debugtrace/common'
require_relative 'debugtrace/config'
require_relative 'debugtrace/location'
require_relative 'debugtrace/log_buffer'
require_relative 'debugtrace/loggers'
require_relative 'debugtrace/state'

# The main module of DebugTrace-rb.
module DebugTrace
  @@no_reflection_classes = [
    FalseClass, TrueClass, Integer, Float, Rational, Complex, Range, Regexp,
  ]

  # Configuration values
  @@config = nil

  def self.config
    return @@config
  end

  # A Mutex for thread safety
  @@thread_mutex = Mutex.new

  # Hash (int: State) of thread id to a trace state
  @@state_hash = {}

  # Before thread id
  @@before_thread_id = 0

  # The last output content
  @@last_log_buff = nil

  # Reflected objects
  @@reflected_objects = []

  # The logger used by DebugTrace-py
  @@logger = nil

  # The before thread id
  @@before_thread_id = nil

  @@DO_NOT_OUTPUT = 'Do not output'

  # Initialize this class
  def self.initialize()
    config_path = ENV['DEBUGTRACE_CONFIG']
    if config_path == nil || config_path.empty?
      config_path = './debugtrace.yml'
    end

    @@config = Config.new(config_path)

    @@last_log_buff = LogBuffer.new(@@config.data_output_width)

    # Decide the logger class
    case @@config.logger_name.downcase
    when 'stdout'
      @@logger = StdOutLogger.new(@@config)
    when 'stderr'
      @@logger = StdErrLogger.new(@@config)
    when 'rubylogger'
      @@logger = RubyLogger.new(@@config)
    when 'file'
      @@logger = FileLogger.new(@@config)
    else
      @@logger = StdErrLogger.new(@@config)
      @@logger.print("DebugTrace-rb: logger = #{@@config.logger_name} is unknown. (#{@@config.config_path}) \n")
    end

    return unless @@config.enabled?

    @@logger.print("DebugTrace-rb #{DebugTrace::VERSION} on Ruby #{RUBY_VERSION}")
    @@logger.print("  config file: #{config_path}")
    @@logger.print("  logger: #{@@logger}")
  end

  # Contains options to pass to the print method.
  class PrintOptions
    attr_reader :reflection, :string_as_bytes, :minimum_output_size, :minimum_output_length,
                :output_size_limit, :output_length_limit, :reflection_limit

    # Initializes this object.
    #
    # @param reflection [TrueClass, FalseClass] use reflection if true
    # @param string_as_bytes [TrueClass, FalseClass] print string as byte array if true
    # @param minimum_output_size [Integer] the minimum value to output the number of elements for Array and Hash (overrides debugtarace.yml value)
    # @param minimum_output_length [Integer] the minimum value to output the length of String and byte array (overrides debugtarace.yml value)
    # @param output_size_limit [Integer] Output limit of collection elements (overrides debugtarace.yml value)
    # @param output_length_limit [Integer] the limit value of characters for string to output (overrides debugtarace.yml value)
    # @param reflection_limit [Integer] reflection limits when using reflection (overrides debugtarace.yml value)
    def initialize(
      reflection,
      string_as_bytes,
      minimum_output_size,
      minimum_output_length,
      output_size_limit,
      output_length_limit,
      reflection_limit
    )
      @reflection = reflection
      @string_as_bytes = string_as_bytes
      @minimum_output_size = minimum_output_size == -1 ? DebugTrace.config.minimum_output_size : minimum_output_size
      @minimum_output_length = minimum_output_length == -1 ? DebugTrace.config.minimum_output_length : minimum_output_length
      @output_size_limit = output_size_limit == -1 ? DebugTrace.config.output_size_limit : output_size_limit
      @output_length_limit = output_length_limit == -1 ? DebugTrace.config.output_length_limit : output_length_limit
      @reflection_limit = reflection_limit == -1 ? DebugTrace.config.reflection_limit : reflection_limit
    end
  end

  # Returns the current state.
  #
  # @return [State] the current state
  def self.current_state
    thread_id = Thread.current.object_id

    if @@state_hash.key?(thread_id)
      state = @@state_hash[thread_id]
    else
      state = State.new(thread_id)
      @@state_hash[thread_id] = state
    end

    return state
  end

  # Returns the current indent string.
  #
  # @param nest_level [Integer] the code nesting level
  # @param data_nest_level [Integer] the data nesting level
  # @return [Sring] the current indent string
  def self.get_indent_string(nest_level, data_nest_level)
    indent_str = @@config.indent_string * [[0, nest_level].max, @@config.maximum_indents].min
    data_indent_str = @@config.data_indent_string * [[0, data_nest_level].max, @@config.maximum_indents].min
    return indent_str + data_indent_str
  end

  # Returns a string representation of the variable contents.
  #
  # @param name [String] the variable name
  # @param value [Object] the value
  # @param print_options [PrintOptions] the print options
  def self.to_string(name, value, print_options)
    buff = LogBuffer.new(@@config.data_output_width)

    unless name.empty?
      buff.append(name).no_break_append(@@config.varname_value_separator)
    end

    if @@no_reflection_classes.include?(value.class)
      buff.append(value.to_s)
    else
      case value
      when nil
        buff.append('nil')
      when Symbol
        buff.append(':').no_break_append(value.name)
      when Class
        buff.append(value.name).no_break_append(' class')
      when Module
        buff.append(value.name).no_break_append(' module')
      when String
        value_buff = print_options.string_as_bytes ?
            to_string_bytes(value, print_options) : to_string_str(value, print_options)
        buff.append_buffer(value_buff)
      when DateTime, Time
        buff.append(value.strftime('%Y-%m-%d %H:%M:%S.%L%:z'))
      when Date
        buff.append(value.strftime('%Y-%m-%d'))
      when Dir, File
        buff.append(value.class.name)
        buff.append_buffer(to_string_str(value.path, print_options))
      when Array, Set, Hash
        value_buff = to_string_enumerable(value, print_options)
        buff.append_buffer(value_buff)
      else
        reflection = print_options.reflection || value.class.superclass == Struct

        begin
          to_s_string = reflection ? '' : value.to_s 
          if reflection || to_s_string.start_with?('#<')
            # use reflection
            value_buff = LogBuffer.new(@@config.data_output_width)
            if @@reflected_objects.any? { |obj| value.equal?(obj) }
              # cyclic reference
              value_buff.no_break_append(@@config.circular_reference_string)
            elsif @@reflected_objects.length > print_options.reflection_limit
              # over reflection level limitation
              value_buff.no_break_append(@@config.limit_string)
            else
              @@reflected_objects.push(value)
              value_buff = to_string_reflection(value, print_options)
              @@reflected_objects.pop
            end
            buff.append_buffer(value_buff)
          else
            buff.append(to_s_string)
          end
        rescue => e
          buff.append("Raised #{e.class.to_s}: '#{e.message}'")
        end
      end
    end

    return buff
  end

  # Returns a string representation of the string value
  #
  # @param value [String] the value
  # @param print_options [PrintOptions] the print options
  def self.to_string_str(value, print_options)
    double_quote = false
    single_quote_buff = LogBuffer.new(@@config.data_output_width)
    double_quote_buff = LogBuffer.new(@@config.data_output_width)

    if value.length >= print_options.minimum_output_length
      single_quote_buff.no_break_append(format(@@config.length_format, value.length))
      double_quote_buff.no_break_append(format(@@config.length_format, value.length))
    end

    single_quote_buff.no_break_append("'")
    double_quote_buff.no_break_append('"')

    count = 1
    value.each_char do |char|
      if count > print_options.output_length_limit
        single_quote_buff.no_break_append(@@config.limit_string)
        double_quote_buff.no_break_append(@@config.limit_string)
        break
      end
      case char
      when "'"
        double_quote = true
        double_quote_buff.no_break_append(char)
      when '"'
        single_quote_buff.no_break_append(char)
        double_quote_buff.no_break_append("\\\"")
      when "\\"
        double_quote = true
        double_quote_buff.no_break_append("\\\\")
      when "\n"
        double_quote = true
        double_quote_buff.no_break_append("\\n")
      when "\r"
        double_quote = true
        double_quote_buff.no_break_append("\\r")
      when "\t"
        double_quote = true
        double_quote_buff.no_break_append("\\t")
      else
        char_ord = char.ord
        if char_ord >= 0x00 && char_ord <= 0x1F || char_ord == 0x7F
          double_quote = true
          num_str = format('%02X', char_ord)
          double_quote_buff.no_break_append("\\x" + num_str)
        else
          single_quote_buff.no_break_append(char)
          double_quote_buff.no_break_append(char)
        end
      end
      count += 1
    end

    double_quote_buff.no_break_append('"')
    single_quote_buff.no_break_append("'")

    return double_quote ? double_quote_buff : single_quote_buff
  end

  # Returns a string representation of the string value which encoding is ASCII_8BIT.
  #
  # @param value [String] the value
  # @param print_options [PrintOptions] the print options
  def self.to_string_bytes(value, print_options)
    bytes_length = value.length
    buff = LogBuffer.new(@@config.data_output_width)

    if bytes_length >= print_options.minimum_output_length
      buff.no_break_append(format(@@config.length_format, bytes_length))
    end

    buff.no_break_append('[')

    multi_lines = bytes_length >= @@config.bytes_count_in_line

    if multi_lines
      buff.line_feed
      buff.up_nest
    end

    chars = ''
    count = 0
    value.each_byte do |element|
      if count != 0 && count % @@config.bytes_count_in_line == 0 && multi_lines
        buff.no_break_append('| ')
        buff.no_break_append(chars)
        buff.line_feed
        chars = ''
      end
      if count >= print_options.output_length_limit
        buff.no_break_append(@@config.limit_string)
        break
      end
      buff.no_break_append(format('%02X ', element))
      chars += element >= 0x20 && element <= 0x7E ? element.chr : '.'
      count += 1
    end

    if multi_lines
      # padding
      full_length = 3 * @@config.bytes_count_in_line
      current_length = buff.length
      current_length = full_length if current_length == 0
      buff.no_break_append(' ' * (full_length - current_length))
    end
    buff.no_break_append('| ')
    buff.no_break_append(chars)

    if multi_lines
      buff.line_feed
      buff.down_nest
    end
    buff.no_break_append(']')

    return buff
  end

  # Returns a string representation of the value using reflection.
  #
  # @param value [Object] the value
  # @param print_options [PrintOptions] the print options
  def self.to_string_reflection(value, print_options)
    buff = LogBuffer.new(@@config.data_output_width)

    buff.append(get_type_name(value, -1, print_options))

    body_buff = to_string_reflection_body(value, print_options)

    multi_lines = body_buff.multi_lines? || buff.length + body_buff.length > @@config.data_output_width

    buff.no_break_append('{')
    if multi_lines
      buff.line_feed
      buff.up_nest
    end

    buff.append_buffer(body_buff)

    if multi_lines
      buff.line_feed if buff.length > 0
      buff.down_nest
    end
    buff.no_break_append('}')

    return buff
  end

  # Returns a string representation of the value using reflection.
  #
  # @param value [Object] the value
  # @param print_options [PrintOptions] the print options
  def self.to_string_reflection_body(value, print_options)
    buff = LogBuffer.new(@@config.data_output_width)
    multi_lines = false
    index = 0

    variables = value.instance_variables
    variables.each do |variable|
      buff.no_break_append(', ') if index > 0

      var_value = value.instance_variable_get(variable)
      member_buff = LogBuffer.new(@@config.data_output_width)
      member_buff.append(variable).no_break_append(@@config.key_value_separator)
      member_buff.append_buffer(to_string('', var_value, print_options))
      buff.line_feed if index > 0 && (multi_lines || member_buff.multi_lines?)
      buff.append_buffer(member_buff)

      multi_lines = member_buff.multi_lines?
      index += 1
    end

    if value.class.superclass == Struct
      members = value.members
      hash = value.to_h
      members.each do |member|
        buff.no_break_append(', ') if index > 0

        var_value = hash[member]
        member_buff = LogBuffer.new(@@config.data_output_width)
        member_buff.append(member).no_break_append(@@config.key_value_separator)
        member_buff.append_buffer(to_string('', var_value, print_options))
        buff.line_feed if index > 0 && (multi_lines || member_buff.multi_lines?)
        buff.append_buffer(member_buff)

        multi_lines = member_buff.multi_lines?
        index += 1
      end
    end

    return buff
  end

  # Returns a string representation of an Array, Set or Hash.
  #
  # @param value [Array, Set, Hash] the value
  # @param print_options [PrintOptions] the print options
  def self.to_string_enumerable(values, print_options)
    open_char = '[' # Array 
    close_char = ']'

    if values.is_a?(Hash)
      # Hash
      open_char = '{'
      close_char = '}'
    elsif values.is_a?(Set)
      # Set
      open_char = 'Set['
      close_char = ']'
    end

    buff = LogBuffer.new(@@config.data_output_width)
    buff.append(get_type_name(values, values.size, print_options))
    buff.no_break_append(open_char)

    body_buff = to_string_enumerable_body(values, print_options)

    multi_lines = body_buff.multi_lines? || buff.length + body_buff.length > @@config.data_output_width

    if multi_lines
      buff.line_feed
      buff.up_nest
    end

    buff.append_buffer(body_buff)

    if multi_lines
      buff.line_feed
      buff.down_nest
    end

    buff.no_break_append(close_char)

    return buff
  end

  # Returns a string representation of the Array, Set or Hash value.
  #
  # @param value [Array, Set, Hash] the value
  # @param print_options [PrintOptions] the print options
  def self.to_string_enumerable_body(values, print_options)
    buff = LogBuffer.new(@@config.data_output_width)

    multi_lines = false
    index = 0

    values.each do |element|
      buff.no_break_append(', ') if index > 0

      if index >= print_options.output_size_limit
        buff.append(@@config.limit_string)
        break
      end

      element_buff = if values.is_a?(Hash)
          # Hash
          to_string_key_value(element[0], element[1], print_options)
        else
          # Array
          to_string('', element, print_options)
        end

      buff.line_feed if index > 0 && (multi_lines || element_buff.multi_lines?)
      buff.append_buffer(element_buff)

      multi_lines = element_buff.multi_lines?
      index += 1
    end

    buff.no_break_append(':') if values.is_a?(Hash) && values.empty?

    return buff
  end

  # Returns a string representation the key and the value.
  #
  # @param key [Object] the key
  # @param value [Object] the value
  # @param print_options [PrintOptions] the print options
  def self.to_string_key_value(key, value, print_options)
    buff = LogBuffer.new(@@config.data_output_width)
    key_buff = to_string('', key, print_options)
    value_buff = to_string('', value, print_options)
    buff.append_buffer(key_buff).no_break_append(@@config.key_value_separator).append_buffer(value_buff)
    buff
  end

  # Returns the type name.
  #
  # @param value [Object] the value
  # @param size [Object] the size of Array, Set or Hash
  # @param print_options [PrintOptions] the print options
  def self.get_type_name(value, size, print_options)
    type_name = value.class.to_s
    type_name = '' if %w[Array Hash Set].include?(type_name)

    if size >= print_options.minimum_output_size
      type_name += @@config.size_format % size
    end

    return type_name
  end

  # Called at the start of the print method.
  def self.print_start
    if @@config == nil
      initialize
    end
    return unless @@config.enabled?

    thread = Thread.current
    thread_id = thread.object_id
    return unless thread_id != @@before_thread_id

    # Thread changing
    @@logger.print('')
    @@logger.print(format(@@config.thread_boundary_format, thread.name, thread_id))
    @@logger.print('')
    @@before_thread_id = thread_id
  end

  # Prints the message or the value.
  #
  # @param name [String] a message if the value is not specified, otherwise the value name
  # @option value [Object] the value
  # @option reflection [TrueClass, FalseClass] use reflection if true
  # @param string_as_bytes [TrueClass, FalseClass] print string as byte array if true
  # @option minimum_output_size [Integer] the minimum value to output the number of elements for Array and Hash (overrides debugtarace.yml value)
  # @option minimum_output_length [Integer] the minimum value to output the length of String and byte array (overrides debugtarace.yml value)
  # @option output_size_limit [Integer] Output limit of collection elements (overrides debugtarace.yml value)
  # @option output_length_limit [Integer] the limit value of characters for string to output (overrides debugtarace.yml value)
  # @option reflection_limit [Integer] reflection limits when using reflection (overrides debugtarace.yml value)
  def self.print(name, value = @@DO_NOT_OUTPUT,
      reflection: false, string_as_bytes: false, minimum_output_size: -1, minimum_output_length: -1,
      output_size_limit: -1, output_length_limit: -1, reflection_limit: -1)
    @@thread_mutex.synchronize do
      print_start
      return value unless @@config.enabled?

      state = current_state
      @@reflected_objects.clear

      last_multi_lines = @@last_log_buff.multi_lines?

      if value.equal? @@DO_NOT_OUTPUT
        # without value
        @@last_log_buff = LogBuffer.new(@@config.data_output_width)
        @@last_log_buff.no_break_append(name)
      else
        # with value
        print_options = PrintOptions.new(
          reflection, string_as_bytes, minimum_output_size, minimum_output_length,
          output_size_limit, output_length_limit, reflection_limit
        )
        @@last_log_buff = to_string(name, value, print_options)
      end

      # append print suffix
      location = Location.new(caller_locations(3, 3)[0])

      @@last_log_buff.no_break_append(
        format(@@config.print_suffix_format, location.name, location.path, location.lineno)
      )

      @@last_log_buff.line_feed

      if last_multi_lines || @@last_log_buff.multi_lines?
        @@logger.print(get_indent_string(state.nest_level, 0)) # Empty Line
      end

      @@last_log_buff.lines.each do |line|
        @@logger.print(get_indent_string(state.nest_level, line.nest_level) + line.log)
      end
    end

    return value.equal? @@DO_NOT_OUTPUT ? nil : value
  end

  # Prints the start of the method.
  def self.enter
    @@thread_mutex.synchronize do
      print_start
      return unless @@config.enabled?

      state = current_state
      location = Location.new(caller_locations(3, 3)[0])
      parent_location = Location.new(caller_locations(4, 4)[0])

      indent_string = get_indent_string(state.nest_level, 0)
      if state.nest_level < state.previous_nest_level || @@last_log_buff.multi_lines?
        @@logger.print(indent_string) # Empty Line
      end

      @@last_log_buff = LogBuffer.new(@@config.data_output_width)
      @@last_log_buff.no_break_append(
        format(@@config.enter_format,
          location.name, location.path, location.lineno,
          parent_location.name, parent_location.path, parent_location.lineno)
      )
      @@last_log_buff.line_feed
      @@logger.print(indent_string + @@last_log_buff.lines[0].log)

      state.up_nest
    end
    return nil
  end

  # Prints the end of the method.
  #
  # @option [Object] the return value
  # @return [Object] return_value if specified, otherwise nil
  def self.leave(return_value = nil)
    @@thread_mutex.synchronize do
      print_start
      return return_value unless @@config.enabled?

      state = current_state
      location = Location.new(caller_locations(3, 3)[0])

      if @@last_log_buff.multi_lines?
        @@logger.print(get_indent_string(state.nest_level, 0)) # Empty Line
      end

      time = (Time.now.utc - state.down_nest) * 1000 # milliseconds <- seconds

      @@last_log_buff = LogBuffer.new(@@config.data_output_width)
      @@last_log_buff.no_break_append(
        format(@@config.leave_format, location.name, location.path, location.lineno, time)
      )
      @@last_log_buff.line_feed
      @@logger.print(get_indent_string(state.nest_level, 0) + @@last_log_buff.lines[0].log)
    end
    return return_value
  end

  # Returns the last print string.
  def self.last_print_string
    lines = @@last_log_buff.lines
    buff_string = lines.map { |line| @@config.data_indent_string * line.nest_level + line.log }.join("\n")

    state = nil
    @@thread_mutex.synchronize do
      state = current_state
    end

    return "#{get_indent_string(state.nest_level, 0)}#{buff_string}"
  end
end
