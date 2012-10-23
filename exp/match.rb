#!/usr/bin/env ruby
#
# For each kind of project/language
#
# - project-init:
#   - find root project directory, etc.
#   - update tags (and, if applicable, cscope)
#
# - for c:
#   - gather all applicable directories
#     - makefile based if possible
#     - quick scan of current / children directories and/or from project root
#   - determine directories that will allow for ./.tags vs ones without
#     write-access that will need to be put in a global location.
#   - makefile for tag files for each directory
#   - ctags-location-list for &tags in vim
#
#   - 
#
#
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


mdb_make  = 'make -r -i -p -n -B --new-file=* 2>/dev/null'
mdb_res   = `#{mdb_make}`
mcmds     = ''
mdb       = ''
state     = :cmds
mdb_res.split(/(?=(?:\n|^) *(?:# Make data base|# Finished Make data base).*?(?:\n|$))/mu).each do |part|
  #next if part ~= /^\s*$/m
  if    part =~ /^\s*# Make data base/          then state = :makedb
  elsif part =~ /^\s*# Finished Make data base/ then state = :cmds   end

  (state == :makedb) ? mdb+=part : mcmds+= part
  #if    state == :makedb                        then mdb   += part
  #else                                               mcmds += part   end
end


# DEBUG
if ARGV[0] == '-r'
  puts mdb
  print "\n"*4 + "="*80 + "\n"*4
  puts mcmds
  exit
end

files    = mdb.split(/(?=^\s*CURDIR\s*:?=.+)/).map { |m|
  root = m[/^\s*CURDIR\s*:?=\s*([^\s]+)/,1]
  m.scan(/(?:\s+|^)([^\s\$\(\)]+\.[hci])(?::|$|\s(?=[^=]*$))/).map{|f| f=f[0].strip; f[0..0]=='/' ? f : root+'/'+f}
}.flatten.uniq
includes = mcmds.scan(/^(?!#)[^\s]*(?:g?cc|clang)\s+.*/).join("\n").scan(/\s-I([^\s]+)\s/).uniq

pp includes
pp files

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


