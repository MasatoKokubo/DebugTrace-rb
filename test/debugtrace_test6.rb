# frozen_string_literal: false
# (C) 2025 Masato Kokubo

require "test_helper"

class DebugTraceTest6 < Test::Unit::TestCase
  test 'in eval' do
    eval("DebugTrace.enter")
    eval("DebugTrace.print('OK')")
    eval("DebugTrace.leave")
  end
end
