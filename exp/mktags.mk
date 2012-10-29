PROJECT    = /Users/jwecker/src/ffmpeg
#HOMEDIR    = /Users/jwecker/.prim

path_to_id = $(shell echo $1 | base64 | tr '/=' '_-')
id_to_path = $(shell echo $1 | tr '_-' '/=' | base64 -D)
#qpath_to_id= $(subst .,-,$(subst /,-,$1))

PID        = $(call path_to_id,$(PROJECT))
PDIRS      = $(shell find '$(PROJECT)' -type d -not -path '*/.*')

P          = $(wildcard ~)/.prim/$(PID)

all: $P/src.files $P/src.dirs tags

$P : ; mkdir -p '$P'

$P/src.files : $(PDIRS) | $P
	cd '$(PROJECT)' && find . -type f -name '*.[chi]' -not -path '*/.*' | sort -u > $@

$P/src.dirs : $P/src.files | $P
	cat $< | sed 's/\/[^\/]*$$//g' | uniq > $@

tagdirs : TAGDIRS=$(patsubst %,$P/subtags/%,$(shell cat '$P/src.dirs'))
tagdirs : $(TAGDIRS) | $P/src.dirs 
	mkdir -p $^
	

tags : TAGFILES=$(patsubst %,$P/subtags/%.tags,$(shell cat '$P/src.files'))
tags : $P/src.files tagdirs $(TAGFILES)

$P/subtags/%.tags : $(PROJECT)/%
	mkdir -p `dirname $@`
	echo 'got it' > $@

#$P/tags.mk : $P/src.files
#	cat $< | ruby -p -e '\
#		$$_.strip! ; \
#		tdr="$P/subtags/#{$$_.split("/")[0..-2].join("/")}" ; \
#		$$_="$P/subtags/#{$_}.tags : $(PROJECT)/#{$_} | #{tdr}}\n#{tdr} : ; mkdir -p #{tdr}\n"'

#tagdirs : $P/src.dirs $(patsubst %,$P/subtags/%,$(shell cat $P/src.dirs))

#$P/subtags/% :
#	mkdir -p 


#tags : TAGSRCS=$(shell cat '$P/src.files')
#tags : TAGTGTS=$(patsubst %,$P/%.tags,$(TAGSRCS))
#tags : TAGTGTS=$(foreach src,$(TAGSRCS),$(src))
#tags : TAGTGTS=$(patsubst ../%,.%.tags,$(shell cat '$P/source_files.list'))
#tags : TAGTGTS=$(foreach pth,$(TAGSRCS),$(call path_to_id,$(pth)).tags)

#tags : $P/src.files
#	@echo $(TAGTGTS)

# Per directory tagfiles & combination tagfile
#TAGFS    = $(patsubst ../%,.%.tags,$(wildcard ../*.[ch]))
#CTAGS    = ctags -f - --tag-relative=yes --format=2 --excmd=number          \
#					 --extra=+fq --fields=+afikKlmnSszt --c-kinds=+cdefglmnpstuvx     \
#					 --c++-kinds=+cdefglmnpstuvx --file-scope=yes --sort=no $<
#META     = "!_TAG_FILE_FORMAT\t2\n!_TAG_FILE_SORTED\t1\n"
#tags     : $(TAGFS) ; printf $(META) | LC_ALL='C' sort -g -k1 -t'	' $^ - > $@
#.%.tags  : ../%     ; $(CTAGS)       | grep -v '^!_' > $@




# Per directory individual file dependencies
# (for search relevance)

# Per project include directories
# (to generate file dependencies & polish cscope files)

# Per project cscope files


