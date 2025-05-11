# frozen_string_literal: false
# (C) 2025 Masato Kokubo

require "test_helper"

class Contact
  attr_reader :first_name, :last_name, :birthday
  def initialize(first_name, last_name, birthday)
    @first_name = first_name
    @last_name = last_name
    @birthday = birthday
  end
end

class DebugTraceTest4 < Test::Unit::TestCase
  test 'print Class' do
    DebugTrace.enter
    contact = Contact.new('Akane', 'Apple', Date.new(2021, 2, 3))
    DebugTrace.print('contact', contact)
    assert_match(/ contact = Contact\{@first_name: 'Akane', @last_name: 'Apple', @birthday: 2021-02-03\} /, DebugTrace.last_print_string)
    DebugTrace.leave
  end

  test 'print Struct' do
    DebugTrace.enter
    contact_struct = Struct.new('Contact', :first_name, :last_name, :birthday)
    contact = contact_struct.new('Saika', 'Apple', Date.new(2022, 3, 4))
    DebugTrace.print('contact', contact)
    assert_match(/ contact = Struct::Contact\{first_name: 'Saika', last_name: 'Apple', birthday: 2022-03-04\} /, DebugTrace.last_print_string)
    DebugTrace.leave
  end
end
