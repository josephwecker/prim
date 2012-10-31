path_to_id = $(shell echo $1 | base64 | tr '/=' '_-')
id_to_path = $(shell echo $1 | tr '_-' '/=' | base64 -D)

PROJ     = /Users/jwecker/src/ffmpeg
#PDIRS    = $(shell find '$(PROJ)' -type d -not -path '*/.*')
PID      = $(call path_to_id,$(PROJ))
P        = $(wildcard ~)/.prim/$(PID)
SRCFILES = $(shell cd '$(PROJ)' && find . -type f -name '*.[chi]' -not -path '*/.*' | sort -u)
SRCDIRS  = $(shell echo $(SRCFILES) | sed 's/\/[^\/]*\($$\| \)/\n/g' | sort -u)
TAGFILES = $(patsubst %,$P/subtags/%.tags,$(SRCFILES))
TAGDIRS  = $(patsubst %,$P/subtags/%,$(SRCDIRS))

CTAGS    = ctags -f - --tag-relative=yes --format=2 --excmd=number          \
					 --extra=+fq --fields=+afikKlmnSszt --c-kinds=+cdefglmnpstuvx     \
					 --c++-kinds=+cdefglmnpstuvx --file-scope=yes --sort=no
META     = "!_TAG_FILE_FORMAT\t2\n!_TAG_FILE_SORTED\t1\n"

all           : $P/tags $P/cscope.out
$P            :      ; @mkdir -p '$P'
$(TAGDIRS)    : | $P ; @mkdir -p $@
$(TAGFILES)   : $P/subtags/%.tags : $(PROJ)/% |$(TAGDIRS)
	@$(CTAGS) $(subst /./,/,$<) | grep -v '^!_' > $@
$P/tags       : $(TAGFILES)
	@cd '$P/subtags' && printf $(META) | LC_ALL='C' sort -g -k1 -t'	' $(subst $P/subtags/,,$^) - > $@
$P/cscope.out : $(SRCFILES) | $P
	@cd '$(PROJ)' && cscope -b -c -q -U $(patsubst %,-I%,$(SRCDIRS)) -P'$(PROJ)' -R -f'$@'



# Per directory individual file dependencies
# (for search relevance)

# Per project include directories
# (to generate file dependencies & polish cscope files)

# Per project cscope files


