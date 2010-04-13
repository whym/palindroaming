#! /usr/bin/env ruby
# -*- coding: utf-8; mode: ruby -*-


USAGE= <<'END'
  usage: palindroaming.rb --phone PHONE_MODEL --dictionary DICTIONARY --word WORD_MODEL
END
require 'optparse'

OPT = Struct.
  new(:verbose, :pmod,        :wmod,       :seed, :length).
  new(false,    'phone.pmod', 'word.wmod', 0,     5)
ORDER = 2

OptionParser.new do |opts|
  opts.on('--seed SEED', Integer) do |v|
    OPT.seed = v
  end
  opts.on('--phone STRING', String) do |v|
    OPT.pmod = v
  end
  opts.on('--word STRING', String) do |v|
    OPT.wmodelfile = v
  end
  opts.on('--dictionary STRING', String) do |v|
    OPT.dictionary = v
  end
  opts.on('--length N', Integer) do |v|
    OPT.length = v
  end
  opts.on('--verbose') do
    OPT.verbose = true
  end
end.parse!

class Hash
  def roulette
    sum = self.values.inject(&:+)
    r = rand(sum)
    self.each_pair do |k,v|
      sum -= v
      if sum <= r then
        return k
      end
    end
  end
  def degenerate
    n = {}
    self.each_pair do |k,v|
      n[k[0]] ||= {}
      n[k[0]][k[1..-1]] = v
    end
    return n
  end
  def select_hash(&block)
    h = {}
    self.each_pair do |k,v|
      if block.call(k,v) then
        h[k] = v
      end
    end
    h
  end
end

class Object
  def let(&block)
    yield self
  end
end

OPT.pmod = OPT.pmod.let do |slf|
  h = Hash.new{|h,k| h[k] = 0}
  sum = 0
  open(slf) do |io|
    io.each_line do |line|
      a = line.split(/\s+/)
      val = a.shift
      h[a] = val.to_i
      sum += h[a]
    end
  end
  h
end

uniphones = OPT.pmod.let do |slf|
  h = Hash.new{|h,k| h[k] = 0}
  slf.each_pair do |k,v|
    h[k[0]] += v
  end
  h
end.let do |slf|
  u = slf.clone
  slf[''] = u
end

# average with probability of reversed sequence
OPT.pmod = OPT.pmod.let do |slf|
  h = {}
  slf.each_pair do |k,v|
    krev = k.reverse
    if slf.has_key?(krev) then
      [k, krev].each do |seq|
        h[seq] ||= 1
        h[seq] *= v
      end
    end
  end
  h
end

if OPT.length % 2 == 1 then
  class Array
    def center_pair
      [self[self.length / 2]] * 2
    end
  end
else
  class Array
    def center_pair
      m = self.length / 2
      self[m,m+1]
    end
  end
end

degenerated = OPT.pmod.degenerate

srand(OPT.seed)

while true do
  cand = if OPT.length % 2 == 0 then
           OPT.pmod.select_hash{|k,_| k[0] == k[1]}.roulette
         else
           [uniphones.roulette]
         end
  while true do
    # STDERR.print cand[0]
    # STDERR.puts degenerated.values.inject(0){|s,x| s+=x.size}
    # STDERR.puts cand[0], degenerated[cand[0]]
    # STDERR.puts "#{degenerated[cand[0]].size}"
    nexts = degenerated[cand[0]]
    if nexts then
      r = nexts.roulette
      cand = r + cand + r
      if cand.length == OPT.length then
        puts cand.join(' ')
        break
      end
    else
      cand = cand[1..cand.length-2]
      if !cand then
        break
      end
    end
  end
end
