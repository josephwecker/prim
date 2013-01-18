#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'nokogiri'
require 'uri'

class HTML2Markdown

	def initialize(str, baseurl=nil)
		@links = []
		@baseuri = (baseurl ? URI::parse(baseurl) : nil)
		@section_level = 0
		#@encoding = str.encoding
		@markdown = output_for(Nokogiri::HTML(str, baseurl).root).gsub(/\n\n+/, "\n\n")
		# Hack for converting tables to defintion lists
		@td = 0
	end

	def to_s
		i = 0
		@markdown.to_s + "\n\n" + @links.map {|link|
			i += 1
			"[#{i}]: #{link[:href]}" + (link[:title] ? " (#{link[:title]})" : '')
		}.join("\n")
	end

	def output_for_children(node)
		node.children.map {|el|
			output_for(el)
		}.join
	end

	def wrap(str)
		return str if str =~ /\n/
		out = ''
		line = []
		str.split(/[ \t]+/).each {|word|
			line << word
			if line.join(' ').length >= 74
				out << line.join(' ') << " \n"
				line = []
			end
		}
		out << line.join(' ') + (str[-1..-1] =~ /[ \t\n]/ ? str[-1..-1] : '')
	end

	def output_for(node)
		case node.name
			when 'head', 'style', 'script'
				''
			when 'br'
				"  \n"
			when 'p', 'div'
				"\n\n#{wrap(output_for_children(node))}\n\n"
			when 'section', 'article'
				@section_level += 1
				o = "\n\n----\n\n#{output_for_children(node)}\n\n"
				@section_level -= 1
				o
			when /h(\d+)/
				hx = '#'*($1.to_i+@section_level)
				header = output_for_children(node).gsub(/(\n+)|(chapter\s*\d*\.)/i, "")
				anchor = header.gsub(/[\s_:']|\b(the|and|or|to)\b/i, "").gsub(/traffic\s*server/i, "TS")
				"\n\n" + hx + ' ' + header + ' ' + hx + ' {#' + anchor + '}' + "\n\n"
			when 'blockquote'
				@section_level += 1
				o = ("\n\n> #{wrap(output_for_children(node)).gsub(/\n/, "\n> ")}\n\n").gsub(/> \n(> \n)+/, "> \n")
				@section_level -= 1
				o
			when 'ul'
				"\n\n" + node.children.map {|el|
					next if el.name == 'text'
					"- #{output_for_children(el).gsub(/^\n+/, "").gsub(/^(\t)|(    )/, "\t\t").gsub(/^>/, "\t>")}\n"
				}.join + "\n\n"
			when 'ol'
				i = 0
				"\n\n" + node.children.map {|el|
					next if el.name == 'text'
					i += 1
					"#{i}. #{output_for_children(el).gsub(/^\n+/, "").gsub(/^(\t)|(    )/, "\t\t").gsub(/^>/, "\t>")}\n"
				}.join + "\n\n"
			when 'pre', 'code'
				block = "\t" + node.content.gsub(/\n/, "\n\t")
				if block.count("\n") < 1
					"`#{output_for_children(node)}`"
				else
					block
				end
			when 'hr'
				"\n\n----\n\n"
			when 'a', 'link'
				if node['href']
					link = node['href']
					if node['title']
						link +=  ' "' + node['title'] + '"'
					end
					"[#{output_for_children(node).gsub("\n",' ')}](#{link})"
				else
					output_for_children(node)
				end
			when 'img'
				link = node['src']
				if node['title']
					link +=  ' ' + node['title']
				end
				"![#{node['alt']}](#{link})"
			when 'video', 'audio', 'embed'
				link = node['src']
				if node['title']
					link +=  ' ' + node['title']
				end
				"[#{output_for_children(node).gsub("\n",' ')}](#{link})"
			when 'object'
				link = node['data']
				if node['title']
					link +=  ' ' + node['title']
				end
				"[#{output_for_children(node).gsub("\n",' ')}](#{link})"
			when 'i', 'em', 'u'
				"_#{output_for_children(node)}_"
			when 'b', 'strong'
				"**#{output_for_children(node)}**"
			# Tables suck, when not used as tables
			# we convert them to defintion lists
			when 'tr'
				@td=0
				node.children.select {|c|
					c.name == 'th' || c.name == 'td'
				}.map {|c|
					output_for(c)
				}.join + "\n\n"
			when 'th'
				"**#{output_for_children(node)}** "
			when 'td'
				if @td == 0
					@td += 1
					output_for_children(node) + "\n"
				else
					":   " + wrap(output_for_children(node)).gsub(/\n/, "\n    ")
				end
			when 'text'
        node.content
				# Sometimes Nokogiri lies. Force the encoding back to what we know it is
				#if (c = node.content.force_encoding(@encoding)) =~ /\S/
				#	c.gsub!(/\n\n+/, '<$PreserveDouble$>')
				#	c.gsub!(/\s+/, ' ')
				#	c.gsub(/<\$PreserveDouble\$>/, "\n\n")
				#else
				#	c
				#end
			else
				wrap(output_for_children(node))
		end
	end

end


puts HTML2Markdown.new(ARGF.read.gsub("\r",'')).to_s
