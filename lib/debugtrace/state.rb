# state.rb
# (C) 2025 Masato Kokubo
require_relative 'common'

# Have the trace state for a thread
# @author Masato Kokubo
class State
  attr_reader :thread_id
  attr_reader :nest_level
  attr_reader :previous_nest_level

  def initialize(thread_id)
    @thread_id = thread_id
    reset()
  end

  def reset
    @nest_level = 0
    @previous_nest_level = 0
    @times = []
  end

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
      return nil
  end

  #Downs the nest level.
  # @return Time: The time when the corresponding upNest method was invoked
  def down_nest
      @previous_nest_level = @nest_level
      @nest_level -= 1
      return @times.length > 0 ? @times.pop() : Time.now
  end
end
