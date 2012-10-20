#!/usr/bin/env ruby
require 'pp'
mt    = ARGV.join(' ')
files = Dir.glob('**/**', File::FNM_DOTMATCH)
mtre  = mt.each_char.to_a.map{|c| c==c.upcase ? Regexp.escape(c) : '['+Regexp.escape(c)+Regexp.escape(c.upcase)+']'}.join('.*')
cands = []
files.select{|f| f =~ /#{mtre}/}.each{|f| cands << {:matches => f, :file=>f,:kind=>:filename}}
tags  = `ctags -f - \
  --format=2 --excmd=mixed --sort=no \
  --fields=+mKnSsz \
  --c-kinds=+cdefglmnpstuvx \
  --c++-kinds=+cdefglmnpstuvx \
  -R .`
tags.split("\n").select{|t| t.split("\t")[0] =~ /#{mtre}/}.each do |t|
  t   = t.split("\t")
  res = {:matches => t.shift, :file=>t.shift, :ex => t.shift}
  t   = Hash[t.map{|v| v.split(':')}.map{|k,v2|[k.to_sym,v2]}]
  t.delete(:file)
  cands << t.merge(res)
end

pp cands
