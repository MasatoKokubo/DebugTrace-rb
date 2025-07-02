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
end
