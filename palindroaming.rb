#! /usr/bin/env ruby
# -*- coding: utf-8; mode: ruby -*-


USAGE= <<'END'
  usage: palindroaming.rb --phone PHONE_MODEL --dictionary DICTIONARY --word WORD_MODEL
END
require 'optparse'

OPT = Struct.
  new(:verbose, :pmod,        :wmod,       :seed, :length, :order).
  new(false,    'phone.pmod', 'word.wmod', 0,     5,       2)

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
  opts.on('--order N', Integer) do |v|
    OPT.order = v
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
  def degenerate(len)
    n = {}
    self.each_pair do |k,v|
      n[k[0,len]] ||= {}
      n[k[0,len]][k[len..-1]] = v
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
      h[a[0..OPT.order]] = val.to_i
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

degenerateds = (0..OPT.order-1).map do |i|
  OPT.pmod.degenerate(OPT.order - i)
end

# degenerateds.each_with_index do |d,i|
#   print i.to_s + ' '
#   puts '   ' + d.keys.map{|x| x.join}.sort.join(' ')
# end

srand(OPT.seed)

while true do

  cand = []
  while true
    # generate the core (length == 1 or 2)
    cand = if OPT.length % 2 == 0 then
             OPT.pmod.select_hash{|k,_| k[0] == k[1]}.roulette
           else
             [uniphones.roulette]
           end
    # append to the core (length / 2 >= order - 1)
    x = degenerateds[OPT.order-1][[cand[0]]]
    if x then
      x = x.roulette[0..OPT.order-1]
      cand = x.reverse + cand + x
      break
    end
  end
  
  # keep appending to the core
  while true do
    nexts = degenerateds[1][cand[0,OPT.order-1].reverse]
    p [cand[0,OPT.order-1].reverse, nexts] if OPT.verbose
    if nexts then
      r = nexts.roulette
      cand = r.reverse + cand + r
      if cand.length >= OPT.length then
        d = (cand.length - OPT.length) / 2
        cand = cand[d..cand.length-d-1]
        puts cand.join(' ')
        break
      end
    else
      cand = cand[OPT.order-1..cand.length-1-OPT.order-1]
      if !cand or cand.length == 0 then
        break
      end
    end
  end
end
