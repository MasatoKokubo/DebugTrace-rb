# frozen_string_literal: false
# (C) 2025 Masato Kokubo

require "test_helper"

class RaiseInToS
  def to_s
    raise 'error'
  end
end

class DebugTraceTest6 < Test::Unit::TestCase
  test 'in eval' do
    eval("DebugTrace.enter")
    eval("DebugTrace.print('OK')")
    eval("DebugTrace.leave")
  end

  test 'throw in to_s' do
    raise_in_to_s = RaiseInToS.new
    DebugTrace.enter
    DebugTrace.print('raise_in_to_s', raise_in_to_s)
    DebugTrace.leave
  end

  test 'throw in to_string_str' do
    DebugTrace.enter
    value = "\xA4\xA2\xA4\xA4\xA4\xA6\xA4\xA8\xA4\xAA"
    DebugTrace.print('value', value)
    assert_match(/ value = \[A4 A2 A4 A4 A4 A6 A4 A8 A4 AA \| ..........\] /, DebugTrace.last_print_string)
    DebugTrace.leave
  end
end
