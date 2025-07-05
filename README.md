# DebugTrace-rb

[Japanese](README_ja.md)

**DebugTrace-rb** is a library that outputs trace logs when debugging Ruby, and is available for Ruby 3.1.0 and later.
By embedding `DebugTrace.enter` and `DebugTrace.leave` at the start and end of a method, you can output the execution status of a Ruby program you are developing.

## 1. Features

* Automatically outputs the calling method name, source file name, and line number.
* Automatically indents logs when nesting methods or objects.
* Automatically inserts line breaks when outputting values.
* Can output object contents using reflection.
* Output contents can be customized by configuring the `debugtrace.yml` file.

## 2. Installation

Run the following command to install the gem and add it to your application's Gemfile:

```bash
$ bundle add debugtrace
```

If you are not using bundler to manage dependencies, run the following command to install the gem:

```bash
$ gem install debugtrace
```

## 3. Usage

Do the following for the debug target and related methods.

1. Insert `DebugTrace.enter` at the beginning of the method.

1. Insert `DebugTrace.leave` at the end of the method (or just before the `return` statement).

1. Optionally, insert `DebugTrace.print('foo', foo)` to print arguments, local variables, and return values ​​to the log.

Below is an example of Ruby using DebugTrace-rb methods and the log when it is executed.

```ruby
# frozen_string_literal: true
# readme-example.rb
require 'debugtrace'

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
  DebugTrace.leave(contacts)
end

def func1
  DebugTrace.enter
  DebugTrace.print('Hello, World!')
  contacts = func2
  DebugTrace.leave(contacts)
end

func1
```

```log
2025-07-05 14:38:35.412+09:00 DebugTrace-rb 1.2.0 on Ruby 3.4.4
2025-07-05 14:38:35.412+09:00   config file: <No config file>
2025-07-05 14:38:35.412+09:00   logger: StdErrLogger
2025-07-05 14:38:35.412+09:00 
2025-07-05 14:38:35.412+09:00 ______________________________  #72 ______________________________
2025-07-05 14:38:35.412+09:00 
2025-07-05 14:38:35.412+09:00 Enter func1 (examples/readme-example.rb:29) <- <main> (examples/readme-example.rb:35)
2025-07-05 14:38:35.412+09:00 | Hello, World! (examples/readme-example.rb:30)
2025-07-05 14:38:35.412+09:00 | Enter func2 (examples/readme-example.rb:20) <- func1 (examples/readme-example.rb:31)
2025-07-05 14:38:35.412+09:00 | | Enter Contact#initialize (examples/readme-example.rb:10) <- Class#new (examples/readme-example.rb:22)
2025-07-05 14:38:35.412+09:00 | | Leave Contact#initialize (examples/readme-example.rb:15) duration: 0.012 ms
2025-07-05 14:38:35.412+09:00 | | 
2025-07-05 14:38:35.412+09:00 | | Enter Contact#initialize (examples/readme-example.rb:10) <- Class#new (examples/readme-example.rb:23)
2025-07-05 14:38:35.412+09:00 | | Leave Contact#initialize (examples/readme-example.rb:15) duration: 0.007 ms
2025-07-05 14:38:35.413+09:00 | Leave func2 (examples/readme-example.rb:25) duration: 0.234 ms
2025-07-05 14:38:35.413+09:00 Leave func1 (examples/readme-example.rb:32) duration: 0.379 ms
2025-07-05 14:38:35.413+09:00 
2025-07-05 14:38:35.413+09:00 contacts = [
2025-07-05 14:38:35.413+09:00   Contact{
2025-07-05 14:38:35.413+09:00     @id: 1, @firstName: 'Akane', @lastName: 'Apple', @birthday: 1991-02-03
2025-07-05 14:38:35.413+09:00   },
2025-07-05 14:38:35.413+09:00   Contact{
2025-07-05 14:38:35.413+09:00     @id: 2, @firstName: 'Yukari', @lastName: 'Apple',
2025-07-05 14:38:35.413+09:00     @birthday: 1992-03-04
2025-07-05 14:38:35.413+09:00   }
2025-07-05 14:38:35.413+09:00 ] (examples/readme-example.rb:36)
```

