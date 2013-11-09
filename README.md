Garanchu - ガラポンTV iOSアプリ
=========

ガラポンTVで録画した番組をiPadで視聴するためのアプリです。

## 開発環境

 * Xcode 5 + iOS SDK7
 * [CocoaPods](http://cocoapods.org/)
 * ガラポンTV APIのデベロッパーID

## セットアップ

```
git clone https://github.com/makotokw/GaranchuForiOS.git
cd GaranchuForiOS/Garanchu
cp Garanchu/WZGaranchuConfig.sample.h Garanchu/WZGaranchuConfig.h
bundle install --path=vendor/bundle
bundle exec pod install
open Garanchu.xcworkspace
```

``WZGaranchuConfig.h`` にデベロッパーIDを入れてください。


## ライセンス

GNU GENERAL PUBLIC LICENSE Version 3 (GPL v3)