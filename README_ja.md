# DebugTrace-rb

[English](README.md)

**DebugTrace-rb** は、Rubyのデバッグ時にトレースログを出力するライブラリで、 Ruby 3.1.0以降で利用できます。  
メソッドの開始と終了箇所に`DebugTrace.enter`および`DebugTrace.leave` を埋め込む事で、開発中のRubyプログラムの実行状況を出力する事ができます。

### 1. 特徴

* 呼び出し元のメソッド名、ソースファイル名および行番号を自動的に出力。
* メソッドやオブジェクトのネストで、ログを自動的にインデント 。
* 値の出力で自動的に改行。
* リフレクションを使用してオブジェクト内容の出力が可能。
* `debugtrace.yml`ファイルの設定で、出力内容のカスタマイズが可能。

### 2. インストール

次のコマンドを実行して、gemをインストールし、アプリケーションのGemfileに追加します。

```bash
$ bundle add debugtrace
```

依存関係の管理にbundlerを使用していない場合は、次のコマンドを実行して gem をインストールします。

```bash
$ gem install debugtrace
```

### 3. 使用方法

デバッグ対象および関連するメソッドに対して以下を行います。

1. メソッドの先頭に`DebugTrace.enter`を挿入する。
1. メソッドの終了(または`return`文の直前)に`DebugTrace.leave`を挿入する。
1. 必要に応じて、引数、ローカル変数、戻り値をログに出力する`DebugTrace.print('foo', foo)`を挿入する。

以下は、DebugTrace-rbのメソッドを使用したRubyの例とそれを実行した際のログです。

