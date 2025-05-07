# frozen_string_literal: true
# config.rb
# (C) 2025 Masato Kokubo
require 'yaml'
require_relative 'common'

# Retains the contents defined in debugtrace.yml.
class Config
  attr_reader :config_path
  attr_reader :config
  attr_reader :logger_name
  attr_reader :log_path
  attr_reader :logging_format
  attr_reader :logging_datetime_format
  attr_reader :enter_format
  attr_reader :leave_format
  attr_reader :thread_boundary_format
  attr_reader :maximum_indents
  attr_reader :indent_string
  attr_reader :data_indent_string
  attr_reader :limit_string
  attr_reader :non_output_string
  attr_reader :cyclic_reference_string
  attr_reader :varname_value_separator
  attr_reader :key_value_separator
  attr_reader :print_suffix_format
  attr_reader :size_format
  attr_reader :minimum_output_size
  attr_reader :length_format
  attr_reader :minimum_output_length
  attr_reader :maximum_data_output_width
  attr_reader :bytes_count_in_line
  attr_reader :collection_limit
  attr_reader :bytes_limit
  attr_reader :string_limit
  attr_reader :reflection_limit

  # Initializes with a yml file in the config_path.
  #
  # @param config_path [String] path of the yml file
  def initialize(config_path)
    @config_path = Common.check_type('config_path', config_path, String)
    if File.exist?(@config_path)
      @config = YAML.load_file(@config_path)
    else
      @config_path = '<No config file>'
      @config = nil
    end
    @logger_name               = get_value 'logger'                   , 'stderr'
    @log_path                  = get_value 'log_path'                 , 'debugtrace.log'
    @logging_format            = get_value 'logging_format'           , "%2$s %1$s %4$s\n"
    @logging_datetime_format   = get_value 'logging_datetime_format'  , '%Y-%m-%d %H:%M:%S.%L%:z'
    @enabled                   = get_value 'enabled'                  , true
    @enter_format              = get_value 'enter_format'             , 'Enter %1$s (%2$s:%3$d) <- %4$s (%5$s:%6$d)'
    @leave_format              = get_value 'leave_format'             , 'Leave %1$s (%2$s:%3$d) duration: %4$.3f ms'
    @thread_boundary_format    = get_value 'thread_boundary_format'   , '______________________________ %1$s #%2$s ______________________________'
    @maximum_indents           = get_value 'maximum_indents'          , 32
    @indent_string             = get_value 'indent_string'            , '| '
    @data_indent_string        = get_value 'data_indent_string'       , '  '
    @limit_string              = get_value 'limit_string'             , '...'
    @non_output_string         = get_value 'non_output_string'        , '...'
    @cyclic_reference_string   = get_value 'cyclic_reference_string'  , '*** Cyclic Reference ***'
    @varname_value_separator   = get_value 'varname_value_separator'  , ' = '
    @key_value_separator       = get_value 'key_value_separator'      , ': '
    @print_suffix_format       = get_value 'print_suffix_format'      , ' (%2$s:%3$d)'
    @size_format               = get_value 'size_format'              , '(size:%d)'
    @minimum_output_size       = get_value 'minimum_output_size'      , 256
    @length_format             = get_value 'length_format'            , '(length:%d)'
    @minimum_output_length     = get_value 'minimum_output_length'    , 256
    @maximum_data_output_width = get_value 'maximum_data_output_width', 70
    @bytes_count_in_line       = get_value 'bytes_count_in_line'      , 16
    @collection_limit          = get_value 'collection_limit'         , 128
    @bytes_limit               = get_value 'bytes_limit'              , 256
    @string_limit              = get_value 'string_limit'             , 256
    @reflection_limit          = get_value 'reflection_limit'         , 4
  end

  # Returns true if logging is enabled, false otherwise.
  #
  # @return [TrueClass, FalseClass] true if logging is enabled, false otherwise
  def enabled?
    return @enabled
  end

  private

  # Gets the value related the key from debugtrace.yml file.
  #
  # @param key [String] the key
  # @param defalut_value [Object] value to return if the value related the key is undefined
  # @return [Object] value related the key
  def get_value(key, defalut_value)
    Common.check_type('key', key, String)
    value = defalut_value
    unless @config.nil?
      value = @config[key]
      if value.nil?
        value = defalut_value
      else
        Common.check_type("config[#{key}]", value, defalut_value.class)
      end
    end
    return value
  end
end
