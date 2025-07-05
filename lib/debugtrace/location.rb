# frozen_string_literal: true
# location.rb
# (C) 2025 Masato Kokubo

# Contains source location information.
class Location
  attr_reader :name
  attr_reader :path
  attr_reader :lineno

  # Initializes this object.
  #
  # @param caller_location [Thread::Backtrace::Location] the caller location
  def initialize(caller_location)
    if caller_location == nil
      @name = 'unknown'
      @path = 'unknown'
      @lineno = 0
    else
      @name = caller_location.label
      if @name.start_with?('Object#')
        @name = caller_location.base_label
      end
      @path = caller_location.path || 'unknown'
      @lineno = caller_location.lineno
    end
  end

  # Returns a string representation of this object.
  #
  # @return [String] A string representation of this object
  def to_s()
      return "(Location){name: #{@name}, path: #{@path}, lineno: #{@lineno}"
  end
end
