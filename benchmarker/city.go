package main

import "math/rand"

var Cities = []string{
	"レイキャビク",
	"ダブリン",
	"バクー",
	"カブール",
	"ワシン卜ン",
	"アブダビ",
	"アルジェ",
	"ブエノスアイレス",
	"チラナ",
	"エレバン",
	"ルアンダ",
	"セントジョンズ",
	"アンドラ・ラ・べリャ",
	"サナア",
	"エルサレム",
	"ローマ",
	"バグダッド",
	"テヘラン",
	"ニューデリー",
	"ジャカルタ",
	"カンパラ",
	"キエフ",
	"タシケント",
	"モンテビデオ",
	"キト",
	"カイロ",
	"タリン",
	"アジスアべバ",
	"アスマラ",
	"サンサルバドル",
	"ウイーン",
	"キャンべラ",
	"マスカット",
	"アムステルダム",
	"プライア",
	"アクラ",
	"ジョージタウン",
	"アルマトゥイ",
	"ドーハ",
	"オタワ",
	"リーブルビル",
	"ヤウンデ",
	"バンジュール",
	"プノンぺン",
	"ビサオ",
	"コナクリ",
	"ニコシア",
	"ハバナ",
	"アテネ",
	"タラワ",
	"ビシュケク",
	"グアテマラシティ",
	"クウェート",
	"トビリシ",
	"ロンドン",
	"セントジョージズ",
	"ザグレブ",
	"ナイロビ",
	"ヤムスクロ",
	"サンホセ",
	"モロニ",
	"サンタフェデボゴタ",
	"キンシヤサ",
	"リヤド",
	"サントメ",
	"ルサカ",
	"サンマリノ",
	"フリータウン",
	"ジブチ",
	"キングストン",
	"ダマスカス",
	"シンガポール",
	"ハラーレ",
	"べルン",
	"ストックホルム",
	"ハルツーム",
	"マドリード",
	"パラマリボ",
	"スリジャヤワルダナプラコッテ",
	"ブラチスラバ",
	"リュブリャナ",
	"ムババネ",
	"ビクトリア",
	"マラボ",
	"ダカール",
	"バセテ一ル",
	"キングスタウン",
	"カストリーズ",
	"モガディシュ",
	"ホニアラ",
	"ソウル",
	"バンコク",
	"ドゥシャンべ",
	"ダルエスサラーム",
	"プラハ",
	"ンジャメナ",
	"ぺキン",
	"バンギ",
	"チュニス",
	"ピョンヤン",
	"サンチアゴ",
	"フナフチ",
	"コぺンハーゲン",
	"べルリン",
	"ロメ",
	"サントドミンゴ",
	"ロゾー",
	"ポートオブスペイン",
	"アシガバード",
	"アンカラ",
	"ヌクアロファ",
	"アブジャ",
	"ナウル",
	"ウイントフック",
	"マナグア",
	"ニアメ",
	"アピア",
	"東京",
	"ウェリントン",
	"カトマンズ",
	"オスロ",
	"マナーマ",
	"ポルトープランス",
	"イスラマバード",
	"バチカン",
	"パナマ",
	"ポートビラ",
	"ナッソー",
	"ポートモレスビー",
	"コロール",
	"アスンシオン",
	"ブリッジタウン",
	"ブダぺスト",
	"ダッカ",
	"テインプー",
	"スバ",
	"マニラ",
	"ヘルシンキ",
	"ブラジリア",
	"パリ",
	"ソフィア",
	"ワガドゥーグー",
	"バンダルスリブガワン",
	"ブジュンブラ",
	"ハノイ",
	"ポルトノボ",
	"カラカス",
	"ミンスク",
	"べルモパン",
	"リマ",
	"ブリュッセル",
	"ワルシャワ",
	"サラエボ",
	"ハボローネ",
	"ラパス",
	"リスボン",
	"主市ビクトリア",
	"テグシガルパ",
	"マジュロ",
	"スコピエ",
	"アンタナナリボ",
	"リロングウェ",
	"バマコ",
	"バレッタ",
	"クアラルンプール",
	"パリキール",
	"プレトリア",
	"ヤンゴン",
	"メキシコシティ",
	"ポートルイス",
	"ヌアクショット",
	"マプート",
	"モナコ",
	"マレ",
	"キシニョフ",
	"ラバト",
	"ウランバートル",
	"べオグラード",
	"アンマン",
	"ビエンチヤン",
	"リガ",
	"ビリニュス",
	"トリポリ",
	"ファドーツ",
	"モンロビア",
	"ブカレスト",
	"ルクセンブルク",
	"キガリ",
	"マセル",
	"べイルート",
	"モスクワ",
}

var CitiesCount int

func init() {
	CitiesCount = len(Cities)
}

func randomCity() string {
	idx := rand.Intn(CitiesCount)
	return Cities[idx]
}