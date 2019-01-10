# Makefile

SRCTOP=..
include $(SRCTOP)/build/vars.mak
PLUGIN_PATCH_LEVEL=1.0.4
build: package
unittest:
systemtest: test-setup test-run
emaketest:
	$(MAKE) NTESTFILES="systemtest/klocworkea.ntest" RUNEMAKETESTS=1 test-setup test-run

NTESTFILES ?= systemtest

test-setup:
	$(EC_PERL) ../EC-Klocwork-EA/systemtest/setup.pl $(TEST_SERVER) $(PLUGINS_ARTIFACTS)

test-run: systemtest-run

include $(SRCTOP)/build/rules.mak
