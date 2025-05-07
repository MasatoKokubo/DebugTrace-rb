# frozen_string_literal: false
# (C) 2025 Masato Kokubo

require "test_helper"

class DebugTraceTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::DebugTrace.const_defined?(:VERSION)
    end
  end

  test 'print nil' do
    DebugTrace.enter
    value = nil
    DebugTrace.print('value', value)
    assert_match(/value = nil/, DebugTrace.last_print_string)
    DebugTrace.leave
  end  

  test 'print false, true' do
    DebugTrace.enter
    value = false
    DebugTrace.print('value', value)
    assert_match(/value = false/, DebugTrace.last_print_string)

    value = true
    DebugTrace.print('value', value)
    assert_match(/value = true/, DebugTrace.last_print_string)
    DebugTrace.leave
  end  

  test 'print Integer' do
    DebugTrace.enter
    value = -123
    DebugTrace.print('value', value)
    assert_match(/value = -123/, DebugTrace.last_print_string)

    value = 0
    DebugTrace.print('value', value)
    assert_match(/value = 0/, DebugTrace.last_print_string)

    value = 123
    DebugTrace.print('value', value)
    assert_match(/value = 123/, DebugTrace.last_print_string)
    DebugTrace.leave
  end  

  test 'print Float' do
    DebugTrace.enter
    value = -123.456789
    DebugTrace.print('value', value)
    assert_match(/value = -123.456789/, DebugTrace.last_print_string)

    value = 0.0
    DebugTrace.print('value', value)
    assert_match(/value = 0.0/, DebugTrace.last_print_string)

    value = 123.456789
    DebugTrace.print('value', value)
    assert_match(/value = 123.456789/, DebugTrace.last_print_string)
    DebugTrace.leave
  end  

  test 'print Symbol' do
    DebugTrace.enter
    value = :Apple
    DebugTrace.print('value', value)
    assert_match(/value = :Apple/, DebugTrace.last_print_string)
    DebugTrace.leave
  end  

  test 'print Class, Module' do
    DebugTrace.enter
    value = Integer
    DebugTrace.print('value', value)
    assert_match(/value = Integer class/, DebugTrace.last_print_string)

    value = DebugTrace
    DebugTrace.print('value', value)
    assert_match(/value = DebugTrace module/, DebugTrace.last_print_string)
    DebugTrace.leave
  end  

  test 'print String' do
    DebugTrace.enter
    value = 'ABC'
    DebugTrace.print('value', value)
    assert_match(/value = 'ABC'/, DebugTrace.last_print_string)

    value = "A'B'C"
    DebugTrace.print('value', value)
    assert_match(/value = "A'B'C"/, DebugTrace.last_print_string)

    value = 'A"B"C'
    DebugTrace.print('value', value)
    assert_match(/value = 'A"B"C'/, DebugTrace.last_print_string)

    value = "\\\n\r\t"
    DebugTrace.print('value', value)
    assert_match(/value = "\\\\\\n\\r\\t"/, DebugTrace.last_print_string)

    value = "\x01\x02\x03"
    DebugTrace.print('value', value)
    assert_match(/value = "\\x01\\x02\\x03"/, DebugTrace.last_print_string)
  end  

  test 'print byte array' do
    value = 'ABCD'.force_encoding(Encoding::ASCII_8BIT)
    DebugTrace.print('value', value)
    assert_match(/value = \[41 42 43 44 | ABCD\]/, DebugTrace.last_print_string)
    DebugTrace.leave
  end  
end
