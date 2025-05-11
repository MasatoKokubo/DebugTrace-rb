# frozen_string_literal: false
# (C) 2025 Masato Kokubo

require "test_helper"

class DebugTraceTest2 < Test::Unit::TestCase
  test 'print Rational' do
    DebugTrace.enter
    rational = Rational(-128, 256)
    DebugTrace.print('rational', rational)
    assert_match(/ rational = -1\/2 /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Complex' do
    DebugTrace.enter
    complex = Complex(2.5, -3.6)
    DebugTrace.print('complex', complex)
    assert_match(/ complex = 2.5-3.6i /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Range' do
    DebugTrace.enter
    range = Range.new(-10, 5)
    DebugTrace.print('range', range)
    assert_match(/ range = -10..5 /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Dir' do
    DebugTrace.enter
    dir = Dir.new('./test')
    DebugTrace.print('dir', dir)
    assert_match(/ dir = Dir'.\/test' /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print File' do
    DebugTrace.enter
    file = File.new('./test/debugtrace_test.rb')
    DebugTrace.print('file', file)
    assert_match(/ file = File'.\/test\/debugtrace_test.rb' /, DebugTrace.last_print_string)
    DebugTrace.leave
  end
end
