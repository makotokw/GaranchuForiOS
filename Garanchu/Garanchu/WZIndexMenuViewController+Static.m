//
//  WZIndexMenuViewController+Static.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZIndexMenuViewController+Static.h"

@implementation WZIndexMenuViewController (Static)

- (NSMutableArray *)rootItems
{
    return [@[
            @{@"title": @"インデックス", @"items": @[
            @{@"title": @"録画番組", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType]},
            @{@"title": @"放送中の番組", @"indexType": [NSNumber numberWithInteger:WZRecordingProgramGaranchuIndexType], @"params":[self recordingProgramParams]},
//            @{@"title": @"日付一覧", @"indexType": [NSNumber numberWithInteger:WZDateGaranchuIndexType]},
            @{@"title": @"ジャンル", @"indexType": [NSNumber numberWithInteger:WZGenreGaranchuIndexType]},
            @{@"title": @"放送局", @"indexType": [NSNumber numberWithInteger:WZChannelGaranchuIndexType]},
            @{@"title": @"お気に入り", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"rank": @"all"}},
            ]
            }
            ] mutableCopy];
}

- (NSDictionary *)recordingProgramParams
{
    NSTimeInterval sdate = [[NSDate date] timeIntervalSince1970];    
    NSTimeInterval edate = sdate + 600;
    return @{
             @"s": @"e",
             @"dt": @"e",
             @"sort": @"sta",
             @"sdate": [WZGaraponTv formatDateTime:sdate],
             @"sdate": [WZGaraponTv formatDateTime:edate],
             @"video": @"all",
             };
}

