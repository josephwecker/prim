require 'pathname'
Path =   Pathname
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

class String
  def fnv32() bytes.reduce(0x811c9dc5)        {|h,b|((h^b)*0x01000193)    % (1<<32)} end
  def fnv64() bytes.reduce(0xcbf29ce484222325){|h,b|((h^b)*0x100000001b3) % (1<<64)} end
  def method_missing(m,*a,&b) to_p.respond_to?(m) ? to_p.send(m,*a,&b) : super       end
  def blank?()     self !~ /[^[:space:]]/                       end
  def to_p()       Path.new(self)                                 end
  def respond_to?(m,p=false) super || to_p.respond_to?(m,p) end
  def ===(p)       r=super(p); r ? r : to_p===p   end
  def to_sh()      blank? ? '' : gsub(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1").gsub("\n","'\n'") end
end

module Enumerable
  def amap(m,*a,&b) self.map {|i|i.send(m,*a,&b)} end
  def amap!(m,*a,&b)self.map!{|i|i.send(m,*a,&b)} end
end

class Path
  def to_p()  self             end
  def **  (p) self+p.to_p      end
  def r?  ()  readable_real?   end
  def w?  ()  writable_real?   end
  def x?  ()  executable_real? end
  def rw? ()  r? && w?         end
  def rwx?()  r? && w? && x?   end
  def dir?()  directory?       end
  def ===(p)  real.to_s==p.real.to_s              end
  def perm?() exp.dir? ? rwx? : rw?             end
  def exp ()  return @exp ||= self.expand_path  end
  def real()  begin exp.realpath rescue exp end end
  def dir()   exp.dir? ? exp : exp.dirname       end
  def dir!()  (exp.mkdir unless exp.dir? rescue return nil); self end
  def [](p)   Path.glob((dir + p.to_s).to_s, File::FNM_DOTMATCH)  end
  def relation_to(other)
    travp = other.exp.relative_path_from(exp).to_s
    if    travp =~ /^(..\/)+$/ then :child
    else  travp =~ /^..\// ? :stranger : :parent end
  end
end

