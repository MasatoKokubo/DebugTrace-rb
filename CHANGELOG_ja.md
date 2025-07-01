## 1.1.1 - 2025/7/1

#### バグ修正
* 条件によって`enter`, `leave`, `print`メソッドで例外がスローされるバグを修正。

## 1.1.0 - 2025/5/25

#### バグ修正

* `print`メソッドで`Array`, `Hash`および`Set`を出力する場合に要素間での改行が行われないバグの修正。

#### 仕様変更

* `print`メソッドの以下のキーワード引数名を変更、また`debugtrace.yml`の同名のプロパティ名も変更
    * `output_size_limit` ← `collection_limit`
    * `output_length_limit` ← `string_limit` および `bytes_limit` _(統一)_
 
## 1.0.1 - 2025/5/19

環境変数 `DEBUGTRACE_CONFIG` が設定されていない場合にエラーが発生するバグを修正

## 1.0.0 - 2025/5/18

最初のリリース