```ruby
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
  DebugTrace.leave(contacts)
end

def func1
  DebugTrace.enter
  DebugTrace.print('Hello, World!')
  contacts = func2
  DebugTrace.leave(contacts)
end

contacts = func1
DebugTrace.print('contacts', contacts)
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

### 4. メソッド一覧

DebugTraceモジュールには以下のメソッドがあります。

<table>
  <caption>メソッド一覧</caption>
  <tr>
    <th style="text-align:center">メソッド名</th>
    <th style="text-align:center">引 数</th>
    <th style="text-align:center">戻り値</th>
    <th style="text-align:center">説 明</th>
  </tr>
  <tr>
    <td><code>enter</code></td>
    <td>なし</td>
    <td>なし</td>
    <td>メソッドの開始のログを出力する</td>
  </tr>
  <tr>
    <td><code>leave</code></td>
    <td><code>return_value</code>: このメソッドの戻り値 <small>(省略可)</small></td>
    <td><code>return_value</code> <small>(引数が省略された場合は<code>nil</code>)</small></td>
    <td>メソッドの終了のログを出力する</td>
  </tr>
  <tr>
    <td><code>print</code></td>
    <td>
      <code>name</code>: 値の名前<br>
      <code>value</code>: 値 <small>(省略可)</small><br>
      <small><i>以降の引数は、キーワード引数で省略可</i></small><br>
      <code>reflection</code>: <code>true</code>ならリフレクションを積極的に使用、<code>false</code>なら消極的に使用 <small>(デフォルト: <code>false</code>)</small><br>
      <small><i>以降の引数は、debugtrace.ymlで指定可能 (引数指定が優先)</i></small><br>
      <code>minimum_output_size</code>: <code>Array</code>, <code>Hash</code>および<code>Set</code>の要素数を出力する最小要素数<br>
      <code>minimum_output_length</code>: 文字列の長さを出力する最小の長さ<br>
      <code>output_size_limit</code>: <code>Array</code>, <code>Hash</code>および<code>Set</code>の要素の出力数の制限値<br>
      <code>output_length_limit</code>: 文字列の出力文字数の制限値<br>
      <code>reflection_limit</code>: リフレクションのネスト数の制限値<br>
    </td>
    <td>値の指定があれば引数値、なければ<code>nil</code></td>
    <td>
      値の指定があれば、<br>
      <code><値の名前> = <値></code><br>
      の形式でログに出力し、なければ<code>name</code>をメッセージとして出力する。
    </td>
  </tr>
</table>

### 5. debugtrace.ymlのプロパティ

環境変数`DEBUGTRACE_CONFIG`で、debugtrace.ymlのパスを指定できます。  
デフォルトのパスは、`./debugtrace.yml`です。  
debugtrace.ymlには以下のプロパティを指定できます。

<table>
  <caption>debugtrace.yml</caption>
  <tr>
    <th style="text-align:center">プロパティ名</th>
    <th style="text-align:center">説 明</th>
  </tr>
  <tr>
    <td><code>logger</code></td>
    <td>
      ログの出力先の指定<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>logger: stdout</code> - <small>標準出力</small><br>
        <code>logger: stderr</code> - <small>標準エラー出力</small><br>
        <code>logger: rubylogger</code> - <small>RubyのLoggerクラスを使用</small><br>
        <code>logger: file</code> - <small>指定のファイル</small>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>stderr</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>log_path</code></td>
    <td>
      <code>logger: rubylogger</code>または<code>logger: file</code>の場合のログの出力先のパス<br>
      <code>logger: file</code>の場合で先頭文字が<code>+</code>の場合は、ログを追記します。
      <small><b>設定例:</b></small>
      <ul>
        <code>logger: file</code><br>
        <code>log_path: +/var/log/debugtrace.log</code><br>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>debugtrace.log</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>rubylogger_format</code></td>
    <td>
      Rubyの<code>Logger</code>クラスを使用する際のフォーマット文字列<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>rubylogger_format: "%2$s %1$s %3$s %4$s\n"</code>
      </ul>
      <small><b>パラメータ:</b></small><br>
      <ul>
        <code>%1</code>: ログレベル <small>(DEBUG)</small><br>
        <code>%2</code>: 日時<br>
        <code>%3</code>: プログラム <small>(DebugTrace)</small><br>
        <code>%4</code>: メッセージ
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>rubylogger_format: "%2$s %1$s %4$s\n"</code>
      </ul>
      <small><b>参考:</b></small><br>
      <ul>
        <code><a href="https://docs.ruby-lang.org/ja/latest/class/Logger.html">class Logger</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>log_datetime_format</code></td>
    <td>
      ログの日時のフォーマット<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>log_datetime_format: "%Y/%m/%d %H:%M:%S.%L%"</code>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>log_datetime_format: "%Y-%m-%d %H:%M:%S.%L%:z"</code>
      </ul>
      <small><b>参考:</b></small><br>
      <ul>
        <code><a href="https://docs.ruby-lang.org/ja/latest/method/Date/s/_strptime.html">Date._strptime</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>enabled</code></td>
    <td>
      <code>true</code>ならログ出力が有効、<code>false</code>なら無効<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>enabled: false</code>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>enabled: true</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>enter_format</code></td>
    <td>
      メソッドの開始時に出力するログのフォーマット<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>enter_format: "┌ %1$s (%2$s:%3$d)"</code>
      </ul>
      <small><b>パラメータ:</b></small><br>
      <ul>
        <code>%1</code>: メソッド名<br>
        <code>%2</code>: ファイル名<br>
        <code>%3</code>: 行番号<br>
        <code>%4</code>: 呼び出し元メソッドのメソッド名<br>
        <code>%5</code>: 呼び出し元メソッドのファイル名<br>
        <code>%6</code>: 呼び出し元メソッドの行番号
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>enter_format: "Enter %1$s (%2$s:%3$d) <- %4$s (%5$s:%6$d)"</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>leave_format</code></td>
    <td>
      メソッド終了時に出力するログのフォーマット<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>leave_format: "└ %1$s (%2$s:%3$d) duration: %4$.2f ms"</code>
      </ul>
      <small><b>パラメータ:</b></small><br>
      <ul>
        <code>%1</code>: メソッド名<br>
        <code>%2</code>: ファイル名<br>
        <code>%3</code>: 行番号<br>
        <code>%4</code>: 対応する<code>enter</code>メソッドを呼び出してからの時間(ミリ秒)
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>leave_format: "Leave %1$s (%2$s:%3$d) duration: %4$.3f ms"</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>thread_boundary_format</code></td>
    <td>スレッド境界で出力する文字列のフォーマット<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>thread_boundary_format: "─────────────────────────────── %1$s #%2$d ──────────────────────────────"</code>
      </ul>
      <small><b>パラメータ:</b></small><br>
      <ul>
        <code>%1</code>: スレッド名<br>
        <code>%2</code>: スレッドのオブジェクトID<br>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>thread_boundary_format: "______________________________ %1$s #%2$d ______________________________"</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>maximum_indents</code></td>
    <td>インデントの最大数<br>
      <small><b>設定例:</b></small>
      <ul>
      <code>maximum_indents: 16</code>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>maximum_indents: 32</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>indent_string</code></td>
    <td>コードのインデント文字列<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>indent_string: "│ "</code>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>indent_string: "| "</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>data_indent_string</code></td>
    <td>
      データのインデント文字列<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>data_indent_string: "⧙ "</code>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>data_indent_string: "  "</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>limit_string</code></td>
    <td>
      制限を超えた場合に出力する文字列<br>
      <small><b>設定例:</b></small>
      <ul>
       <code>limit_string: "‥‥"</code>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>limit_string: "..."</code>
      </ul>
     </td>
  </tr>
  <tr>
    <td><code>circular_reference_string</code></td>
    <td>
      循環参照している場合に出力する文字列<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>circular_reference_string: "⤴ "</code>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>circular_reference_string: "*** cyclic reference ***"</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>varname_value_separator</code></td>
    <td>
      変数名と値のセパレータ文字列<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>varname_value_separator: " == "</code>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>varname_value_separator: " = "</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>key_value_separator</code></td>
    <td>
      <code>Hash</code>のキーと値およびオブジェクトの変数名と値のセパレータ文字列<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>key_value_separato: " => "</code>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>key_value_separato: ": "</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>print_suffix_format</code></td>
    <td>
      <code>print</code>メソッドで付加される文字列のフォーマット<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>print_suffix_format: " (%2$s/%1$s:%3$d)"</code>
      </ul>
      <br>
      <small><b>パラメータ:</b></small><br>
      <ul>
        <code>%1</code>: メソッド名<br>
        <code>%2</code>: ファイル名<br>
        <code>%3</code>: 行番号<br>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>print_suffix_format: " (%2$s:%3$d)"</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>size_format</code></td>
    <td>
      <code>Array</code>, <code>Hash</code>および<code>Set</code>の要素数の出力フォーマット<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>size_format: "(size=%d)"</code>
      </ul>
      <small><b>パラメータ:</b></small><br>
      <ul>
        <code>%1</code>: 要素数
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>size_format: "(size:%d)"</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>minimum_output_size</code></td>
    <td>
      <code>Array</code>, <code>Hash</code>および<code>Set</code>の要素数を出力する最小数<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>minimum_output_size: 2</code>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>minimum_output_size: 256</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>length_format</code></td>
    <td>
      文字列の長さの出力フォーマット<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>length_format: "(length=%d)"</code>
      </ul>
      <small><b>パラメータ:</b></small><br>
      <ul>
        <code>%1</code>: 文字列長
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>length_format: "(length:%d)"</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>minimum_output_length</code></td>
    <td>
      文字列の長さを出力する最小の長さ<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>minimum_output_length: 6</code>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>minimum_output_length: 256</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>data_output_width</code></td>
    <td>
      データの出力幅<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>data_output_width = 100</code>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>data_output_width: 70</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>bytes_count_in_line</code></td>
    <td>
      文字列をバイト配列として出力する場合の1行の出力数<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>bytes_count_in_line: 32</code>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>bytes_count_in_line: 16</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>output_size_limit</code></td>
    <td>
      Array</code>, <code>Hash</code>および<code>Set</code>の要素の出力数の制限値<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>output_size_limit: 64</code>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>output_size_limit: 128</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>output_length_limit</code></td>
    <td>
      文字列の出力文字数の制限値<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>output_length_limit: 64</code>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>output_length_limit: 256</code>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>reflection_limit</code></td>
    <td>
      リフレクションのネスト数の制限値<br>
      <small><b>設定例:</b></small>
      <ul>
        <code>reflection_limit: 3</code>
      </ul>
      <small><b>初期値:</b></small>
      <ul>
        <code>reflection_limit: 4</code>
      </ul>
    </td>
  </tr>
</table>

### 6. 修正履歴

[修正履歴](CHANGELOG_ja.md)

### 7. ライセンス

[MIT ライセンス(MIT)](LICENSE.txt)

_&copy; 2025 Masato Kokubo_

