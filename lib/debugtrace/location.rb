# frozen_string_literal: true
# location.rb
# (C) 2025 Masato Kokubo

# Contains source location information.
class Location
  attr_reader :name
  attr_reader :filename
  attr_reader :lineno

  # Initializes this object.
  #
  # @param caller_location [Thread::Backtrace::Location] the caller location
  def initialize(caller_location)
    if caller_location == nil
      @name = 'unknown'
      @filename = 'unknown'
      @lineno = 0
    else
      @name = caller_location.base_label
      path = caller_location.absolute_path || caller_location.path || 'unknown'
      @filename = File.basename(path)
      @lineno = caller_location.lineno
    end
  end

  # Returns a string representation of this object.
  #
  # @return [String] A string representation of this object
  def to_s()
      return "(Location){name: #{@name}, filename: #{@filename}, lineno: #{@lineno}"
  end
end
