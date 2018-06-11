FILE_LISTS		=
SOURCE_FILES	=
DEFINES				=

VCS_ARGS	=
SIMV_ARGS	=
TEST_LIST	=

VCS_ARGS	+= -full64 -sverilog -timescale="1ns/1ps" -l vcs.log
VCS_ARGS	+= -ntb_opts uvm +define+UVM_NO_DEPRECATED +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTO
SIMV_ARGS	+= +vcs+lic+wait -l $(TEST_NAME).log +UVM_TESTNAME=$(TEST_NAME)

DUMP				?= off
GUI					?= off
TR_DEBUG		?= off
RANDOM_SEED	?= auto

ifeq ($(GUI), verdi)
	VCS_ARGS	+= -lca -debug_access+all -kdb +vcs+fsdbon
	SIMV_ARGS	+= -gui=verdi +fsdb+struct=on
	ifeq ($(TR_DEBUG), on)
		SIMV_ARGS	+= +UVM_VERDI_TRACE +UVM_TR_RECORD
	endif
endif
ifeq ($(GUI), dve)
	VCS_ARGS	+= +vcs+vcdpluson -debug_access+all
	SIMV_ARGS	+= -gui=dve
endif

ifeq ($(RANDOM_SEED), auto)
	SIMV_ARGS	+= +ntb_random_seed_automatic
else
	SIMV_ARGS	+= +ntb_random_seed=$(RANDOM_SEED)
endif

-include local.mk
-include test_list.mk

ifdef TOP_MODULE
	VCS_ARGS	+= -top $(TOP_MODULE)
endif

TNOC_HOME	?= $(shell git rev-parse --show-toplevel)
TUE_HOME	?= $(TNOC_HOME)/env/tue

export TNOC_HOME
export TUE_HOME

VCS_ARGS	+= $(addprefix -f , $(FILE_LISTS))
VCS_ARGS	+= $(SOURCE_FILES)
VCS_ARGS	+= $(addprefix +define+, $(DEFINES))

.PHONY: all run_simv compile_simv clean clean_all $(TEST_LIST) 

all: $(TEST_LIST)

$(TEST_LIST):
	make run_simv TEST_NAME=$@

run_simv:
	if [ ! -f simv ] ; then \
		make compile_simv ; \
	fi
	if [ ! -d $(TEST_NAME) ] ; then \
		mkdir $(TEST_NAME) ; \
	fi
	cd $(TEST_NAME); ../simv $(SIMV_ARGS)

compile_simv:
	vcs $(VCS_ARGS)

CLEAN_TARGETS	= simv* csrc *.log *.h
clean:
	rm -rf $(CLEAN_TARGETS)

clean_all:
	make clean
	rm -rf $(TEST_LIST)
