# (C) 2025 Masato Kokubo
# frozen_string_literal: true

require "test_helper"

class DebugTraceTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::DebugTrace.const_defined?(:VERSION)
    end
  end

#  test "something useful" do
#    assert_equal("expected", "actual")
#  end
  test 'print nil' do
    value = nil
    DebugTrace.print('value', value)
    assert_match('.+value = nil .+')
  end  
end
