#!/usr/bin/env ruby
require 'rubygems'
require 'json'

# TODO: actually use the api, etc.:
# https://api.stackexchange.com/2.0/search?order=desc&sort=votes&intitle=git&site=stackoverflow&filter=!9Tk5iz1Gf
# (that filter gives lots of extra data etc. so it doesn't have to be loaded in separate requests).
#
j = JSON.load IO.read('/Users/jwecker/res.json')

j['items'].each do |h|
  puts "<hr /><h1>#{h['title']}</h1>"
  puts h['body']
  h['answers'].each{|a| puts "<hr />#{a['body']}"}
end
