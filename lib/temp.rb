  class DebugTrace
    # Outputs an entering log when initializing and outputs a leaving log when deleting.
    # 
    # 初期化時に進入ログを出力し、削除時に退出ログを出力します。

    attr_accessor :name, :filename, :lineno

    def initialize(invoker)
      return unless @@config.is_enabled

      Mutex.new.synchronize do
        print_start

        state = current_state
        if invoker.nil?
          @name = ''
        else
          @name = invoker.class.name
          if @name == 'Class'
            @name = invoker.to_s
          end
          @name += '.'
        end

      # frame_summary = get_frame_summary(4)
        location = caller_locations(1, 1)[0]
        @name += location.base_label
        @filename = File.basename(location.absolute_path)
        @lineno = location.lineno

      # parent_frame_summary = get_frame_summary(5)
        parent_location = caller_locations(2, 2)[0]
        parent_filename = File.basename(parent_location.absolute_path)
        parent_lineno = parent_location.lineno

        indent_string = get_indent_string(state.nest_level, 0)
        if state.nest_level < state.previous_nest_level || _last_print_buff.is_multi_lines
          _logger.print(indent_string) # Empty Line
        end

        _last_print_buff = LogBuffer.new(@@config.maximum_data_output_width)
        _last_print_buff.no_break_append(
          @@config.enter_format % [@name, @filename, @lineno, parent_filename, parent_lineno]
        )
        _last_print_buff.line_feed
        _logger.print(indent_string + _last_print_buff.lines[0][1])

        state.up_nest
      end
    end

    def finalize
      return unless @@config.is_enabled

      Mutex.new.synchronize do
        print_start

        state = current_state

        if _last_print_buff.is_multi_lines
          _logger.print(get_indent_string(state.nest_level, 0)) # Empty Line
        end

        time = Time.now.utc - state.down_nest

        _last_print_buff = LogBuffer.new(@@config.maximum_data_output_width)
        _last_print_buff.no_break_append(
          @@config.leave_format % [@name, @filename, @lineno, time]
        )
        _last_print_buff.line_feed
        _logger.print(get_indent_string(state.nest_level, 0) + _last_print_buff.lines[0][1])
      end
    end
  end
