#!/usr/bin/env ruby
require 'pp'

=begin
mt    = ARGV.join(' ')
files = Dir.glob('**/**', File::FNM_DOTMATCH)
mtre  = mt.each_char.to_a.map{|c| c==c.upcase ? Regexp.escape(c) : '['+Regexp.escape(c)+Regexp.escape(c.upcase)+']'}.join('.*')
cands = []
files.select{|f| f =~ /#{mtre}/}.each{|f| cands << {:matches => f, :file=>f,:kind=>:filename}}
tags  = `ctags -f - \
  --format=2 --excmd=number --sort=no \
  --extra=+fq \
  --fields=+afikKlmnSszt \
  --c-kinds=+cdefglmnpstuvx \
  --c++-kinds=+cdefglmnpstuvx \
  --file-scope=yes \
  -R .`
puts tags
exit
tags.split("\n").select{|t| t.split("\t")[0] =~ /#{mtre}/}.each do |t|
  t   = t.split("\t")
  res = {:matches => t.shift, :file=>t.shift, :ex => t.shift}
  t   = Hash[t.map{|v| v.split(':')}.map{|k,v2|[k.to_sym,v2]}]
  t.delete(:file)
  cands << t.merge(res)
end

pp cands
=end
#make -p -f
#grep -E -o '^[^[:space:].]+.[hc]:' | sed 's/:$//g' | sort -u
#files = `make -R -i -p -n --new-file=*`.scan /(?:(?:\s+|^)([^\s\$\(\)]+\.[hci])(?::|$|\s)|(^\s*PWD\s*=.+))/

#files = `make ; make -r -i -p -n -B 2>/dev/null`.scan /(^\/[^\s]*(?:g?cc|clang)\s+.*|^\s*PWD\s*=.+)/  # For include directories
mdb_cmd = 'make -r -i -p -n -B --new-file=* 2>/dev/null'
files = `#{mdb_cmd}`.scan(/^\/[^\s]*(?:g?cc|clang)\s+.*/) #.join("\n")

# 1. Get all main source files
# 2. Get all include directories (-I... lines)
# 3. Figure out all system dependencies ( ls (main-sources) | xargs -L 1 /usr/bin/cpp -I... -I... -E -M -MG )
#
# 4. Pull it all together and reduce to directories
# 5. Make a makefile that makes tag-files and cscope
  #
  #  ./.tags/src.ectags:  ./src/*.c ./src/*.h
  #  ^Ictags ... ./src/*.c ./src/*.h
  #
  #  ./.tags/cscope.files: ./src/*.c ./src/*.h ./.../*.c ...
  #  ^I(cmd to make list of files)
  #
  #  ./.tags/cscope.out:  ./.tags/cscope.files
  #  ^Icscope -i./.tags
  #
# 6. Pipe said makefile to `make -f -` (or as temp file etc.)

pp files

