require 'set'
module Kernel; def require_r(p) require File.join(File.dirname(caller[0]), p.to_str) end end
require_r '../lib/shorthand.rb'

class VimBuf
  def initialize(pwd, lsline)
    @pwd   = pwd
    @str   = lsline.strip
    @parts = @str.scan(/^(\d+)([u ])([%# ])([ah ])([-= ])([\+x ]) +"(.*)" +line (\d+)$/)[0]
  end
  def inspect() "<VimBuf: #{path} [#{to_set.to_a.join('|')}]>" end
  def path()        unlisted? ? @parts[6].to_p : @pwd.to_p.join(@parts[6]) end
  def unlisted?()   @parts[1] == 'u' end
  def current?()    @parts[2] == '%' end
  def alternate?()  @parts[2] == '#' end
  def visible?()    @parts[3] == 'a' end
  def closed?()     @parts[3] == ' ' end
  def modifiable?() @parts[4] != '-' && @parts[4] != '=' end
  def readonly?()   ! modifiable?    end
  def modified?()   @parts[5] == '+' end
  def has_errors?() @parts[5] == 'x' end
  def to_set()
    return @set unless @set.nil?
    @set = Set.new
    @set.add 'unlisted'   if unlisted?   ; @set.add 'current'    if current?
    @set.add 'alternate'  if alternate?  ; @set.add 'visible'    if visible?
    @set.add 'closed'     if closed?     ; @set.add 'readonly'   if readonly?
    @set.add 'modified'   if modified?   ; @set.add 'has_errors' if has_errors?
    return @set
  end
end

class Vim
  def self.name()
    return @@vim_cmd ||= %w[gvim vim mvim].reduce do |_a,v|
      `#{v} -h 2>/dev/null`.include?('--remote') ? (break(v)) : _a
    end
  end

  def self.cli(*args)
    throw 'No vim command that will work' if Vim.name.blank?
    args       = args.amap(:to_a).flatten.amap(:to_s)
    e          = args.find_index('errors')
    errors     = e.nil?  ? 'devnull' : args.delete_at(e+1)
    err_action = {'devnull'=>'2>/dev/null','include'=>'2>&1'}[errors] || ''
    cmd        = "#{Vim.name} #{args.amap(:to_sh).join(' ')} #{err_action}"
    return `#{cmd}`
  end

  def self.servers
    @@schkt  ||= nil
    @@servers  = nil if @@schkt.blank? || (Time.now - @@schkt > 5.0)
    return @@servers unless @@servers.blank?
    @@servers  = Vim.cli('--serverlist')
    return nil if @@servers.blank?
    @@schkt    = Time.now
    return @@servers = @@servers.split(/\s+/)
  end

  def self.expr(expr) Vim.servers.map{|s|Vim.cli('--servername',s,'--remote-expr',expr)} end
  def self.cmd(cmd)   Vim.expr("ExCmd(\"#{cmd}\")") end

  def self.curr_buffers
    Vim.cmd('pwd | ls!').map {|out|
      raw  = out.strip.split("\n")
      vpwd = raw.shift
      raw.map{|buff| VimBuf.new(vpwd, buff)}
    }.flatten
  end
end


