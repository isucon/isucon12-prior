# ISUCON 12 Prior Manual

[レギュレーション](./REGULATION.md)もあわせて読んでください。

## サーバー構成について

想定環境は以下の通りですが、開始後にハードウェアスペックを変更しないならばどのような環境でも構いません。

|OS          |CPU |MEM|HDD |
|------------|----|---|----|
|Ubuntu 20.04|1コア|4GB|40GB|

### 注意

#### 複数台構成にする場合

3台での複数台構成にしてのチャレンジをする場合、初期状態は全台同じものにして開始してください。

#### CPU やメモリを想定初期状態から拡張する場合

どちらも拡張すると問題解決に際して取れる手段が増加するため、あまり増設しすぎない方がよいです。

#### AWS 上で環境を再現する場合

c5.large が最も想定環境に近いので、 c5.large での起動を推奨します。

## 作業開始

各参加者は開催者から配布された IP アドレスあるいはドメインを控えておいてください。

### SSH でのマシンへのログイン

各参加者は `isucon` ユーザーとして鍵認証で SSH ログインが可能なように設定されています。

以下のようなコマンドで SSH ログインをしてください。

```
$ ssh isucon@<YOUR INSTANCE IP>
```

ログイン後、パスワードなしで `sudo` 可能なように設定されています。

※ 競技中の開催者メンテナンス用に `isuadmin` というユーザーが設定されています。このユーザーを削除したりした場合、開催者のサポートが受けられなくなりますので、ご注意ください。

### 負荷走行

ベンチマーカーは `/home/isucon/bin/benchmarker` に配置されています。`PATH` も事前に通してあるので、ログイン後

```
$ benchmarker
```

とすることでベンチマークを実行できます。

ベンチマーカーにはいくつかオプションがあります。

```
$ benchmarker --help
Usage of benchmarker:
  -admin
    	administrator mode
      # 管理者モードで実行します。スコアの内訳が表示されるようになります。
  -exit-status
    	set exit status non-zero when a benchmark result is failing
      # ベンチマーク終了時、 FAIL ならば終了コードが 1 になります。
  -no-load
    	exit on finished prepare
      # ベンチマークを実行せず、 initialize のみを実行します。
  -parallelism int
    	parallelism count (default 20)
      # 並列数を調整します。並列数によってスコアが変動するため、開催者が変更を禁じた場合は変更しないでください。
  -progress
    	show score in progress
      # ベンチマーク実行中の途中経過スコアも表示します。
  -target string
    	ex: 127.0.0.1:9292 (default "")
      # ベンチマークのターゲットホストを設定します。未指定の場合は空白で、空白の場合は localhost がセットされます。
      # BENCHMARKER_TARGET_HOST 環境変数がセットされている場合、その値がデフォルトになります。
  -tls
    	use tls
      # リクエストを TLS で送信するかのフラグです。有効化すると HTTP/2 での通信になる場合があります。
      # BENCHMARKER_USE_TLS 環境変数が1にセットされている場合、デフォルトで ON です。
  -version
    	show version and exit 1
      # ベンチマーカーのバージョンを表示します。
```

### 参考実装の切替方法

デフォルトでは Ruby の実装が起動しています。

`/home/isucon/webapp/tools/switch-lang` で利用する実装を切り替えることが出来ます。

```
# golang 参考実装へ切り替え。
$ /home/isucon/webapp/tools/switch-lang golang
```

### データベースのリカバリ

DB を初期状態へ戻すには `/home/isucon/webapp/tools/initdb` を利用します。

```
# DB を初期状態へ戻す
$ /home/isucon/webapp/tools/initdb
```

## ISUCON 12 Prior アプリケーションについて

以降、アプリケーション名を I12P と表記します。

### ストーリー

世界的 Webinar ブームにより、世界各地で Webinar が行われるようになりました。世界各地で開催されるスケジュールの応募人数制限を守りつつ、Webinar への参加申込を正しく処理しましょう。

- とある日から世界各地で Webinar が開催されます。
- 受け付けられる参加申込上限は、各 Webinar ごとに設定されています。
- 管理者は Webinar の申し込みが埋まってくると、新たな Webinar の予定を設定します。
- ユーザーは1度の Webinar 参加では満足せず、複数回参加しようとします。

### ルール詳細

指定された競技用サーバーインスタンス上のアプリケーションのチューニングを行い、それに対するベンチマーク走行のスコアで競技を行います。 利用が認められた競技用サーバーのみでアプリケーションの動作が可能であれば、どのような変更を加えても構いません。

ベンチマーカーとブラウザの挙動に差異がある場合、ベンチマーカーの挙動を正とします。

また、初期実装は言語毎に若干の挙動の違いはありますが、ベンチマーカーに影響のない挙動に関しては仕様とします。

#### スケジュールの一覧について

I12P はトップページにて予約を受け付けているスケジュールを一覧で表示します。

API は予約を受け付けているスケジュールの一覧をレスポンスしてください。ただし、管理者が全スケジュールの一覧を要求した時は、予約が埋まっていてもすべてのスケジュールを返してください。

#### 個別スケジュール画面について

各スケジュールの画面には予約しているユーザーのニックネームを一覧で表示します。

この際、管理者が同画面を閲覧した時のみ、ユーザーのメールアドレスもともにレスポンスしてください。ただし、ユーザーがアクセスした際にメールアドレスが表示された場合、情報漏えいが発生したとみなしクリティカルなエラーとして扱われます。

## ベンチマーク

### 負荷走行の流れ

1. `POST /initialize` が実行されます
2. 60秒間、負荷走行が実行されます
3. 負荷走行後の検証走行(数秒〜数十秒)が実行されます

各ステップにてエラーが発生した場合、ベンチマーカーは即座にエラーを報告しますが、クリティカルエラーでない場合は停止しません。

すべてのリクエストは10秒でタイムアウトし、10秒を超える、または60秒間の負荷走行終了時にタイムアウトとしてカウントされます。

### スコアの計算

加点項目は以下の通りです。

- ログインが正常な挙動を示す(1リクエスト毎) : 1点
- 新たなスケジュールが1件作成される : 10点
- 新たな予約が1件作成される : 1点

減点項目は以下の通りです。

- 減点対象とされるエラー : 1件につき1点
- タイムアウトエラー : 10件につき1点
- 検証走行中の減点対象エラー : 1件につき50点

加点をすべて合計し、減点の合計を減じたものが最終的なスコアとなります。

### 制約事項

以下の項目に抵触した場合、Fail となります。

- スコアの合計が0点あるいはそれを下回った場合
- クリティカルなエラーが1件でも発生した場合
- 初期化処理(`POST /initialize`)でなんらかのエラーが発生した場合

また、開催者による追試がある場合は以下の項目も厳守してください。

- サーバー再起動後もデータが永続化されていること
  - この際、複数台構成ではサーバーの起動順序は保証されません
  - 再起動手順は以下の通りです
    1. `isuadmin` ユーザーによる開催者のログイン
    2. `sudo shutdown -r now` がすべてのサーバーで順次実行されます
    3. 再起動を待ち、すべてのサーバーに ssh ログインが可能になるまで待ちます
    4. ssh ログインの確認後、10秒間の待機した後、画面確認が行われます

各エンドポイントの URI の変更は認められませんが、以下の点については明確に許可されます。

- ID 発行形式の変更

## その他

不明点は開催者に問い合わせてください。