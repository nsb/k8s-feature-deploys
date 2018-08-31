BRANCH_NAME ?=

$(if $(BRANCH_NAME),,$(error BRANCH_NAME variable not set))

src_generate_html: _src/index.html

_src/:
	mkdir -p $@

_src/%.html: %.template.html _src/ FORCE
	sed \
	-e 's/__BRANCH_NAME__/$(BRANCH_NAME)/g' \
	$< > $@

FORCE:
