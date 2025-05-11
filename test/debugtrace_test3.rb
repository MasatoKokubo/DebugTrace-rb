# frozen_string_literal: false
# (C) 2025 Masato Kokubo

require "test_helper"

class DebugTraceTest3 < Test::Unit::TestCase
  test 'print Array' do
    DebugTrace.enter
    array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    DebugTrace.print('array', array)
    assert_match(/ array = \[1, 2, 3, 4, 5, 6, 7, 8, 9, 10\] /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Array with size' do
    DebugTrace.enter
    array = [1, 2, 3, 4, 5]
    DebugTrace.print('array', array, minimum_output_size: 6)
    assert_match(/ array = \[1, 2, 3, 4, 5\] /, DebugTrace.last_print_string)

    DebugTrace.print('array', array, minimum_output_size: 5)
    assert_match(/ array = \(size:5\)\[1, 2, 3, 4, 5\] /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Array over limit' do
    DebugTrace.enter
    array = [1, 2, 3, 4, 5, 6]
    DebugTrace.print('array', array, collection_limit: 6)
    assert_match(/ array = \[1, 2, 3, 4, 5, 6\] /, DebugTrace.last_print_string)

    DebugTrace.print('array', array, collection_limit: 5)
    assert_match(/ array = \[1, 2, 3, 4, 5, \.\.\.\] /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Set' do
    DebugTrace.enter
    set = Set.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    DebugTrace.print('set', set)
    assert_match(/ set = Set\[1, 2, 3, 4, 5, 6, 7, 8, 9, 10\] /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Set with size' do
    DebugTrace.enter
    set = Set.new([1, 2, 3, 4, 5])
    DebugTrace.print('set', set, minimum_output_size: 6)
    assert_match(/ set = Set\[1, 2, 3, 4, 5\] /, DebugTrace.last_print_string)

    DebugTrace.print('set', set, minimum_output_size: 5)
    assert_match(/ set = \(size:5\)Set\[1, 2, 3, 4, 5\] /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Set over limit' do
    DebugTrace.enter
    set = Set.new([1, 2, 3, 4, 5, 6])
    DebugTrace.print('set', set, collection_limit: 6)
    assert_match(/ set = Set\[1, 2, 3, 4, 5, 6\] /, DebugTrace.last_print_string)

    DebugTrace.print('set', set, collection_limit: 5)
    assert_match(/ set = Set\[1, 2, 3, 4, 5, \.\.\.\] /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Hash' do
    DebugTrace.enter
    hash = {'A' => 'a', 'B' => 'b', 'C' => 'c', 'D' => 'd', 'E' => 'e', 'F' => 'f'}
    DebugTrace.print('hash', hash)
    assert_match(/ hash = {'A': 'a', 'B': 'b', 'C': 'c', 'D': 'd', 'E': 'e', 'F': 'f'} /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Hash with size' do
    DebugTrace.enter
    hash = {'A' => 'a', 'B' => 'b', 'C' => 'c', 'D' => 'd', 'E' => 'e'}
    DebugTrace.print('hash', hash, minimum_output_size: 6)
    assert_match(/ hash = {'A': 'a', 'B': 'b', 'C': 'c', 'D': 'd', 'E': 'e'} /, DebugTrace.last_print_string)

    DebugTrace.print('hash', hash, minimum_output_size: 5)
    assert_match(/ hash = \(size:5\){'A': 'a', 'B': 'b', 'C': 'c', 'D': 'd', 'E': 'e'} /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Hash over limit' do
    DebugTrace.enter
    hash = {'A' => 'a', 'B' => 'b', 'C' => 'c', 'D' => 'd', 'E' => 'e', 'F' => 'f'}
    DebugTrace.print('hash', hash, collection_limit: 6)
    assert_match(/ hash = {'A': 'a', 'B': 'b', 'C': 'c', 'D': 'd', 'E': 'e', 'F': 'f'} /, DebugTrace.last_print_string)

    DebugTrace.print('hash', hash, collection_limit: 5)
    assert_match(/ hash = {'A': 'a', 'B': 'b', 'C': 'c', 'D': 'd', 'E': 'e', \.\.\.\} /, DebugTrace.last_print_string)
    DebugTrace.leave
  end
end
