Garanchu - ガラポンTV iOSアプリ
=========

ガラポンTVで録画した番組をiPadで視聴するためのアプリです。

## 開発環境

 * Xcode 5.1.1 + iOS SDK 7.1
 * [CocoaPods](http://cocoapods.org/)
 * ガラポンTV APIのデベロッパーID

## セットアップ

```
git clone https://github.com/makotokw/GaranchuForiOS.git
cd GaranchuForiOS/Garanchu
cp Garanchu/GRCGaranchuConfig.sample.h Garanchu/GRCGaranchuConfig.h
bundle install --path=vendor/bundle
bundle exec pod install
open Garanchu.xcworkspace
```

``WZGaranchuConfig.h`` にデベロッパーIDを入れてください。


## ライセンス

Copyright (c) 2013 Makoto Kawasaki
GNU GENERAL PUBLIC LICENSE Version 3 (GPL v3)