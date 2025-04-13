# loggers.rb
# (C) 2023 Masato Kokubo
require 'logger'
require_relative 'common'
require_relative 'config'

# Abstract base class for logger classes.
class LoggerBase
  # Outputs the message.
  # @param message (String): The message to output
  def print(message)
    raise 'LoggerBase.print is an abstract method.'
  end
end

# Abstract base class for StdOut and StdErr classes.
class StdLogger < LoggerBase
  # Initializes this object.
  # @param iostream: Output destination
  def initialize(config, iostream)
    @config = Common::check_type("config", config, Config)
    @iostream = iostream
  end

  # Outputs the message.
  # @param message (String): The message to output
  def print(message)
    Common::check_type("message", message, String)
    datetime_str = Time.now().strftime(@config.logging_datetime_format)
    @iostream.puts "#{datetime_str} #{message}"
  end

end

# A logger class that outputs to $stdout.
class StdOutLogger < StdLogger
  # Initializes this object.
  def initialize(config)
    super(config, $stdout)
  end

  # Returns a string representation of this object.
  # @return String: A string representation of this object
  def to_s
    '$stdout logger'
  end
end

# A logger class that outputs to $stderr.
class StdErrLogger < StdLogger
  # Initializes this object.
  def initialize(config)
    super(config, $stderr)
  end

  # Returns a string representation of this object.
  # @return String: A string representation of this object
  def to_s
    '$stderr logger'
  end
end

# A logger class that outputs using the logging library.
class LoggerLogger
  private

  class Formatter
    def initialize(config)
      @config = config
    end

    def call(severity, datetime, progname, msg)
      datetime_str = datetime.strftime(@config.logging_datetime_format)
      format(@config.logging_format, severity, datetime_str, progname, msg)
    end
  end

  public

  def initialize(config)
    @config = Common::check_type("config", config, Config)
    @logger = Logger.new(
        @config.logging_destination,
        formatter: Formatter.new(@config),
        datetime_format: @config.logging_datetime_format)
  end

  # Outputs the message.
  # @param message (String): The message to output
  def print(message)
    Common::check_type("message", message, String)
    @logger.log(Logger::Severity::DEBUG, message, 'DebugTrace-rb')
  end

  # Returns a string representation of this object.
  # @return String: A string representation of this object
  def to_s
    'logging.Logger logger'
  end
end

# A logger class that outputs the file.
class FileLogger < LoggerBase
  def initialize(config, log_path)
    @config = Common::check_type("config", config, Config)
    Common::check_type("log_path", log_path, String)
    dir_path = File.dirname(log_path)
    if Dir.exist?(dir_path)
      @log_path = log_path
    else
      $stderr.puts "DebugTrace-rb: FileLogger: The directory '#{dir_path}' cannot be found."
      @log_path = ''
    end
  end
  
  def print(message)
    Common::check_type("message", message, String)
    if @log_path != ''
      File.open(@log_path, 'a') {|file|
        datetime_str = Time.now().strftime(@config.logging_datetime_format)
        file.puts "#{datetime_str} #{message}"
      }
    end
  end

  # Returns a string representation of this object.
  # @return String: A string representation of this object
  def to_s
    "File logger: '#{@log_path}"
  end
end
