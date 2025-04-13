# config.rb
# (C) 2023 Masato Kokubo
require 'yaml'
require_relative 'common'

class Config
  def initialize(config_path)
    @config_path = Common::check_type('config_path', config_path, String)
    if File.exist?(@config_path)
      @config = YAML.load_file(@config_path)
    else
      @config_path = '<No config file>'
      @config = nil
    end
    @logger_name               = _get_config_value 'logger'                    , 'stderr'
    @logging_destination       = _get_config_value 'logging_destination'       , 'STDERR'
    @logging_format            = _get_config_value 'logging_format'            , "%2$s %1$s %4$s\n"
    @logging_datetime_format   = _get_config_value 'logging_datetime_format'   , '%Y-%m-%d %H:%M:%S.%L%:z'
    @enabled                   = _get_config_value 'enabled?'                  , true
    @enter_format              = _get_config_value 'enter_format'              , 'Enter %1$s (%2$s:%3$d) <- %4$s (%5$s:%6$d)'
    @leave_format              = _get_config_value 'leave_format'              , 'Leave %1$s (%2$s:%3$d) duration: %4$s'
    @thread_boundary_format    = _get_config_value 'thread_boundary_format'    , '______________________________ %1$s #%2$s ______________________________'
    @maximum_indents           = _get_config_value 'maximum_indents'           , 32
    @indent_string             = _get_config_value 'indent_string'             , '| '
    @data_indent_string        = _get_config_value 'data_indent_string'        , '  '
    @limit_string              = _get_config_value 'limit_string'              , '...'
    @non_output_string         = _get_config_value 'non_output_string'         , '...'
    @cyclic_reference_string   = _get_config_value 'cyclic_reference_string'   , '*** Cyclic Reference ***'
    @varname_value_separator   = _get_config_value 'varname_value_separator'   , ' = '
    @key_value_separator       = _get_config_value 'key_value_separator'       , ': '
    @print_suffix_format       = _get_config_value 'print_suffix_format'       , ' (%2$s:%3$d)'
    @count_format              = _get_config_value 'count_format'              , 'count:%d'
    @minimum_output_count      = _get_config_value 'minimum_output_count'      , 16
    @length_format             = _get_config_value 'length_format'             , 'length:%d'
    @minimum_output_length     = _get_config_value 'minimum_output_length'     , 16
    @maximum_data_output_width = _get_config_value 'maximum_data_output_width' , 70
    @bytes_count_in_line       = _get_config_value 'bytes_count_in_line'       , 16
    @collection_limit          = _get_config_value 'collection_limit'          , 128
    @bytes_limit               = _get_config_value 'bytes_limit'               , 256
    @string_limit              = _get_config_value 'string_limit'              , 256
    @reflection_nest_limit     = _get_config_value 'reflection_nest_limit'     , 4
  end

  def config_path              ; @config_path              ; end
  def logger_name              ; @logger_name              ; end
  def logging_destination      ; @logging_destination      ; end
  def logging_format           ; @logging_format           ; end
  def logging_datetime_format  ; @logging_datetime_format  ; end
  def enabled?                 ; @enabled                  ; end
  def enter_format             ; @enter_format             ; end
  def leave_format             ; @leave_format             ; end
  def thread_boundary_format   ; @thread_boundary_format   ; end
  def maximum_indents          ; @maximum_indents          ; end
  def indent_string            ; @indent_string            ; end
  def data_indent_string       ; @data_indent_string       ; end
  def limit_string             ; @limit_string             ; end
  def non_output_string        ; @non_output_string        ; end
  def cyclic_reference_string  ; @cyclic_reference_string  ; end
  def varname_value_separator  ; @varname_value_separator  ; end
  def key_value_separator      ; @key_value_separator      ; end
  def print_suffix_format      ; @print_suffix_format      ; end
  def count_format             ; @count_format             ; end
  def minimum_output_count     ; @minimum_output_count     ; end
  def length_format            ; @length_format            ; end
  def minimum_output_length    ; @minimum_output_length    ; end
  def maximum_data_output_width; @maximum_data_output_width; end
  def bytes_count_in_line      ; @bytes_count_in_line      ; end
  def collection_limit         ; @collection_limit         ; end
  def bytes_limit              ; @bytes_limit              ; end
  def string_limit             ; @string_limit             ; end
  def reflection_nest_limit    ; @reflection_nest_limit    ; end

  private

  # Gets the value related the key from debugtrace.ini file.
  # @param key (String): The key
  # @param defalut_value (Object): Value to return when the value related the key is undefined
  # @return  Object: Value related the key
  def _get_config_value(key, defalut_value)
    Common::check_type('key', key, String)
    value = defalut_value
    if @config != nil
      value = @config[key]
      if value == nil
        value = defalut_value
      else
        Common::check_type("config[#{key}]", value, defalut_value.class)
      end
    end
    value
  end
end
