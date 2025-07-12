# frozen_string_literal: false
# (C) 2025 Masato Kokubo

require "test_helper"
require "set"
require "date"

class DebugTraceTest1 < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::DebugTrace.const_defined?(:VERSION)
    end
  end

  test 'print nil' do
    DebugTrace.enter
    value = nil
    DebugTrace.print('value', value)
    assert_match(/ value = nil /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print false, true' do
    DebugTrace.enter
    value = false
    DebugTrace.print('value', value)
    assert_match(/ value = false /, DebugTrace.last_print_string)

    value = true
    DebugTrace.print('value', value)
    assert_match(/ value = true /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Integer' do
    DebugTrace.enter
    value = -123
    DebugTrace.print('value', value)
    assert_match(/ value = -123 /, DebugTrace.last_print_string)

    value = 0
    DebugTrace.print('value', value)
    assert_match(/ value = 0 /, DebugTrace.last_print_string)

    value = 123
    DebugTrace.print('value', value)
    assert_match(/ value = 123 /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Float' do
    DebugTrace.enter
    value = -123.456789
    DebugTrace.print('value', value)
    assert_match(/ value = -123.456789 /, DebugTrace.last_print_string)

    value = 0.0
    DebugTrace.print('value', value)
    assert_match(/ value = 0.0 /, DebugTrace.last_print_string)

    value = 123.456789
    DebugTrace.print('value', value)
    assert_match(/ value = 123.456789 /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Symbol' do
    DebugTrace.enter
    symbol = :Apple
    DebugTrace.print('symbol', symbol)
    assert_match(/ symbol = :Apple /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Class, Module' do
    DebugTrace.enter
    value = Integer
    DebugTrace.print('value', value)
    assert_match(/ value = Integer class /, DebugTrace.last_print_string)

    value = DebugTrace
    DebugTrace.print('value', value)
    assert_match(/ value = DebugTrace module /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print String' do
    DebugTrace.enter
    string = 'ABC'
    DebugTrace.print('string', string)
    assert_match(/ string = 'ABC' /, DebugTrace.last_print_string)

    string = "A'B'C"
    DebugTrace.print('string', string)
    assert_match(/ string = "A'B'C" /, DebugTrace.last_print_string)

    string = 'A"B"C'
    DebugTrace.print('string', string)
    assert_match(/ string = 'A"B"C' /, DebugTrace.last_print_string)

    string = "\\\n\r\t"
    DebugTrace.print('string', string)
    assert_match(/ string = "\\\\\\n\\r\\t" /, DebugTrace.last_print_string)

    string = "\x01\x02\x03"
    DebugTrace.print('string', string)
    assert_match(/ string = "\\x01\\x02\\x03" /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print String with length' do
    DebugTrace.enter
    string = 'ABCDE'
    DebugTrace.print('string', string, minimum_output_length: 6)
    assert_match(/ string = 'ABCDE' /, DebugTrace.last_print_string)

    DebugTrace.print('string', string, minimum_output_length: 5)
    assert_match(/ string = \(length:5\)'ABCDE' /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print String length over limit' do
    DebugTrace.enter
    string = 'ABCDEF'
    DebugTrace.print('string', string, output_length_limit: 6)
    assert_match(/ string = 'ABCDEF' /, DebugTrace.last_print_string)

    DebugTrace.print('string', string, output_length_limit: 5)
    assert_match(/ string = 'ABCDE...' /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print byte array' do
    DebugTrace.enter
    bytes = '@ABCDEFGHIJKLMN'.force_encoding(Encoding::ASCII_8BIT)
    DebugTrace.print('bytes', bytes, string_as_bytes: true)
    assert_match(/ bytes = \[40 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E \| @ABCDEFGHIJKLMN\] /,
      DebugTrace.last_print_string)

    bytes = '@ABCDEFGHIJKLMNO'.force_encoding(Encoding::ASCII_8BIT)
    DebugTrace.print('bytes', bytes, string_as_bytes: true)
    assert_match(/ bytes = \[\n  40 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F \| @ABCDEFGHIJKLMNO\n\] /,
      DebugTrace.last_print_string)

    bytes = '@ABCDEFGHIJKLMNOPQRSTU'.force_encoding(Encoding::ASCII_8BIT)
    DebugTrace.print('bytes', bytes, string_as_bytes: true)
    assert_match(/ bytes = \[\n  40 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F \| @ABCDEFGHIJKLMNO\n  50 51 52 53 54 55                               \| PQRSTU\n\] /,
      DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print byte array with length' do
    DebugTrace.enter
    bytes = '@ABCD'.force_encoding(Encoding::ASCII_8BIT)
    DebugTrace.print('bytes', bytes, string_as_bytes: true, minimum_output_length: 6)
    assert_match(/ bytes = \[40 41 42 43 44 \| @ABCD\] /, DebugTrace.last_print_string)

    DebugTrace.print('bytes', bytes, string_as_bytes: true, minimum_output_length: 5)
    assert_match(/ bytes = \(length:5\)\[40 41 42 43 44 \| @ABCD\] /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print byte array over limit' do
    DebugTrace.enter
    bytes = '@ABCDE'.force_encoding(Encoding::ASCII_8BIT)
    DebugTrace.print('bytes', bytes, string_as_bytes: true, output_length_limit: 6)
    assert_match(/ bytes = \[40 41 42 43 44 45 \| @ABCDE\] /, DebugTrace.last_print_string)

    DebugTrace.print('bytes', bytes, string_as_bytes: true, output_length_limit: 5)
    assert_match(/ bytes = \[40 41 42 43 44 \.\.\.\| @ABCD\] /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print DateTime, Date, Time' do
    DebugTrace.enter
    date_time = DateTime.new(2025, 5, 10, 12, 34, 56.789, '+0900')
    DebugTrace.print('date_time', date_time)
    assert_match(/ date_time = 2025-05-10 12:34:56.789\+09:00 /, DebugTrace.last_print_string)

    date = Date.new(2025, 5, 10)
    DebugTrace.print('date', date)
    assert_match(/ date = 2025-05-10 /, DebugTrace.last_print_string)

    time = Time.new(2025, 5, 10, 12, 34, 56.789, '+0900')
    DebugTrace.print('time', time)
    assert_match(/ time = 2025-05-10 12:34:56.789\+09:00 /, DebugTrace.last_print_string)

    DebugTrace.leave
  end
end
