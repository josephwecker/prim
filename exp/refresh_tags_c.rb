#!/usr/bin/env ruby
#
# - More-or-less realtime (git branch change, save buffer, etc.)
#   - Updated tagfiles
#   - Updated cscope DBs (so that normal searches can always be done with -d)
#   - Updated dependency lists
# - All in the background, as efficiently as possible, and prioritized by
#   proximity to a given file.
#
# 

require 'pathname'
Path =   Pathname
class Nilish
  def self.global() $__N||= self.new end; def inspect;"nil(ish)"  end
  def blank?() true end;  def nil?() true end;  def empty?() true end
  def method_missing(m,*a,&b)
    case when nil.respond_to?(m)   then nil.send(m,*a,&b)
         when false.respond_to?(m) then false.send(m,*a,&b)
         when m.to_s[-1..-1]=='?'  then nil
    else self end
  end
end
class Object
  def blank?()   respond_to?(:empty?) ? empty? : !self            end
  def maybe()    self.nil? ? Nilish.global : self                 end
  def present?() !blank? end;     def presence() self if present? end
end
class String
  def fnv32() bytes.reduce(0x811c9dc5)        {|h,b|((h^b)*0x01000193)    % (1<<32)} end
  def fnv64() bytes.reduce(0xcbf29ce484222325){|h,b|((h^b)*0x100000001b3) % (1<<64)} end
  def method_missing(m,*a,&b) to_p.respond_to?(m) ? to_p.send(m,*a,&b) : super       end
  def blank?()                self !~ /[^[:space:]]/              end
  def to_p()                  Path.new(self)                      end
  def respond_to?(m,p=false)  super || to_p.respond_to?(m,p)      end
  def ===(p)                  r=super(p); r ? r : to_p===p        end
end
class NilClass; def blank?; true  end end; class FalseClass;  def blank?() true end  end 
class TrueClass;def blank?; false end end; class Hash;  alias_method :blank?,:empty? end
class Numeric;  def blank?; false end end; class Array; alias_method :blank?,:empty? end
module Enumerable
  def amap (m,*a,&b) self.map {|i| i.send(m,*a,&b)}               end
  def amap!(m,*a,&b) self.map!{|i| i.send(m,*a,&b)}               end
end
class Path
  def **  (p) self+p.to_p      end;  def r?  ()  readable_real?   end
  def w?  ()  writable_real?   end;  def x?  ()  executable_real? end
  def rw? ()  r? && w?         end;  def rwx?()  r? && w? && x?   end
  def to_p()  self             end;  def dir?()  directory?       end
  def perm?() exp.dir? ? rwx? : rw?                               end
  def exp ()  return @exp ||= self.expand_path                    end
  def real()  begin exp.realpath rescue exp end                   end
  def dir ()  exp.dir? ? exp : exp.dirname                        end
  def dir!()  (exp.mkdir unless exp.dir? rescue return nil); self end
  def ===(p)  real.to_s == p.real.to_s                            end
  def [](p)   Path.glob((dir + p.to_s).to_s, File::FNM_DOTMATCH)  end
  def relation_to(other)
    travp = other.exp.relative_path_from(exp).to_s
    if    travp =~ /^(..\/)+$/ then :child
    else  travp =~ /^..\// ? :stranger : :parent end
  end
end


$_.strip!
tdr="$P/subtags/#{$_.split("/")[0..-2].join("/")}"
"$P/subtags/#{$_}.tags : $(PROJECT)/#{$_} | #{tdr}}\n" .
"#{tdr} : ; mkdir -p #{tdr}"


class Proj
  def initialize(cwd, cf)
    @cached_lookups = {}
    @p_cf           = nil
    @p_cwd          = (cwd || Path.pwd).exp
    @p_cf           = cf.exp unless cf.blank?
  end

  def root_dir
    wd_root = root_dir_for(@p_cwd)
    return wd_root if @p_cf.blank?
    cf_root = root_dir_for(@p_cf)
    return @p_cwd  if wd_root.blank? && cf_root.blank?
    return cf_root if wd_root.blank?
    return wd_root if cf_root.blank?
    return wd_root if wd_root === cf_root
    return wd_root if wd_root.relation_to(cf_root) == :parent
    return cf_root
  end

  def [](pattern,refresh=false)
    @cached_lookups.delete(pattern) if refresh
    return @cached_lookups[pattern] ||= root_dir[pattern]
  end

  def makefiles()  self['**/Makefile'] end
  def sourcedirs() self['**/*.[chi]'].map{|f|f.split[0..-2].join}.uniq end
  def has_root_makefile?() !self['Makefile'].empty? end

  private
  def root_dir_for(path)
    in_cvs = in_svn = in_rcs = false
    tentative = path.dir
    tentative.ascend do |d|
      has_cvs = has_svn = has_rcs = false
      d['{.hg,.svn,CVS,RCS,[MR]akefile,configure,LICENSE}'].each do |c|
        case c.basename.to_s
        when '.hg'||'.git'           then return d
        when '.svn' then in_svn = d; has_svn = true
        when 'CVS'  then in_cvs = d; has_cvs = true
        when 'RCS'  then in_rcs = d; has_rcs = true
        when /[MR]akefile.*/         then tentative = d
        when 'configure'||'LICENSE'  then tentative = d
        end
      end
      return in_svn if in_svn && !has_svn
      return in_cvs if in_cvs && !has_cvs
      return in_rcs if in_rcs && !has_rcs
    end
    return tentative
  end
