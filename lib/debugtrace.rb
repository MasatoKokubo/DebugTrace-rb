# debugtrace.rb
# (C) 2025 Masato Kokubo
require 'logger'

# Require necessary files
require_relative 'debugtrace/version'
require_relative 'debugtrace/common'
require_relative 'debugtrace/config'
require_relative 'debugtrace/log_buffer'
require_relative 'debugtrace/loggers'
require_relative 'debugtrace/state'

module DebugTrace
  # Configuration values
  @@config = nil

  def self.config
    @@config
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

  def self.initialize(config_path = './debugtrace.yml')
    @@config = Config.new(config_path)

    @@last_log_buff = LogBuffer.new(@@config.maximum_data_output_width)

    # Decide the logger class
    case @@config.logger_name.downcase
    when 'stdout'
      @@logger = StdOutLogger.new(@@config)
    when 'stderr'
      @@logger = StdErrLogger.new(@@config)
    when 'logger'
      @@logger = LoggerLogger.new(@@config)
    when /^file:/
      @@logger = FileLogger.new(@@config)
    else
      Pr._print("debugtrace: (#{@@config.config_path}) logger = #{@@config.logger_name} is unknown", STDERR)
    end

    return unless @@config.enabled?

    ruby_version = RUBY_VERSION
    @@logger.print("DebugTrace-rb #{DebugTrace::VERSION} on Ruby #{ruby_version}")
    @@logger.print("  config file path: #{@@config.config_path}")
    @@logger.print("  logger: #{@@logger}")
  end

  class PrintOptions
    attr_reader :reflection,
                :minimum_output_count, :minimum_output_length,
                :collection_limit, :bytes_limit, :string_limit, :reflection_limit

    def initialize(
      reflection,
      minimum_output_count,
      minimum_output_length,
      collection_limit,
      bytes_limit,
      string_limit,
      reflection_limit
    )
      @reflection = reflection
      @minimum_output_count = minimum_output_count == -1 ? DebugTrace.config.minimum_output_count : minimum_output_count
      @minimum_output_length = minimum_output_length == -1 ? DebugTrace.config.minimum_output_length : minimum_output_length
      @collection_limit = collection_limit == -1 ? DebugTrace.config.collection_limit : collection_limit
      @bytes_limit = bytes_limit == -1 ? DebugTrace.config.bytes_limit : bytes_limit
      @string_limit = string_limit == -1 ? DebugTrace.config.string_limit : string_limit
      @reflection_limit = reflection_limit == -1 ? DebugTrace.config.reflection_limit : reflection_limit
    end
  end

  def self.current_state
    thread_id = Thread.current.object_id

    if @@state_hash.key?(thread_id)
      state = @@state_hash[thread_id]
    else
      state = State.new(thread_id)
      @@state_hash[thread_id] = state
    end

    state
  end

  def self.get_indent_string(nest_level, data_nest_level)
    indent_str = @@config.indent_string * [[0, nest_level].max, @@config.maximum_indents].min
    data_indent_str = @@config.data_indent_string * [[0, data_nest_level].max, @@config.maximum_indents].min
    indent_str + data_indent_str
  end

  def self.to_string(name, value, print_options)
    buff = LogBuffer.new(@@config.maximum_data_output_width)

    separator = ''
    unless name.empty?
      buff.append(name)
      separator = @@config.varname_value_separator
    end

    case value
    when nil
      buff.no_break_append(separator).append('nil')
    when FalseClass, TrueClass, Integer, Float
      buff.no_break_append(separator).append(value.to_s)
    when String
      value_buff = to_string_str(value, print_options)
      buff.append_buffer(separator, value_buff)
    when DateTime
      buff.no_break_append(separator).append(value.strftime('%Y-%m-%d %H:%M-%S.%L%:z'))
    when Date
      buff.no_break_append(separator).append(value.strftime('%Y-%m-%d'))
    when Time
      buff.no_break_append(separator).append(value.strftime('%H:%M-%S.%L%:z'))
    when Array, Set, Hash
      value_buff = to_string_enumerable(value, print_options)
      buff.append_buffer(separator, value_buff)
    else
      value_buff = LogBuffer.new(@@config.maximum_data_output_width)
      if !print_options.reflection && has_to_s_method?(value)
        # has to_s or inspect method
        value_buff.append('to_s: ')
        value_buff.no_break_append(value.to_s)
        buff.append_buffer(separator, value_buff)
      else
        # use reflection
        if @@reflected_objects.any? { |obj| value.equal?(obj) }
          # cyclic reference
          value_buff.no_break_append(@@config.cyclic_reference_string)
        elsif @@reflected_objects.length > print_options.reflection_limit
          # over reflection level limitation
          value_buff.no_break_append(@@config.limit_string)
        else
          @@reflected_objects.push(value)
          value_buff = to_string_reflection(value, print_options)
          @@reflected_objects.pop
        end
        buff.append_buffer(separator, value_buff)
      end
    end

    buff
  end

  def self.to_string_str(value, print_options)
    has_single_quote = false
    has_double_quote = false
    single_quote_buff = LogBuffer.new(@@config.maximum_data_output_width)
    double_quote_buff = LogBuffer.new(@@config.maximum_data_output_width)

    if value.length >= @@config.minimum_output_length
      single_quote_buff.no_break_append('(')
      single_quote_buff.no_break_append(format(@@config.length_format, value.length))
      single_quote_buff.no_break_append(')')
      double_quote_buff.no_break_append('(')
      double_quote_buff.no_break_append(format(@@config.length_format, value.length))
      double_quote_buff.no_break_append(')')
    end

    single_quote_buff.no_break_append("'")
    double_quote_buff.no_break_append('"')

    count = 1
    value.each_char do |char|
      if count > print_options.string_limit
        single_quote_buff.no_break_append(@@config.limit_string)
        double_quote_buff.no_break_append(@@config.limit_string)
        break
      end
      case char
      when "'"
        single_quote_buff.no_break_append("\\'")
        double_quote_buff.no_break_append(char)
        has_single_quote = true
      when '"'
        single_quote_buff.no_break_append(char)
        double_quote_buff.no_break_append("\\\"")
        has_double_quote = true
      when "\\"
        single_quote_buff.no_break_append("\\\\")
        double_quote_buff.no_break_append("\\\\")
      when "\n"
        single_quote_buff.no_break_append("\\n")
        double_quote_buff.no_break_append("\\n")
      when "\r"
        single_quote_buff.no_break_append("\\r")
        double_quote_buff.no_break_append("\\r")
      when "\t"
        single_quote_buff.no_break_append("\\t")
        double_quote_buff.no_break_append("\\t")
      else
        char_ord = char.ord
        if char_ord >= 0x00 && char_ord <= 0x1F || char_ord == 0x7F
          num_str = format('%02X', char_ord)
          single_quote_buff.no_break_append("\\x" + num_str)
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

    return double_quote_buff if has_single_quote && !has_double_quote

    single_quote_buff
  end

  def self.to_string_bytes(value, print_options)
    bytes_length = value.length
    buff = LogBuffer.new(@@config.maximum_data_output_width)
    buff.no_break_append('(')

    if value.is_a?(String)
      buff.no_break_append('bytes')
    elsif value.is_a?(Array)
      buff.no_break_append('bytearray')
    end

    if bytes_length >= @@config.minimum_output_length
      buff.no_break_append(' ')
      buff.no_break_append(format(@@config.length_format, bytes_length))
    end

    buff.no_break_append(') [')

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
      if count >= print_options.bytes_limit
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

    buff
  end

  def self.to_string_reflection(value, print_options)
    buff = LogBuffer.new(@@config.maximum_data_output_width)

    buff.append(get_type_name(value))

    body_buff = to_string_reflection_body(value, print_options)

    multi_lines = body_buff.multi_lines? || buff.length + body_buff.length > @@config.maximum_data_output_width

    buff.no_break_append('{')
    if multi_lines
      buff.line_feed
      buff.up_nest
    end

    buff.append_buffer('', body_buff)

    if multi_lines
      buff.line_feed if buff.length > 0
      buff.down_nest
    end
    buff.no_break_append('}')

    buff
  end

  def self.to_string_reflection_body(value, print_options)
    buff = LogBuffer.new(@@config.maximum_data_output_width)

    variables = value.instance_variables

    multi_lines = false
    index = 0
    variables.each do |variable|
      buff.no_break_append(', ') if index > 0

      var_value = value.instance_variable_get(variable)
      member_buff = LogBuffer.new(@@config.maximum_data_output_width)
      member_buff.append(variable)
      member_buff.append_buffer(@@config.key_value_separator, to_string('', var_value, print_options))
      buff.line_feed if index > 0 && (multi_lines || member_buff.multi_lines?)
      buff.append_buffer('', member_buff)

      multi_lines = member_buff.multi_lines?
      index += 1
    end

    buff
  end

  def self.to_string_enumerable(values, print_options)
    open_char = '[' # Array 
    close_char = ']'

    if values.is_a?(Hash)
      # Array
      open_char = '{'
      close_char = '}'
    elsif values.is_a?(Set)
      # Sete
      open_char = 'Set['
      close_char = ']'
    end

    buff = LogBuffer.new(@@config.maximum_data_output_width)
    buff.append(get_type_name(values, values.length))
    buff.no_break_append(open_char)

    body_buff = to_string_enumerable_body(values, print_options)

    multi_lines = body_buff.multi_lines? || buff.length + body_buff.length > @@config.maximum_data_output_width

    if multi_lines
      buff.line_feed
      buff.up_nest
    end

    buff.append_buffer('', body_buff)

    if multi_lines
      buff.line_feed
      buff.down_nest
    end

    buff.no_break_append(close_char)

    buff
  end

  def self.to_string_enumerable_body(values, print_options)
    buff = LogBuffer.new(@@config.maximum_data_output_width)

    multi_lines = false
    index = 0

    values.each do |element|
      buff.no_break_append(', ') if index > 0

      if index >= print_options.collection_limit
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
      buff.append_buffer('', element_buff)

      multi_lines = element_buff.multi_lines?
      index += 1
    end

    buff.no_break_append(':') if values.is_a?(Hash) && values.empty?

    buff
  end

  def self.to_string_key_value(key, value, print_options)
    buff = LogBuffer.new(@@config.maximum_data_output_width)
    key_buff = to_string('', key, print_options)
    value_buff = to_string('', value, print_options)
    buff.append_buffer('', key_buff).append_buffer(@@config.key_value_separator, value_buff)
    buff
  end

  def self.get_type_name(value, count = -1)
    type_name = value.class.to_s
    type_name = '' if %w[Array Hash Set].include?(type_name)

    if count >= @@config.minimum_output_count
      type_name += ' ' unless type_name.empty?
      type_name += @@config.count_format % count
    end

    type_name
  end

  def self.has_to_s_method?(value)
    begin
      value.public_method('to_s')
    rescue
      return false
    end
    return true
  end

  @@before_thread_id = nil

  def self.print_start
    if @@before_thread_id == nil
      DebugTrace.initialize
      return unless @@config.enabled?
    end

    thread = Thread.current
    thread_id = thread.object_id
    return unless thread_id != @@before_thread_id

    # Thread changing
    @@logger.print('')
    @@logger.print(format(@@config.thread_boundary_format, thread.name, thread_id))
    @@logger.print('')
    @@before_thread_id = thread_id
  end

  @@DO_NOT_OUTPUT = 'Do not output'

  def self.print(name, value = @@DO_NOT_OUTPUT, reflection: false,
      minimum_output_count: -1, minimum_output_length: -1,
      collection_limit: -1, bytes_limit: -1,
      string_limit: -1, reflection_limit: -1)
    @@thread_mutex.synchronize do
      print_start
      return value unless @@config.enabled?

      state = current_state
      @@reflected_objects.clear

      last_multi_lines = @@last_log_buff.multi_lines?

      if value.equal? @@DO_NOT_OUTPUT
        # without value
        @@last_log_buff = LogBuffer.new(@@config.maximum_data_output_width)
        @@last_log_buff.no_break_append(name)
      else
        # with value
        print_options = PrintOptions.new(
          reflection,
          minimum_output_count, minimum_output_length,
          collection_limit, bytes_limit,
          string_limit, reflection_limit
        )
        @@last_log_buff = to_string(name, value, print_options)
      end

      # append print suffix
      location = caller_locations(3, 3)[0]
      name     = !location.nil? ? location.base_label : ''
      filename = !location.nil? ? File.basename(location.absolute_path) : ''
      lineno   = !location.nil? ? location.lineno : 0

      @@last_log_buff.no_break_append(
        format(@@config.print_suffix_format, name, filename, lineno)
      )

      @@last_log_buff.line_feed

      if last_multi_lines || @@last_log_buff.multi_lines?
        @@logger.print(get_indent_string(state.nest_level, 0)) # Empty Line
      end

      @@last_log_buff.lines.each do |line|
        @@logger.print(get_indent_string(state.nest_level, line.nest_level) + line.log)
      end
    end

    value
  end

  def self.enter
    @@thread_mutex.synchronize do
      print_start
      return unless @@config.enabled?

      state = current_state

      location = caller_locations(3, 3)[0]
      name     = !location.nil? ? location.base_label : ''
      filename = !location.nil? ? File.basename(location.absolute_path) : ''
      lineno   = !location.nil? ? location.lineno : 0

      parent_location = caller_locations(4, 4)[0]
      parent_name     = !parent_location.nil? ? parent_location.base_label : ''
      parent_filename = !parent_location.nil? ? File.basename(parent_location.absolute_path) : ''
      parent_lineno   = !parent_location.nil? ? parent_location.lineno : 0

      indent_string = get_indent_string(state.nest_level, 0)
      if state.nest_level < state.previous_nest_level || @@last_log_buff.multi_lines?
        @@logger.print(indent_string) # Empty Line
      end

      @@last_log_buff = LogBuffer.new(@@config.maximum_data_output_width)
      @@last_log_buff.no_break_append(
        format(@@config.enter_format, name, filename, lineno, parent_name, parent_filename, parent_lineno)
      )
      @@last_log_buff.line_feed
      @@logger.print(indent_string + @@last_log_buff.lines[0].log)

      state.up_nest
    end
  end

  def self.leave
    @@thread_mutex.synchronize do
      print_start
      return unless @@config.enabled?

      state = current_state

      location = caller_locations(3, 3)[0]
      name = location.base_label
      filename = File.basename(location.absolute_path)
      lineno = location.lineno

      if @@last_log_buff.multi_lines?
        @@logger.print(get_indent_string(state.nest_level, 0)) # Empty Line
      end

      time = (Time.now.utc - state.down_nest) * 1000 # milliseconds <- seconds

      @@last_log_buff = LogBuffer.new(@@config.maximum_data_output_width)
      @@last_log_buff.no_break_append(
        format(@@config.leave_format, name, filename, lineno, time)
      )
      @@last_log_buff.line_feed
      @@logger.print(get_indent_string(state.nest_level, 0) + @@last_log_buff.lines[0].log)
    end
  end

  def self.last_print_string
    lines = @@last_log_buff.lines
    buff_string = lines.map { |line| _config.data_indent_string * line[0] + line[1] }.join("\n")

    state = nil
    @@thread_mutex.synchronize do
      state = current_state
    end

    "#{get_indent_string(state.nest_level, 0)}#{buff_string}"
  end
end
