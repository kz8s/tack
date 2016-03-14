## display this help text
help:
	$(info Available targets)
	@awk '/^[a-zA-Z\-\_0-9]+:/ {                    \
		nb = sub( /^## /, "", helpMsg );              \
		if(nb == 0) {                                 \
			helpMsg = $$0;                              \
			nb = sub( /^[^:]*:.* ## /, "", helpMsg );   \
		}                                             \
		if (nb)                                       \
			print  $$1 "\t" helpMsg;                    \
	}                                               \
	{ helpMsg = $$0 }'                              \
	$(MAKEFILE_LIST) | column -ts $$'\t' |          \
	grep --color '^[^ ]*'

.PHONY: help
