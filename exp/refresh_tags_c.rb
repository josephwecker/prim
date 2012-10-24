#!/usr/bin/env ruby

# Given:
#   - current working-directory
#   - current buffer
#
# Prioritized refreshing / generating of ctag files
# 
#
# 1. Look for existing makefiles
# 
#

require 'pathname'
require 'pp'

class FNV1a
  I32 = 0x811c9dc5;    I64 = 0xcbf29ce484222325
  P32 = 0x01000193;    P64 = 0x100000001b3
  M32 = 2 ** 32   ;    M64 = 2 ** 64
  def self.h32(d) d.bytes.reduce(I32){|h,b|((h^b)*P32)%M32} end
  def self.h64(d) d.bytes.reduce(I64){|h,b|((h^b)*P64)%M64} end
end

class Pathname
  def dir()       self.directory? ? self : self.dirname end

  def [](pattern) Pathname.glob((self.dir + pattern.to_s).to_s, File::FNM_DOTMATCH) end

  def proj_root
    in_cvs = in_svn = in_rcs = false
    tentative = self.dir
    tentative.dup.ascend do |d|
      has_cvs = has_svn = has_rcs = false
      d.children.each do |c|
        case c.basename.to_s
        when '.hg'        then return d
        when '.git'       then return d
        when '.svn'       then in_svn = d; has_svn = true
        when 'CVS'        then in_cvs = d; has_cvs = true
        when 'RCS'        then in_rcs = d; has_rcs = true
        when /Makefile.*/ then tentative = d
        when 'Rakefile'   then tentative = d
        when 'configure'  then tentative = d
        when 'LICENSE'    then tentative = d
        end
      end
      return in_svn if in_svn && !has_svn
      return in_cvs if in_cvs && !has_cvs
      return in_rcs if in_rcs && !has_rcs
    end
    return tentative
  end

  def relation_to(other)
    other = Pathname.new(other) if other.is_a? String
    travp = other.expand_path.relative_path_from(self.expand_path).to_s
    if    travp =~ /^(..\/)+$/ then return :child
    elsif travp =~ /^..\//     then return :stranger
    else  return :parent end
  end
end

class Proj
  def initialize(cwd, cf)
    @p_cf  = nil
    @p_cwd = Pathname.new(cwd || Pathname.pwd).expand_path
    @p_cf  = Pathname.new(cf).expand_path  unless cf.nil?
  end

  def root_dir
    wd_root = @p_cwd.proj_root
    return wd_root if @p_cf.nil?
    cf_root = @p_cf.proj_root
    return @p_cwd  if wd_root.nil? && cf_root.nil?
    return cf_root if wd_root.nil?
    return wd_root if cf_root.nil?
    return wd_root if wd_root.to_s == cf_root.to_s
    return wd_root if wd_root.relation_to(cf_root) == :parent
    return cf_root
  end

  def makefiles() return @makefiles ||= root_dir['**/Makefile'] end

  def has_root_makefile?()
    makefiles.each{|mk| return true if mk.dir.to_s == root_dir.to_s}
    return false
  end

  def include_dirs(language=:c)
    @inc_dirs ||= {}
    return @inc_dirs[language] if @inc_dirs[language]
    return @inc_dirs[language] = self.send('inc_dirs_for_'+language.to_s)
  end

  private
  def inc_dirs_for_c
    res  = c_makefile_inc_dirs
    res += c_find_inc_dirs      if res.empty? || !has_root_makefile?
    res += c_system_inc_dirs    if res.empty?
    res  = res.select{|d| !d.nil? && d.to_s.strip.length>0 && d.to_s.strip != '/'}
    res.map!{|d| d.is_a?(Pathname) ? d : Pathname.new(d.to_s)}
    res.compact.map{|d| d.expand_path.dir}.sort.uniq
  end

  def c_makefile_inc_dirs
    return [] if makefiles.size == 0
    @mcmds ||= ''
    @mdb   ||= ''
    makefiles.each do |mk|
      mdb_res   = `make -r -i -p -n -B --new-file=* -C '#{mk.dir}' -f '#{mk}' 2>/dev/null`
      state     = :cmds
      mdb_res.split(/(?=(?:\n|^) *(?:# Make data base|# Finished Make data base).*?(?:\n|$))/mu).each do |part|
        if    part =~ /^\s*# Make data base/          then state = :makedb
        elsif part =~ /^\s*# Finished Make data base/ then state = :cmds   end
        (state == :makedb) ? @mdb+=part : @mcmds+= part
      end
    end
    @mkcares = @mdb.split(/(?=^\s*CURDIR\s*:?=.+)/).map do |m|
      root = m[/^\s*CURDIR\s*:?=\s*([^\s]+)/,1]
      m.scan(/(?:\s+|^)([^\s\$\(\)]+\.[hci])(?::|$|\s(?=[^=]*$))/).map{|f| f=f[0].strip; f[0..0]=='/' ? f : root+'/'+f}
    end
    @mkcares = @mkcares.flatten.map{|f| !f.nil? && f.size>0 ? Pathname.new(f).expand_path : nil}.compact.uniq
    buildinc = @mcmds.scan(/^(?!#)[^\s]*(?:g?cc|clang)\s+.*/).join("\n").scan(/\s-I([^\s]+)\s/).
                      flatten.map{|f| Pathname.new(f).expand_path.dir}
    includes = (@mkcares.map{|f|f.dir} + buildinc).uniq

    #cpp = `/bin/bash -c 'command -v cpp'`.strip
    cpp = 'gcc'
    if @mkcares.size > 0 && cpp.strip.size > 0
      inc = includes.map{|i| "-I'#{i}'"}.join(' ')
      cmd = "'#{cpp}' #{inc} -E -M -MG"
      @mkcares.each do |f|
        includes += `#{cmd} '#{f}' | sort -u`.scan(/^\s*([^\s]+?\.[ch])(?:\s|:|$)/)
      end
    end
    includes.flatten.uniq
  end

  def c_find_inc_dirs() root_dir['**/*.[chi]'].map{|f| f.dir} end

  def c_system_inc_dirs
    sys = []
    sys += `gcc -v 2>&1`.scan(/=([^\s]+lib[^\s]*)/)
    sys += `make -p -f/dev/null 2>&1`.scan(/^.*?inc.*$/i).map{|i| i.split('=').last.strip.split(/\s+/)}
    sys += ENV['CPATH'].split(':')          if ENV['CPATH']
    sys += ENV['C_INCLUDE_PATH'].split(':') if ENV['C_INCLUDE_PATH']
    sys += ENV['includedir'].split(/\s+/)   if ENV['includedir']
    sys.flatten.uniq.sort.map{|d| d.to_s.length==0 ? nil : (d = Pathname.new(d).expand_path; d.dir)}
  end
end

class RTags
  attr_reader :proj

  def self.flat_fname(path)
    path = Pathname.new(path) if path.is_a? String
    FNV1a::h64(path.cleanpath.to_s).to_s(36)
  end

  def initialize(cwd, cf)
    @proj = Proj.new(cwd, cf)
  end

  def refresh
    pp @proj.makefiles
  end
end

rt = RTags.new(Pathname.pwd, ARGV[0])
pp rt.proj.include_dirs