end

class RTags
  TAGDIR       = '.tags'
  GLOBALTAGDIR = '~/.prim/tags'
  def initialize(cwd=nil, cfile=nil, language=:c)
    @cwd   = cwd      || Path.pwd
    @cfile = cfile
    @lang  = language || :c
    @proj  = Proj.new(cwd, cfile)
  end
  def self.refresh(cwd=nil,cf=nil,lang=:c) new(cwd, cf, lang).do_refresh end
  #def do_refresh()    fork_refresh(@cfile.dir) if @cfile.maybe.dir.dir?  end
  #def fork_refresh(dir) Process.detach(fork{refresh_dir(dir)})           end
  def refresh_dir (dir) throw("Not yet implemented for #{@lang}")        end
end

class RTagsC < RTags

  def refresh_dir(path)
    #return unless path.maybe.dir?
    ##@srcdir = path
    #@tagdir = path ** TAGDIR
    #@tagdir = GLOBALTAGDIR unless @tagdir.maybe.perm?
    #throw "Couldn't find a good tagfile location for '#{path}'"         unless @tagdir.maybe.perm?
    #throw "Couldn't create tagfile location '#{@tagdir}' for '#{path}'" unless @tagdir.dir!.maybe.perm?
  end
end

if __FILE__ == $0
  proj  = Proj.new(ARGV[0], ARGV[1])
  p proj.has_root_makefile?

  #RTagsC.refresh ARGV[0], ARGV[1]
end


=begin
class RTags
  attr_reader :proj

  def self.flat_fname(path)
    path = Pathname.new(path) if path.is_a? String
    FNV1a::h64(path.cleanpath.to_s).to_s(36)
  end

  def initialize(cwd, cf)
    @proj = Proj.new(cwd, cf)
  end

  def include_dirs(language=:c)
    @inc_dirs ||= {}
    return @inc_dirs[language] if @inc_dirs[language]
    return @inc_dirs[language] = self.send('inc_dirs_for_'+language.to_s)
  end

  def refresh
    #pp @proj.makefiles
  end

  private
  def inc_dirs_for_c
    res  = c_makefile_inc_dirs
    res += c_find_inc_dirs      if res.empty? || !has_root_makefile?
    res += c_system_inc_dirs    if res.empty?
    res  = res.select{|d| !d.blank? && d.to_s.strip.length>0 && d.to_s.strip != '/'}
    res.map!{|d| d.to_p}
    res.compact.map{|d| d.exp.dir}.sort.uniq
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
      m.scan(/(?:\s+|^)([^\s\$\(\)]+\.[hci])(?::|$|\s(?=[^=]*$))/).map do |f|
        f=f[0].strip; f[0..0]=='/' ? f : root+'/'+f
      end
    end
    @mkcares = @mkcares.flatten.map{|f| f.present? ? f.exp : nil}.compact.uniq
    includes = @mcmds.scan(/^(?!#)[^\s]*(?:g?cc|clang)\s+.*/).join("\n")
    includes = includes.scan(/\s-I([^\s]+)\s/)
    includes = (includes + @mkcares).norm_paths.map{|f| f.dir}.uniq

    if @mkcares.size > 0
      inc = includes.map{|i| "-I'#{i}'"}.join(' ')
      cmd = "cpp #{inc} -E -M -MG"
      @mkcares.each do |f|
        more_cares = `#{cmd} '#{f}' 2>/dev/null | sort -u`.scan(/^\s*([^\s]+?\.[ch])(?:\s|:|$)/)
        includes  += more_cares.norm_paths.map{|f| f.dir}.uniq
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
    sys.flatten.uniq.sort.map{|d| d.to_s.length==0 ? nil : (d = Pathname.new(d).exp; d.dir)}
  end
end
rt = RTags.new(Pathname.pwd, ARGV[0])
pp rt.proj.include_dirs
=end
