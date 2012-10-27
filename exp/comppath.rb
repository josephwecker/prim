#!/usr/bin/env ruby

MAXNGRAM  = 2
$totalg   = 0
$res      = []
$perc_acc = 0
$rank     = 0
class Trie
  attr_accessor :root
  def initialize() @root = Hash.new end
  def <<(arr, fullword=false)
    node = @root
    arr[0..(fullword ? -1 : MAXNGRAM-1)].each do |v|
      node[v]     ||= Hash.new
      node[v][:i] ||= 0
      node[v][:i]  += 1
      $totalg      += 1
      node          = node[v]
    end
  end
end

def prgram(char,count)
  res        = "%5d | %10d | % 9.4f%% | % 9.4f%% | %s | [%s]\n"
  sz         = char.scan(/./um).size
  dispc      = "'#{char}'"+(' '*(12-sz))
  cval       = char.unpack('C*').map{|n|'0x'+n.to_s(16)}.join(',')
  $perc_acc += count
  $rank      += 1
  puts(res % [$rank, count, count.to_f / $totalg.to_f * 100.0, $perc_acc.to_f / $totalg.to_f * 100.0, dispc, cval])
end

def nthgram(node, prefix='')
  $res << [prefix, node[:i]] if node[:i]
  node.each{|value,val_node| nthgram(val_node, prefix+value) unless value==:i}
end

t = Trie.new
dircount = 0
ARGF.each_line do |dat|
  dircount += 1
  #break if dircount > 500000
  if (dircount % 2000) == 0
    $stderr.puts "#{dircount} - #{dat.strip}"
    $stderr.flush
  end
  full = dat.strip.split /\W+/
  dat  = dat.strip.scan(/./um)
  (0..dat.size-1).each{|i|t<<dat[i..-1]}
  full.each{|f| t.<<(f,true)}
end

$stderr.puts "Processing ngrams"
nthgram(t.root)
$stderr.puts "Sorting and emitting ngrams"
$res.sort_by{|c,v| -v}.each{|c,v| prgram(c,v)}
$stderr.puts "Done"
