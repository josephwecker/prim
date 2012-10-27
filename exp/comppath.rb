#!/usr/bin/env ruby

class BitString
  def initialize; @buf = '' end
  def <<(v)
    case v
    when BitString; @buf += v.to_s
    when String;    @buf += v
    when Integer;   @buf += v.to_s(2)
    when true;      @buf += '1'
    when false;     @buf += '0'
    end
  end
  def to_s; @buf end
  #def bits; @buf.

end


def crunch(ascii)
  bitstring = ascii.bytes.collect {|b| "%07b" % b}.join
  [bitstring].pack("B*")
end
 
def expand(binary)
  bitstring = binary.unpack("B*")[0]
  bitstring.scan(/[01]{7}/).collect {|b| b.to_i(2).chr}.join
end

MAXNGRAM  = 2
$totalsz  = 0
$totalg   = 0
$res      = []
$count_acc = 0
$rank     = 0
$bytesz_acc = 0
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
  sz         = char.scan(/./um).size
  dispc      = "'#{char}'"+(' '*([24-sz,0].max))
  $count_acc += count
  $rank     += 1
  cval       = char.unpack('C*')
  #bytesz     = cval.size * count.to_f
  #$bytesz_acc+= bytesz
  #perc_cont   = bytesz.to_f / $totalsz.to_f * 100.0
  #perc_cont_a = $bytesz_acc.to_f / $totalsz.to_f * 100.0
  #$aperc_cont+= perc_cont
  cval       = cval.map{|n|'0x'+n.to_s(16)}.join(',')
  res        = "%5d | %10d | % 9.4f%% | % 9.4f%% | %s | [%s]\n"
  puts(res % [$rank, count, count.to_f / $totalg.to_f * 100.0, $count_acc.to_f / $totalg.to_f * 100.0, dispc, cval])
  #res        = "%5d | %10d | % 9.4f%% | % 9.4f%% | %s | [%s]\n"
  #puts(res % [$rank, count, perc_cont, perc_cont_a, dispc, cval])
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
  $totalsz += dat.strip.bytes.to_a.size
  dat  = dat.strip.scan  /./um
  (0..dat.size-1).each{|i|t<<dat[i..-1]}
  full.each{|f| t.<<(f,true)}
end

$stderr.puts "Processing ngrams"
nthgram(t.root)
$stderr.puts "Sorting and emitting ngrams"
$res.sort_by{|c,v| -(v * c.unpack('C*').size)}.each{|c,v| prgram(c,v)}
$stderr.puts "Done"
