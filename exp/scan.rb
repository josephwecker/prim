#puts ARGF.read.scan(/\B(-I(?!\S*?[$%()])\S+)/).uniq


#MK_RULES   = "make -qpik -C $(realpath $(<D)) -f $(<F) | awk -F':' '/^[a-zA-Z0-9][^\$$\#\/\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}'"
#MK_RULES   = make -qp -C $(realpath $(<D)) -f $(<F) | awk -F':' '/^[a-zA-Z0-9][^\$$\#\/\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}'
#MK_TGTS    = $(foreach pth,$(PROJMKS),$(call path_to_id,$(pth)).mdb)
	#ruby -e 'puts $$<.read.scan(/\B(-I(?!\S*?[$$%()])\S+)/).uniq' $<
	#ruby -e 'puts $$<.read.scan(/\B(-I(?!\S*?[$$%()])\S+)|\b(CURDIR.*)/).uniq' $<

#'/^\w[^$#\/\t=]*:([^=]|$)/'
#ruby -e 'puts $$<.read.scan //' $<

#MK_RULES   = make -qp -C $(realpath $(<D)) -f $(<F) | awk -F':' '/^[a-zA-Z0-9][^\$$\#\/\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}'
p `make -qpik -C ../..`.scan(/^(\w[^$#\/\t=]*)(?::(?!=))/).join(' ').split(' ')
