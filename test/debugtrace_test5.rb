# frozen_string_literal: false
# (C) 2025 Masato Kokubo

require "test_helper"
require_relative './contact'

class DebugTraceTest5 < Test::Unit::TestCase
  def setup
    @data_output_width = DebugTrace.config.data_output_width
    DebugTrace.config.data_output_width = 30
  end

  def teardown
    DebugTrace.config.data_output_width = @data_output_width
  end

  test 'print Array with line break' do
    DebugTrace.enter
    array = [1, 2, 3, 4, 5, 6, 7 ,8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
    DebugTrace.print('array', array)
    assert_match(/ array = \[\n  1, 2, 3, 4, 5, 6, 7, 8, 9, 10,\n/, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Hash with line break' do
    DebugTrace.enter
    hash = {'a' => 'A', 'b' => 'B', 'c' => 'C', 'd' => 'D', 'e' => 'E', 'f' => 'F', 'g' => 'G'}
    DebugTrace.print('hash', hash)
    assert_match(/ hash = {\n  'a': 'A', 'b': 'B', 'c': 'C',\n/, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Set with line break' do
    DebugTrace.enter
    set = Set.new([1, 2, 3, 4, 5, 6, 7 ,8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20])
    DebugTrace.print('set', set)
    assert_match(/ set = Set\[\n  1, 2, 3, 4, 5, 6, 7, 8, 9, 10,\n/, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Class with line break' do
    DebugTrace.enter
    contact = Contact.new('Akane', 'Apple', Date.new(2021, 2, 3))
    DebugTrace.print('contact', contact)
    assert_match(/ contact = Contact{\n  @first_name: 'Akane',\n  @last_name: 'Apple',\n  @birthday: 2021-02-03\n} /, DebugTrace.last_print_string)
    DebugTrace.leave
  end
end