### 4. List of methods

DebugTrace module has the following methods.

<table>
  <caption>Method List</caption>
  <tr>
    <th style="text-align:center">Method name</th>
    <th style="text-align:center">Arguments</th>
    <th style="text-align:center">Return value</th>
    <th style="text-align:center">Description</th>
  </tr>
  <tr>
    <td><code>enter</code></td>
    <td><i>None</i></td>
    <td><i>None</i></td>
    <td>Outputs the start of the method to the log.</td>
  </tr>
  <tr>
    <td><code>leave</code></td>
    <td><code>return_value</code>: return value of this method<small>(Optional)</small></td>
    <td><code>return_value</code> <small>(<code>nil</code> if <code>return_value</code> is omitted)</small></td>
    <td>Output the end of the method to the log.</td>
  </tr>
  <tr>
    <td><code>print</code></td>
    <td>
      <code>name</code>: the value name<br>
      <code>value</code>: the value <small>(Optional)</small><br>
      <small><i>The following arguments are keyword arguments and optional</i></small><br>
      <code>reflection</code>: reflection is used aggressively if <code>true</code>, used passively if <code>false</code><small>(Default: <code>false</code>)</small><br>
      <small><i>The following arguments can be specified in debugtrace.yml (argument specification takes precedence)</i></small><br>
      <code>minimum_output_size</code>: The minimum number of elements to print for <code>Array</code>, <code>Hash</code> and <code>Set</code><br>
      <code>minimum_output_length</code>: The minimum length to print the length of the string<br>
      <code>output_size_limit</code>: The limit on the number of elements output for <code>Map</code>, <code>Hash</code> and <code>Set</code><br>
      <code>output_length_limit</code>: The limit on the number of characters that can be output from a string<br>
      <code>reflection_limit</code>: The limit of reflection nesting<br>
    </td>
    <td>the argument value if it is specified, otherwise <code>nil</code></td>
    <td>
      If the value is specified, it will be output to the log in the format:<br>
      <code><value name> = <value></code> <br>
      , otherwise prints <code>name</code> as a message.
    </td>
  </tr>
</table>

### 5. debugtrace.yml Properties

You can specify the path of debugtrace.yml with the environment variable `DEBUGTRACE_CONFIG`.  
The default path is `./debugtrace.yml`.  
You can specify the following properties in debugtrace.yml.

