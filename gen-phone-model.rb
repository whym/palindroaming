#! /usr/bin/env ruby
# -*- coding: utf-8; mode: ruby -*-

USAGE= <<'END'
  usage: gen-phone-model.rb TRAINING_FILE
END
require 'optparse'

OPT = Struct.
  new(:verbose, :order).
  new(false,    2)

OptionParser.new do |opts|
  opts.on('--order N', Integer) do |v|
    OPT.order = v
  end
  opts.on('--verbose') do
    OPT.verbose = true
  end
end.parse!

class String
  def each_phone_sequence(&block)
    line = self.chop
    ls = []
    while line.length > 0 do
      m = PHONES.match(line)
      if m then
        line = m.post_match
        ls << m[0]
      else
        yield ls  if ls.length > 0
        ls = []
        line = line[1..-1]
      end
    end
    yield ls  if ls.length > 0
  end
end

require 'open3'
PHONES = Regexp.new '^('+DATA.read.split(/\s+/).join('|')+')'

counts = Hash.new{|h,k| h[k] = 0} # TODO: use trie
ret = Open3.popen3("mecab -Oyomi") do |stdin, stdout, stderr|
  ARGF.each_with_index do |line,i|
    stdin.puts line
    stdin.flush if i % 100 == 0
  end
  stdin.flush
  stdin.close
  stdout.each_line do |line|
    line.each_phone_sequence do |seq|
      seq.each_cons(OPT.order) do |ngram|
        counts[ngram] += 1
      end
    end
  end
end

counts.keys.sort_by{|k| -counts[k]}.each do |k|
  puts ([counts[k]]+k).join("\t")
end

__END__
ヴュ
ツァ
ヴォ
ツィ
キャ
キュ
キョ
シャ
シュ
シェ
ショ
チャ
チュ
チェ
チョ
ツェ
ニャ
ニュ
ニョ
ヒャ
ヒュ
ヒョ
ミャ
ミュ
ミョ
リャ
リュ
リョ
ギャ
ギュ
ギョ
ビャ
ビュ
ビョ
ヂュ
ヂャ
ヂョ
ピャ
ピュ
ピョ
ヴァ
ヴィ
ヴェ
ウォ
ズィ
ジァ
ドゥ
ドュ
ドャ
ドョ
フョ
フュ
ティ
ファ
フィ
フェ
フォ
ジャ
ジュ
ジョ
ディ
デュ
ウェ
ウィ
トゥ
ジェ
レャ
イュ
ヴャ
クヮ
グュ
テュ
ブュ
シ
チ
ツ
ヲ
カ
キ
ク
ケ
コ
サ
ス
セ
ソ
タ
テ
ト
ナ
ニ
ヌ
ネ
ノ
ハ
ヒ
フ
ヘ
ホ
マ
ミ
ム
メ
モ
ヤ
ユ
ヨ
ラ
リ
ル
レ
グヮ
ヘ
ホ
マ
ミ
ム
メ
モ
ヤ
ユ
ヨ
ラ
リ
ル
レ
ッー
フ
ヘ
ホ
マ
ミ
ム
メ
モ
ヤ
ユ
ヨ
ラ
リ
ル
レ
ロ
ワ
ガ
ギ
グ
ゲ
ゴ
ザ
ジ
ズ
ゼ
ゾ
ダ
ヂ
ヅ
デ
ド
バ
ビ
ブ
ヴ
ベ
ボ
パ
ピ
プ
ペ
ポ
ン
ア
イ
ウ
エ
オ
ッ
ー
ァ
ィ
ゥ
ェ
ォ
ュ
ョ
ヲ
ヱ
ヰ
ヵ
ヶ
