# state.rb
# (C) 2025 Masato Kokubo
require_relative 'common'

# Contains the trace state for a thread
class State
  attr_reader :thread_id
  attr_reader :nest_level
  attr_reader :previous_nest_level

  # Initializes this object.
  #
  # @param thread_id [Integer] the object id of the thread
  def initialize(thread_id)
    @thread_id = Common.check_type('thread_id', thread_id, Integer)
    reset()
  end

  # Resets this object
  def reset
    @nest_level = 0
    @previous_nest_level = 0
    @times = []
  end

  # Returns a string representation of this object.
  #
  # @return [String] A string representation of this object
  def to_s()
      return "(State){thread_id: #{@thread_id}, nest_level: #{@nest_level}, previous_nest_level: #{@previous_nest_level}, times: #{@times}}"
  end

  # Ups the nest level.
  def up_nest
      @previous_nest_level = @nest_level
      if (@nest_level >= 0)
          @times.push(Time.now)
      end
      @nest_level += 1
  end

  # Downs the nest level.
  #
  # @return [Float] The time when the corresponding up_nest method was invoked
  def down_nest
      @previous_nest_level = @nest_level
      @nest_level -= 1
      return @times.length > 0 ? @times.pop() : Time.now
  end
end