- (NSMutableArray *)genreItems
{
    return [@[
            @{@"title": @"ニュース/報道", @"items": @[
            @{@"title": @"ニュース/報道 全て", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"0"} },
            @{@"title": @"定時・総合", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"0", @"genre1" :@"0"} },
            @{@"title": @"天気", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"0", @"genre1" :@"1"} },
            @{@"title": @"特集・ドキュメント", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"0", @"genre1" :@"2"} },
            @{@"title": @"政治・国会", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"0", @"genre1" :@"3"} },
            @{@"title": @"経済・市況", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"0", @"genre1" :@"4"} },
            @{@"title": @"海外・国際", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"0", @"genre1" :@"5"} },
            @{@"title": @"解説", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"0", @"genre1" :@"6"} },
            @{@"title": @"討論・会談", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"0", @"genre1" :@"7"} },
            @{@"title": @"報道特番", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"0", @"genre1" :@"8"} },
            @{@"title": @"ローカル・地域", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"0", @"genre1" :@"9"} },
            @{@"title": @"交通", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"0", @"genre1" :@"10"} },
            @{@"title": @"その他", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"0", @"genre1" :@"15"} },
            ]},
            @{@"title": @"スポーツ", @"items": @[
            @{@"title": @"スポーツ 全て", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"1"} },
            @{@"title": @"スポーツニュース", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"1", @"genre1" :@"0"} },
            @{@"title": @"野球", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"1", @"genre1" :@"1"} },
            @{@"title": @"サッカー", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"1", @"genre1" :@"2"} },
            @{@"title": @"ゴルフ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"1", @"genre1" :@"3"} },
            @{@"title": @"その他の球技", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"1", @"genre1" :@"4"} },
            @{@"title": @"相撲・格闘技", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"1", @"genre1" :@"5"} },
            @{@"title": @"オリンピック・国際大会", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"1", @"genre1" :@"6"} },
            @{@"title": @"マラソン・陸上・水泳", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"1", @"genre1" :@"7"} },
            @{@"title": @"モータースポーツ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"1", @"genre1" :@"8"} },
            @{@"title": @"マリン・ウィンタースポーツ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"1", @"genre1" :@"9"} },
            @{@"title": @"競馬・公営競技", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"1", @"genre1" :@"10"} },
            @{@"title": @"その他", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"1", @"genre1" :@"15"} },
            ]},
            @{@"title": @"情報/ワイドショー", @"items": @[
            @{@"title": @"情報/ワイドショー 全て", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"2"} },
            @{@"title": @"芸能・ワイドショー", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"2", @"genre1" :@"0"} },
            @{@"title": @"ファッション", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"2", @"genre1" :@"1"} },
            @{@"title": @"暮らし・住まい", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"2", @"genre1" :@"2"} },
            @{@"title": @"健康・医療", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"2", @"genre1" :@"3"} },
            @{@"title": @"ショッピング・通販", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"2", @"genre1" :@"4"} },
            @{@"title": @"グルメ・料理", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"2", @"genre1" :@"5"} },
            @{@"title": @"イベント", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"2", @"genre1" :@"6"} },
            @{@"title": @"番組紹介・お知らせ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"2", @"genre1" :@"7"} },
            @{@"title": @"その他", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"2", @"genre1" :@"15"} },
            ]},
            @{@"title": @"ドラマ", @"items": @[
            @{@"title": @"ドラマ 全て", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"3"} },
            @{@"title": @"国内ドラマ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"3", @"genre1" :@"0"} },
            @{@"title": @"海外ドラマ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"3", @"genre1" :@"1"} },
            @{@"title": @"時代劇", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"3", @"genre1" :@"2"} },
            @{@"title": @"その他", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"3", @"genre1" :@"15"} },
            ]},
            @{@"title": @"音楽", @"items": @[
            @{@"title": @"音楽 全て", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"4"} },
            @{@"title": @"国内ロック・ポップス", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"4", @"genre1" :@"0"} },
            @{@"title": @"海外ロック・ポップス", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"4", @"genre1" :@"1"} },
            @{@"title": @"クラシック・オペラ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"4", @"genre1" :@"2"} },
            @{@"title": @"ジャズ・フュージョン", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"4", @"genre1" :@"3"} },
            @{@"title": @"歌謡曲・演歌", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"4", @"genre1" :@"4"} },
            @{@"title": @"ライブ・コンサート", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"4", @"genre1" :@"5"} },
            @{@"title": @"ランキング・リクエスト", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"4", @"genre1" :@"6"} },
            @{@"title": @"カラオケ・のど自慢", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"4", @"genre1" :@"7"} },
            @{@"title": @"民謡・邦楽", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"4", @"genre1" :@"8"} },
            @{@"title": @"童謡・キッズ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"4", @"genre1" :@"9"} },
            @{@"title": @"民族音楽・ワールドミュージック", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"4", @"genre1" :@"10"} },
            @{@"title": @"その他", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"4", @"genre1" :@"15"} },
            ]},
            @{@"title": @"バラエティ", @"items": @[
            @{@"title": @"バラエティ 全て", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"5"} },
            @{@"title": @"クイズ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"5", @"genre1" :@"0"} },
            @{@"title": @"ゲーム", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"5", @"genre1" :@"1"} },
            @{@"title": @"トークバラエティ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"5", @"genre1" :@"2"} },
            @{@"title": @"お笑い・コメディ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"5", @"genre1" :@"3"} },
            @{@"title": @"音楽バラエティ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"5", @"genre1" :@"4"} },
            @{@"title": @"旅バラエティ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"5", @"genre1" :@"5"} },
            @{@"title": @"料理バラエティ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"5", @"genre1" :@"6"} },
            @{@"title": @"その他", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"5", @"genre1" :@"15"} },
            ]},
            @{@"title": @"映画", @"items": @[
            @{@"title": @"映画 全て", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"6"} },
            @{@"title": @"洋画", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"6", @"genre1" :@"0"} },
            @{@"title": @"邦画", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"6", @"genre1" :@"1"} },
            @{@"title": @"アニメ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"6", @"genre1" :@"2"} },
            @{@"title": @"その他", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"6", @"genre1" :@"15"} },
            ]},
            @{@"title": @"アニメ/特撮", @"items": @[
            @{@"title": @"アニメ/特撮 全て", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"7"} },
            @{@"title": @"国内アニメ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"7", @"genre1" :@"0"} },
            @{@"title": @"海外アニメ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"7", @"genre1" :@"1"} },
            @{@"title": @"特撮", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"7", @"genre1" :@"2"} },
            @{@"title": @"その他", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"7", @"genre1" :@"15"} },
            ]},
            @{@"title": @"ドキュメンタリー/教養", @"items": @[
            @{@"title": @"ドキュメンタリー/教養 全て", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"8"} },
            @{@"title": @"社会・時事", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"8", @"genre1" :@"0"} },
            @{@"title": @"歴史・紀行", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"8", @"genre1" :@"1"} },
            @{@"title": @"自然・動物・環境", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"8", @"genre1" :@"2"} },
            @{@"title": @"宇宙・科学・医学", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"8", @"genre1" :@"3"} },
            @{@"title": @"カルチャー・伝統文化", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"8", @"genre1" :@"4"} },
            @{@"title": @"文学・文芸", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"8", @"genre1" :@"5"} },
            @{@"title": @"スポーツ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"8", @"genre1" :@"6"} },
            @{@"title": @"ドキュメンタリー全般", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"8", @"genre1" :@"7"} },
            @{@"title": @"インタビュー・討論", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"8", @"genre1" :@"8"} },
            @{@"title": @"その他", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"8", @"genre1" :@"15"} },
            ]},
            @{@"title": @"劇場/公演", @"items": @[
            @{@"title": @"劇場/公演 全て", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"9"} },
            @{@"title": @"現代劇・新劇", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"9", @"genre1" :@"0"} },
            @{@"title": @"ミュージカル", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"9", @"genre1" :@"1"} },
            @{@"title": @"ダンス・バレエ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"9", @"genre1" :@"2"} },
            @{@"title": @"落語・演芸", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"9", @"genre1" :@"3"} },
            @{@"title": @"歌舞伎・古典", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"9", @"genre1" :@"4"} },
            @{@"title": @"その他", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"9", @"genre1" :@"15"} },
            ]},
            @{@"title": @"趣味/教育", @"items": @[
            @{@"title": @"趣味/教育 全て", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"10"} },
            @{@"title": @"旅・釣り・アウトドア", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"10", @"genre1" :@"0"} },
            @{@"title": @"園芸・ペット・手芸", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"10", @"genre1" :@"1"} },
            @{@"title": @"音楽・美術・工芸", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"10", @"genre1" :@"2"} },
            @{@"title": @"囲碁・将棋", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"10", @"genre1" :@"3"} },
            @{@"title": @"麻雀・パチンコ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"10", @"genre1" :@"4"} },
            @{@"title": @"車・オートバイ", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"10", @"genre1" :@"5"} },
            @{@"title": @"コンピュータ・TVゲーム", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"10", @"genre1" :@"6"} },
            @{@"title": @"会話・語学", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"10", @"genre1" :@"7"} },
            @{@"title": @"幼児・小学生", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"10", @"genre1" :@"8"} },
            @{@"title": @"中学生・高校生", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"10", @"genre1" :@"9"} },
            @{@"title": @"大学生・受験", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"10", @"genre1" :@"10"} },
            @{@"title": @"生涯教育・資格", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"10", @"genre1" :@"11"} },
            @{@"title": @"教育問題", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"10", @"genre1" :@"12"} },
            @{@"title": @"その他", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"10", @"genre1" :@"15"} },
            ]},
            @{@"title": @"福祉", @"items": @[
            @{@"title": @"福祉 全て", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"11"} },
            @{@"title": @"高齢者", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"11", @"genre1" :@"0"} },
            @{@"title": @"障害者", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"11", @"genre1" :@"1"} },
            @{@"title": @"社会福祉", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"11", @"genre1" :@"2"} },
            @{@"title": @"ボランティア", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"11", @"genre1" :@"3"} },
            @{@"title": @"手話", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"11", @"genre1" :@"4"} },
            @{@"title": @"文字(字幕)", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"11", @"genre1" :@"5"} },
            @{@"title": @"音声解説", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"11", @"genre1" :@"6"} },
            @{@"title": @"その他", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"11", @"genre1" :@"15"} },
            ]},
            @{@"title": @"その他", @"items": @[
            @{@"title": @"その他 全て", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"15"} },
            @{@"title": @"その他", @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType], @"params": @{@"genre0": @"15", @"genre1" :@"15"} },
            ]},            ] mutableCopy];
}

@end
