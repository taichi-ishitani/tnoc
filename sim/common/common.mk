FILE_LISTS		=
SOURCE_FILES	=
DEFINES				=
TEST_LIST			=

DUMP				?= off
GUI					?= off
TR_DEBUG		?= off
RANDOM_SEED	?= auto
SIMULATOR		?= vcs

TNOC_HOME	?= $(shell git rev-parse --show-toplevel)
TUE_HOME	?= $(TNOC_HOME)/env/tue

export TNOC_HOME
export TUE_HOME

-include local.mk
-include test_list.mk

.PHONY: all $(TEST_LIST) clean clean_all

all: $(TEST_LIST)

$(TEST_LIST):
	make $(RUN_SIMULATION) TEST_NAME=$@

CLEAN_TARGETS	+= *.log *.h
clean:
	rm -rf $(CLEAN_TARGETS)

clean_all:
	make clean
	rm -rf $(TEST_LIST)

include $(TNOC_HOME)/sim/common/vcs.mk
include $(TNOC_HOME)/sim/common/xcelium.mk
