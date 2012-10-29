PROJMKS    = $(shell find ../.. -name 'Makefile' | awk '{print length"\t"$$0}'|sort -n|cut -f2-)
MAIN_SRC   = $(realpath $(dir $(firstword $(PROJMKS))))
MK_TGTS    = $(foreach pth,$(PROJMKS),$(call path_to_id,$(pth)).dry)

DTGTS      = $(patsubst ../%,.%.tags,$(wildcard ../*.[ch]))
EXCTAGS    = ctags -f - --tag-relative=yes --format=2 --excmd=number      \
						 --extra=+fq --fields=+afikKlmnSszt --c-kinds=+cdefglmnpstuvx \
						 --c++-kinds=+cdefglmnpstuvx --file-scope=yes --sort=no $< |  \
						 grep -v '^!_' > $@
META       = "!_TAG_FILE_FORMAT\t2\n!_TAG_FILE_SORTED\t1\n"

path_to_id = $(shell echo $1 | base64 | tr '/=' '_-')
id_to_path = $(shell echo $1 | tr '_-' '/=' | base64 -D)

define one_shell_ruby
	$(eval export $1)
	@echo $2
	@echo "$${$1}" | /usr/bin/env ruby --
endef

all      : tags mk_incs


# TODO: you are here-
# You now have the basic build commands == -I flags etc.
# Then another rule that uses those dbs and combines them for some default -I
# rules.
# Then use those -I rules to generate "extended network" tagfiles instead of
# just everything in the same directory via cpp -E ...
# Then also use those -I rules to generate the cscope databases...

tags     : $(DTGTS) ; printf $(META) | LC_ALL='C' sort -g -k1 -t'	' $^ - > $@
.%.tags  : ../% ; $(EXCTAGS)

mk_incs  : $(MK_TGTS)
#	@#ruby -e 'puts $$<.read.scan(/\B(-I(?!\S*?[$$%()])\S+)/).uniq' $<
#	@#ruby -e 'puts $$<.read.scan(/\B(-I(?!\S*?[$$%()])\S+)|\b(CURDIR.*)/).uniq' $<

define makefile_dryrun_rb
	note = "Generating dry-run for $<"
	puts note and `echo '# #{note}' > $@`
	class String; def esc; empty? ? "''" : gsub(/([^A-Za-z0-9_\-=.,:\/@\n])/n,"\\\\\\1").gsub(/\n/,"'\n'") end end
	class Array;  def esc; map{|v|v.to_s.esc}.join(' ') end end
	class Hash;   def esc; map{|k,v| (k.to_s+'='+v.to_s).esc}.join(' ') end end
	srcdir = '$(MAIN_SRC)'
	mkvars = {:SRC_PATH=>srcdir, :source_path=>srcdir, :src_path=>srcdir}
	dryrun = "make #{mkvars.esc} -nBikwj -W '*' -C $(<D) -f $(<F)"
	$$stderr.puts dryrun
	goals  = `make #{mkvars.esc} -qpikj -C $(<D) -f $(<F)`
	goals  = goals.scan /^(\w[^:$$\#\/\t=%\*\n]*)(?::(?!=))/
	goals  = goals.join(' ').split(/\s+/)
	dry1   = `#{dryrun} #{goals.esc} 2>&1 1>$@`
	if dry1 =~ /No rule/
		goals -= dry1.scan(/`[^']+'/).map{|r|r[1..-2]}
		dry2   = `#{dryrun} #{goals.esc} &>$@`.strip
	end
	exit 0
endef

.SECONDEXPANSION:
%.dry    : $$(call id_to_path,%)
	$(call one_shell_ruby,makefile_dryrun_rb)
.%.deps  : $$(call id_to_path,%)
	cpp #{inc} -E -M -MG
