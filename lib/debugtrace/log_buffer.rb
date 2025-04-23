# log_buffer.rb
# (C) 2025 Masato Kokubo
require_relative 'common'

# Buffers logs.
class LogBuffer
  class LevelAndLog
    # Initializes this object.
    def initialize(nest_level, log)
      @nest_level = Common.check_type('nest_level', nest_level, Integer)
      @log = Common.check_type('log', log, String)
    end

    attr_reader :nest_level, :log

    def to_s
      "(LogBuffer.LevelAndLog){nest_level: #{@nest_level}, log: \"#{@log}\"}"
    end
  end

  # Initializes this object.
  def initialize(maximum_data_output_width)
    @maximum_data_output_width = Common.check_type('maximum_data_output_width', maximum_data_output_width, Integer)
    @nest_level = 0
    @append_nest_level = 0

    # tuples of data indentation level && log string
    @lines = []

    # buffer for a line of logs
    @last_line = ''
  end

  # Breaks the current line.
  def line_feed
    @lines << LevelAndLog.new(@nest_level + @append_nest_level, @last_line.rstrip)
    @append_nest_level = 0
    @last_line = ''
  end

  # Ups the data nest level.
  def up_nest
    @nest_level += 1
  end

  # Downs the data nest level.
  def down_nest
    @nest_level -= 1
  end

  # Appends a string representation of the value.
  # @param value (Object): The value to append
  # @param nest_level (int, optional): The nest level of the value. Defaults to 0
  # @param no_break (bool, optional): If true, does not break even if the maximum width is exceeded.
  #         Defaults to false
  # @return LogBuffer: This object
  def append(value, nest_level = 0, no_break = false)
    Common.check_type('nest_level', nest_level, Integer)
    Common.check_type('no_break', no_break, TrueClass)
    unless value.nil?
      string = value.to_s
      line_feed if !no_break && length > 0 && length + string.length > @maximum_data_output_width
      @append_nest_level = nest_level
      @last_line += string
    end
    self
  end

  # Appends a string representation of the value.
  # Does not break even if the maximum width is exceeded.
  # @param value (Object): The value to append
  # @return LogBuffer: This object
  def no_break_append(value)
    append(value, 0, true)
  end

  # Appends lines of another LogBuffer.
  # @param
  # @param separator (String): The separator string to append if not ''
  # @param buff (LogBuffer): Another LogBuffer
  # @returns LogBuffer: This object
  def append_buffer(separator, buff)
    Common.check_type('separator', separator, String)
    Common.check_type('buff', buff, LogBuffer)
    append(separator, 0, true) if separator != ''
    index = 0
    for line in buff.lines
      line_feed if index > 0
      append(line.log, line.nest_level, index == 0 && separator != '')
      index += 1
    end
    self
  end

  # The length of the last line.
  def length
    @last_line.length
  end

  # true if multiple line, false otherwise.
  def multi_lines?
    @lines.length > 1 || @lines.length == 1 && length > 0
  end

  # A list of tuple of data indentation level && log string.
  def lines
    lines = @lines.dup
    lines << LevelAndLog.new(@nest_level, @last_line) if length > 0
    lines
  end
end
