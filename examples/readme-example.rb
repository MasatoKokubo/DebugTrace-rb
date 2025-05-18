# frozen_string_literal: true
# readme-example.rb
#require 'debugtrace'
require_relative '../lib/debugtrace'

class Contact
  attr_reader :id, :firstName, :lastName, :birthday

  def initialize(id, firstName, lastName, birthday)
    DebugTrace.enter
    @id = id
    @firstName = firstName
    @lastName = lastName
    @birthday = birthday
    DebugTrace.leave
  end
end

def func2
  DebugTrace.enter
  contacts = [
    Contact.new(1, 'Akane' , 'Apple', Date.new(1991, 2, 3)),
    Contact.new(2, 'Yukari', 'Apple', Date.new(1992, 3, 4))
  ]
  DebugTrace.print('contacts', contacts)
  DebugTrace.leave
end

def func1
  DebugTrace.enter
  DebugTrace.print('Hello, World!')
  func2
  DebugTrace.leave
end

func1