<table>
  <caption>debugtrace.yml</caption>
  <tr>
    <th style="text-align:center">Property Name</th>
    <th style="text-align:center">Description</th>
  </tr>
  <tr>
    <td><code>logger</code></td>
    <td>
      Specifying the log output destination<br>
      <small><b>Examples:</b></small>
      <ul>
        <code>logger: stdout</code> - <small>standard output</small><br>
        <code>logger: stderr</code> - <small>standard error output</small><br>
        <code>logger: rubylogger</code> - <small>use the Ruby Logger class</small><br>
        <code>logger: file</code> - <small>specified file</small>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>stderr</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>log_path</code></td>
    <td>
      Path to log output destination when using <code>rubylogger</code> or <code>file</code><br>
      If the first character is <code>+</code> and using <code>logger: file</code>, the log will be appended.<br>
      <small><b>Example:</b></small>
      <ul>
        <code>logger: file</code><br>
        <code>log_path: +/var/log/debugtrace.log</code><br>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>debugtrace.log</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>rubylogger_format</code></td>
    <td>
      The format string when using the Ruby <code>Logger</code> class<br>
      <small><b>Example:</b></small>
      <ul>
        <code>rubylogger_format: "%2$s %1$s %3$s %4$s\n"</code>
      </ul>
      <small><b>Parameters:</b></small><br>
      <ul>
        <code>%1</code>: the log level <small>(DEBUG)</small><br>
        <code>%2</code>: the date<br>
        <code>%3</code>: the program <small>(DebugTrace)</small><br>
        <code>%4</code>: the message
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>rubylogger_format: "%2$s %1$s %4$s\n"</code>
      </ul>
      <small><b>Reference:</b></small><br>
      <ul>
        <code><a href="https://docs.ruby-lang.org/ja/latest/class/Logger.html">class Logger</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>log_datetime_format</code></td>
    <td>
      Log date and time format<br>
      <small><b>Example:</b></small>
      <ul>
        <code>log_datetime_format: "%Y/%m/%d %H:%M:%S.%L%"</code>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>log_datetime_format: "%Y-%m-%d %H:%M:%S.%L%:z"</code>
      </ul>
      <small><b>Reference:</b></small><br>
      <ul>
        <code><a href="https://docs.ruby-lang.org/ja/latest/method/Date/s/_strptime.html">Date._strptime</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>enabled</code></td>
    <td>
      Enables logging if <code>true</code>,disables logging if <code>false</code><br>
      <small><b>Example:</b></small>
      <ul>
        <code>enabled: false</code>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>enabled: true</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>enter_format</code></td>
    <td>
      The log format to be output at the start of methods<br>
      <small><b>Example:</b></small>
      <ul>
        <code>enter_format: "┌ %1$s (%2$s:%3$d)"</code>
      </ul>
      <small><b>Parameters:</b></small><br>
      <ul>
        <code>%1</code>: the method name<br>
        <code>%2</code>: the file name<br>
        <code>%3</code>: the line number<br>
        <code>%4</code>: the method name of the calling method<br>
        <code>%5</code>: the file name of the calling method<br>
        <code>%6</code>: the line number of the calling method
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>enter_format: "Enter %1$s (%2$s:%3$d) <- %4$s (%5$s:%6$d)"</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>leave_format</code></td>
    <td>
      The format of the log output at the end of the method<br>
      <small><b>Example:</b></small>
      <ul>
        <code>leave_format: "└ %1$s (%2$s:%3$d) duration: %4$.2f ms"</code>
      </ul>
      <small><b>Parameters:</b></small><br>
      <ul>
        <code>%1</code>: the method name<br>
        <code>%2</code>: the file name<br>
        <code>%3</code>: the line number<br>
        <code>%4</code>: the time (in milliseconds) since the corresponding <code>enter</code> method was called
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>leave_format: "Leave %1$s (%2$s:%3$d) duration: %4$.3f ms"</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>thread_boundary_format</code></td>
    <td>The format string printed at thread boundaries<br>
      <small><b>Example:</b></small>
      <ul>
        <code>thread_boundary_format: "─────────────────────────────── %1$s #%2$d ──────────────────────────────"</code>
      </ul>
      <small><b>Parameters:</b></small><br>
      <ul>
        <code>%1</code>: the thread name<br>
        <code>%2</code>: the object ID of the thread<br>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>thread_boundary_format: "______________________________ %1$s #%2$d ______________________________"</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>maximum_indents</code></td>
    <td>Maximum indentation<br>
      <small><b>Example:</b></small>
      <ul>
      <code>maximum_indents: 16</code>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>maximum_indents: 32</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>indent_string</code></td>
    <td>The code indent string<br>
      <small><b>Example:</b></small>
      <ul>
        <code>indent_string: "│ "</code>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>indent_string: "| "</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>data_indent_string</code></td>
    <td>
      The data indent string<br>
      <small><b>Example:</b></small>
      <ul>
        <code>data_indent_string: "⧙ "</code>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>data_indent_string: "  "</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>limit_string</code></td>
    <td>
      The string to output if limit is exceeded<br>
      <small><b>Example:</b></small>
      <ul>
       <code>limit_string: "‥‥"</code>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>limit_string: "..."</code>
      </ul>
     </td>
  </tr>
  <tr>
    <td><code>circular_reference_string</code></td>
    <td>
      The string to output if there is a circular reference<br>
      <small><b>Example:</b></small>
      <ul>
        <code>circular_reference_string: "⤴ "</code>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>circular_reference_string: "*** Circular Reference ***"</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>varname_value_separator</code></td>
    <td>
      The separator string between variable name and value<br>
      <small><b>Example:</b></small>
      <ul>
        <code>varname_value_separator: " == "</code>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>varname_value_separator: " = "</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>key_value_separator</code></td>
    <td>
      The separator string for <code>Hash</code> key and value, and object variable name and value<br>
      <small><b>Example:</b></small>
      <ul>
        <code>key_value_separato: " => "</code>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>key_value_separato: ": "</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>print_suffix_format</code></td>
    <td>
      The format string added by the <code>print</code> method<br>
      <small><b>Example:</b></small>
      <ul>
        <code>print_suffix_format: " (%2$s/%1$s:%3$d)"</code>
      </ul>
      <br>
      <small><b>Parameters:</b></small><br>
      <ul>
        <code>%1</code>: the method name<br>
        <code>%2</code>: the file name<br>
        <code>%3</code>: the line number<br>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>print_suffix_format: " (%2$s:%3$d)"</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>size_format</code></td>
    <td>
      Output format for number of elements in <code>Array</code>, <code>Hash</code>, and <code>Set</code><br>
      <small><b>Example:</b></small>
      <ul>
        <code>size_format: "(size=%d)"</code>
      </ul>
      <small><b>Parameters:</b></small><br>
      <ul>
        <code>%1</code>: number of elements
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>size_format: "(size:%d)"</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>minimum_output_size</code></td>
    <td>
      The minimum number to print the number of elements in an <code>Array</code>, <code>Hash</code>, or <code>Set</code><br>
      <small><b>Example:</b></small>
      <ul>
        <code>minimum_output_size: 2</code>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>minimum_output_size: 256</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>length_format</code></td>
    <td>
      The format of string length<br>
      <small><b>Example:</b></small>
      <ul>
        <code>length_format: "(length=%d)"</code>
      </ul>
      <small><b>Parameters:</b></small><br>
      <ul>
        <code>%1</code>: the string length
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>length_format: "(length:%d)"</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>minimum_output_length</code></td>
    <td>
      The minimum length to print the length of the string<br>
      <small><b>Example:</b></small>
      <ul>
        <code>minimum_output_length: 6</code>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>minimum_output_length: 256</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>data_output_width</code></td>
    <td>
      Data output width<br>
      <small><b>Example:</b></small>
      <ul>
        <code>data_output_width = 100</code>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>data_output_width: 70</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>bytes_count_in_line</code></td>
    <td>
      Number of lines to output when outputting a string as a byte array<br>
      <small><b>Example:</b></small>
      <ul>
        <code>bytes_count_in_line: 32</code>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>bytes_count_in_line: 16</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>output_size_limit</code></td>
    <td>
      The limit on the number of elements output for <code>Array</code>, <code>Hash</code>, and <code>Set</code><br>
      <small><b>Example:</b></small>
      <ul>
        <code>output_size_limit: 64</code>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>output_size_limit: 128</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>output_length_limit</code></td>
    <td>
      The limit on the number of characters that can be output from a string<br>
      <small><b>Example:</b></small>
      <ul>
        <code>output_length_limit: 64</code>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>output_length_limit: 256</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>reflection_limit</code></td>
    <td>
      The limit of reflection nesting<br>
      <small><b>Example:</b></small>
      <ul>
        <code>reflection_limit: 3</code>
      </ul>
      <small><b>Default Value:</b></small>
      <ul>
        <code>reflection_limit: 4</code>
      </ul>
    </td>
  </tr>
</table>

### 6. CHANGELOG

[CHANGELOG](CHANGELOG.md)

### 7. License

[MIT License(MIT)](LICENSE.txt)

_&copy; 2025 Masato Kokubo_

