#!/usr/bin/env ruby

class ExpGolomb
  def initialize(k) @k=k end
  def enc(n)
    inv   = n.to_s(2)
    inv   = '0'*(@k-inv.size)+inv if inv.size < @k
    #ktail, inv = [inv[[-1,-@k].min..-1], inv[0..-@k-1]]
    inv = (eval('0b0'+inv) + 1).to_s(2)
    inv = '' if inv==0
    [inv,ktail,
    '0'*(inv.size - 1)+inv+ktail]

    #p [n.to_s(2), @k, inv, ktail]
  end
end

e = ExpGolomb.new(0)
(0..50).each{|i| p e.enc(i)}
