all: compile

compile:
	./rebar compile

clean:
	./rebar clean

docs:  
	utils/make_docs/make_docs.el
	@(cd doc;perl add_disqus.pl)

doc: docs

test:
	./rebar eunit

DEPS_PLT=$(CURDIR)/.deps_plt
DEPS=erts kernel stdlib crypto sasl
# removed 'sasl' in attempt to minimize memory usage for Travis

$(DEPS_PLT):
	@echo Building local plt at $(DEPS_PLT)
	@echo 
	@(dialyzer --output_plt $(DEPS_PLT) --build_plt --apps $(DEPS))

dialyzer: compile $(DEPS_PLT)
	@(dialyzer --fullpath --plt $(DEPS_PLT) -Wrace_conditions -r ./ebin)

dialyzer-no-race: compile $(DEPS_PLT)
	@(dialyzer --fullpath --plt $(DEPS_PLT) -r ./ebin)

# TRAVIS-CI STUFF

ERLANG_VERSION_CHECK := erl -eval "io:format(\"~s\",[erlang:system_info(otp_release)]), halt()."  -noshell
ERLANG_VERSION = $(shell $(ERLANG_VERSION_CHECK))

# This is primarily for Travis build testing, as each build instruction will overwrite the previous
travis: test $(ERLANG_VERSION)

R15B: dialyzer
R15B01: dialyzer
R15B02: dialyzer-no-race
R15B03: dialyzer
R16B: dialyzer
R16B01: dialyzer
R16B02: dialyzer

vim:
	utils/vim-headers/add_vim.sh
