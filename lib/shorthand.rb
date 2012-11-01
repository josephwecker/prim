require 'pathname'
require 'pp'
class Nilish
  def self.global()$__N||= self.new end
  def inspect()    "nil(ish)"       end
  def blank?()     true             end
  def nil?()       true             end
  def empty?()     true             end
  def method_missing(m,*a,&b)
    case
    when nil.respond_to?(m)   then nil.send(m,*a,&b)
    when false.respond_to?(m) then false.send(m,*a,&b)
    when m.to_s[-1..-1]=='?'  then nil
    else self end
  end
end

class Object
  def blank?()     respond_to?(:empty?) ? empty? : !self end
  def maybe()      self.nil? ? Nilish.global : self      end
  def present?()   !blank?                               end
  def presence()   self if present?                      end
end

class NilClass;    def blank?() true  end       end
class FalseClass;  def blank?() true  end       end 
class TrueClass;   def blank?() false end       end
class Numeric;     def blank?() false end       end
class Hash;        alias_method :blank?,:empty? end
class Array;       alias_method :blank?,:empty? end

module Enumerable
  def amap(m,*a,&b) self.map {|i|i.send(m,*a,&b)} end
  def amap!(m,*a,&b)self.map!{|i|i.send(m,*a,&b)} end
end

unless defined?(Path)
  Path = Pathname
  class Pathname
    alias old_init initialize
    def initialize(*args) old_init(*args); @rc={}; @rc2={} end
    def to_p()  self             end
    def **  (p) self+p.to_p      end
    def r?  ()  readable_real?   end
    def w?  ()  writable_real?   end
    def x?  ()  executable_real? end
    def rw? ()  r? && w?         end
    def rwx?()  r? && w? && x?   end
    def dir?()  directory?       end
    def ===(p)  real == p.real   end
    def perm?() exp.dir? ? rwx? : rw?               end
    def exp ()  return @exp ||= self.expand_path    end
    def real()  begin exp.realpath rescue exp end   end
    def dir()   exp.dir? ? exp : exp.dirname        end
    def dir!()  (exp.mkdir unless exp.dir? rescue return nil); self end
    def [](p)   Path.glob((dir + p.to_s).to_s, File::FNM_DOTMATCH)  end
    def rel(p=nil,home=true)
      p ||= Path.pwd
      return @rc2[p.to_s] if @rc2[p.to_s]
      sr  = real; pr  = p.real
      se  = exp;  pe  = p.exp
      candidates  = [sr.rel_path_from(pr), sr.rel_path_from(pe),
        se.rel_path_from(pr), se.rel_path_from(pe)]
      candidates += [sr.sub(ENV['HOME'],'~'), se.sub(ENV['HOME'],'~')] if home
      @rc2[p.to_s] = candidates.sort_by{|v|v.to_s.size}[0]
    end
    def rel_path_from(p) @rc ||= {}; @rc[p.to_s] ||= relative_path_from(p) end
    def relation_to(p)
      travp = p.rel(self,false).to_s
      if    travp =~ /^(..\/)+..(\/|$)/ then :child
      else  travp =~ /^..\// ? :stranger : :parent end
    end
    alias old_mm method_missing
    def method_missing(m,*a,&b) to_s.respond_to?(m) ? to_s.send(m,*a,&b) : old_mm(m,*a,&b) end
  end

  class String
    def fnv32() bytes.reduce(0x811c9dc5)        {|h,b|((h^b)*0x01000193)    % (1<<32)} end
    def fnv64() bytes.reduce(0xcbf29ce484222325){|h,b|((h^b)*0x100000001b3) % (1<<64)} end
    alias old_mm method_missing
    def method_missing(m,*a,&b) to_p.respond_to?(m) ? to_p.send(m,*a,&b) : old_mm(m,*a,&b) end
    def blank?() self !~ /[^[:space:]]/      end
    def to_p()   Path.new(self) end
    def respond_to_missing?(m,p=false) to_p.respond_to?(m,p) end
    alias old_eq3 ===
    def ===(p)   r=old_eq3(p); r ? r : to_p===p   end
    def to_sh()  blank? ? '' : gsub(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1").gsub("\n","'\n'") end
  end
end



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


