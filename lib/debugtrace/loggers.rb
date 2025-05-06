# loggers.rb
# (C) 2023 Masato Kokubo
require 'logger'
require_relative 'common'
require_relative 'config'

# @abstract Base class for logger classes.
class LoggerBase
  # @abstract Outputs the message.
  # @param message [String] The message to output
  # @raise [Exception] always
  def print(message)
    raise Exception.new('LoggerBase.print is an abstract method.')
  end

  # Returns a string representation of this object.
  # @return [String] A string representation of this object
  def to_s
    return "#{self.class.name}"
  end
end

# Abstract base class for StdOut and StdErr classes.
class StdLogger < LoggerBase
  # Initializes this object.
  # @param [IO] Output destination
  def initialize(config, output)
    @config = Common::check_type("config", config, Config)
    @output = output
  end

  # Outputs the message.
  # @param message [String] the message to output
  # @return [String] the message
  def print(message)
    Common::check_type("message", message, String)
    datetime_str = Time.now().strftime(@config.logging_datetime_format)
    @output.puts "#{datetime_str} #{message}"
  end

end

# A logger class that outputs to $stdout.
class StdOutLogger < StdLogger
  # Initializes this object.
  # config [Config] a configuration object
  def initialize(config)
    super(config, $stdout)
  end
end

# A logger class that outputs to $stderr.
class StdErrLogger < StdLogger
  # Initializes this object.
  # config [Config] a configuration object
  def initialize(config)
    super(config, $stderr)
  end
end

# A logger class that outputs using Ruby Logger.
class RubyLogger
  private

  class Formatter
    # Initializes this object.
    # config [Config] a configuration object
    def initialize(config)
      @config = Common::check_type("config", config, Config)
    end

    def call(severity, datetime, progname, msg)
      datetime_str = datetime.strftime(@config.logging_datetime_format)
      format(@config.logging_format, severity, datetime_str, progname, msg)
    end
  end

  public

  # Initializes this object.
  #
  # @param config [Config] a configuration object
  def initialize(config)
    @config = Common::check_type("config", config, Config)
    @logger = Logger.new(
        @config.log_path,
        formatter: Formatter.new(@config),
        datetime_format: @config.logging_datetime_format)
  end

  # Outputs the message.
  #
  # @param message [String] The message to output
  def print(message)
    Common::check_type("message", message, String)
    @logger.log(Logger::Severity::DEBUG, message, 'DebugTrace-rb')
    return message
  end

  # Returns a string representation of this object.
  #
  # @return [String] A string representation of this object
  def to_s
    return "Ruby #{Logger.name} path: #{@config.log_path}"
  end
end

# A logger class that outputs the file.
class FileLogger < LoggerBase
  @@log_path_default = 'debugtrace.log'

  # Initializes this object.
  #
  # @parm config [Config] a configuration object
  def initialize(config)
    @log_path = @@log_path_default
    @config = Common::check_type("config", config, Config)
    Common::check_type("log_path", config.log_path, String)
    @log_path = config.log_path
    @append = false

    if @log_path.start_with?('+')
      @log_path = @log_path[1..-1]
      @append = true
    end

    dir_path = File.dirname(@log_path)

    if !Dir.exist?(dir_path)
      @log_path = @@log_path_default
      @append = true
      print("DebugTrace-rb: FileLogger: The directory '#{dir_path}' cannot be found.\n")
    end

    if !@append
      File.open(@log_path, 'w') { |file|
      }
    end
  end
  
  # Outputs the message.
  #
  # @param message [String] the message to output
  # @return [String] the message
  def print(message)
    if File.exist?(@log_path)
      File.open(@log_path, 'a') { |file|
        datetime_str = Time.now().strftime(@config.logging_datetime_format)
        file.puts "#{datetime_str} #{message}"
      }
    end
    return message
  end

  # Returns a string representation of this object.
  #
  # @return [String] A string representation of this object
  def to_s
    return "#{self.class.name} path: #{@log_path}, append: #{@append}"
  end
end
