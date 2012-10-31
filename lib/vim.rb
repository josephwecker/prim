module Kernel; def require_r(p) require File.join(File.dirname(caller[0]), p.to_str) end end
require_r '../lib/shorthand.rb'

class VimBuf
  def initialize(pwd, lsline)
    @pwd   = pwd
    @parts = lsline.strip.scan /^(\d+)([u ])([%# ])([ah ])([-= ])([\+x ]) +"(.*)" +line (\d+)$/
  end
  def path()  end
  def unlisted?() end


  #attr_accessor :unlisted, :current, :alternate, :visible, :closed, :modifiable, :readonly, :modified, :errors
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
    Vim.cmd('pwd | ls!').each {|out|
      raw  = out.strip.split("\n")
      vpwd = raw.shift
      raw.map{|buff| VimBuf.new(vpwd, buff)}
    }.flatten
  end
end
