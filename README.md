konami-lesson-notifier
===

## Description

コナミの代行情報を通知するためのbot

## Before to use

Spreadsheetを準備します。

A列に店舗名、B列に `facility_cd`、C列は空欄にしておきます。

( `facility_cd` は店舗スケジュールのURL `http://information.konamisportsclub.jp/newdesign/timetable.php?Facility_cd=XXXXXX` に記載された末尾の数字をそのまま入力します。）

設定例

![image](https://user-images.githubusercontent.com/531477/59727478-d2138d80-9270-11e9-9033-6c78d408a8c5.png)

その後「ツール -> スクリプトエディタ」からgasのエディタを起動し [main.js](https://github.com/manji602/konami-lesson-notifier/blob/master/main.js) をコピーしてください。

`main` メソッドを実行するとSlackに投稿されます。定期実行したい場合は「編集 -> 現在のプロジェクトのトリガー」から設定します。

## License

MIT

## Author

[Jun Hashimoto](http://github.com/manji602)
