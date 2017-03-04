# SwiftActor
Actor Model Framework written in Swift

# Actor Model

## 基本概念
[アクターモデル - Wikipedia](https://ja.wikipedia.org/wiki/%E3%82%A2%E3%82%AF%E3%82%BF%E3%83%BC%E3%83%A2%E3%83%87%E3%83%AB)
> アクターモデルの基本は「全てのものはアクターである」という哲学である。これはオブジェクト指向プログラミングにおける「全てのものはオブジェクトである」という考え方と似ているが、オブジェクト指向ソフトウェアでは基本的に逐次的に実行するのに対して、アクターモデルでは本質的に並行性を備えている点が異なる。

## 機能
アクターは並行的に受信するメッセージに対応した次のようなふるまいを備えています。
また、そのふるまいも並列で実行されます

- メールボックスとアドレスを持ち、それぞれのアクターが互いに独立して並行にメッセージを処理する
    - 他のアクターに有限個のメッセージを送信する
    - 次に受信するメッセージに対する動作を指定する
- アクターはプロセス越しに通信する
- 有限個の新たなアクターを生成する
- アクターが子供のアクターを作り、それぞれにラウンドロビンでメッセージをブロードキャストしたりすることもできる

![ActorModel](http://blog.scottlogic.com/rdoyle/assets/ActorModel.png)

[Using Akka and Scala to Render a Mandelbrot Set](http://blog.scottlogic.com/2014/08/15/using-akka-and-scala-to-render-a-mandelbrot-set.html)

#### pros
- 並行プログラミングが簡単にできる
    - アクターがメッセージを一度に1つしか処理せず残りのメッセージをキューに追加して後から処理する => 競合状態やデッドロックを避けることができる
- スケーラブル
    - ボトルネックをどんどん小さなアクターに分けられる

同じリソースを見ると競合状態(レースコンディション)が起きて性能劣化が起きるので、  
リソースをコピーするトレードオフをとって、性能劣化せずに並行処理できるのがアクターモデルの利点。

#### cons
- アクター環境自体へのオーバーヘッドがある
    - 一旦キューに入れて処理する
    - リソースをコピーする

## See also
- [リアクティブシステムを実現するツールキットAkka | Think IT（シンクイット）](https://thinkit.co.jp/article/11477)
- [Preparing for distributed system failures using akka #ScalaMatsuri](https://www.slideshare.net/yugolf/preparing-for-distributed-system-failures-using-akka-scala-matsuri2017-72575226)
- [並行処理初心者のためのAkka入門](https://www.slideshare.net/sifue/akka-39611889)
