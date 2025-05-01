# state.rb
# (C) 2025 Masato Kokubo
require_relative 'common'

# Have the trace state for a thread
# @author Masato Kokubo
class State
  def initialize(thread_id)
    @thread_id = Common::check_type('thread_id', thread_id, Integer)
    reset()
  end

  # @return the thread id.
  def thread_id
    @thread_id
  end

  # @return the nest level.
  def nest_level
    @nest_level
  end

  # @return the previous nest level.
  def previous_nest_level
    @previous_nest_level
  end

  # @return the previous line count.
  def previous_line_count
    @previous_line_count
  end

  # Sets the previous line count.
  # @param value the previous line count
  def previous_line_count=(value)
    @previous_line_count = Common::check_type('value', value, Integer)
  end

  def reset
    @nest_level = 0
    @previous_nest_level = 0
    @previous_line_count = 0
    @times = []
  end

  def to_s()
      "(State){thread_id: #{@thread_id}, nest_level: #{@nest_level}, previous_nest_level: #{@previous_nest_level}, previous_line_count: #{@previous_line_count}, times: #{@times}}"
  end

  # Ups the nest level.
  def up_nest
      @previous_nest_level = @nest_level
      if (@nest_level >= 0)
          @times.push(Time.now)
      end
      @nest_level += 1
  end

  #Downs the nest level.
  # @return Time: The time when the corresponding upNest method was invoked
  def down_nest
      @previous_nest_level = @nest_level
      @nest_level -= 1
      return @times.length > 0 ? @times.pop() : Time.now
  end
end
