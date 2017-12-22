NOC_HOME		:= $(shell git rev-parse --show-toplevel)
NOC_SV_HOME	:= $(NOC_HOME)/sv
TUE_HOME		:= $(NOC_SV_HOME)/env/tue

export NOC_HOME
export NOC_SV_HOME
export TUE_HOME

FILE_LISTS		?=
SOURCE_FILES	?=

VCS_ARGS	?=
SIMV_ARGS	?=

VCS_ARGS	+= -full64 -sverilog -timescale="1ns/1ps" -l vcs.log
VCS_ARGS	+= -ntb_opts uvm +define+UVM_NO_DEPRECATED +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTO
SIMV_ARGS	+= +vcs+lic+wait-l $(TEST_NAME).log +UVM_TESTNAME=$(TEST_NAME)

DUMP			?= off
GUI				?= off
TR_DEBUG	?= off

ifeq ($(GUI), verdi)
	VCS_ARGS	+= -lca -debug_access+all -kdb +vcs+fsdbon
	SIMV_ARGS	+= -gui=verdi
	ifeq ($(TR_DEBUG), on)
		SIMV_ARGS	+= +UVM_VERDI_TRACE +UVM_TR_RECORD
	endif
endif
ifeq ($(GUI), dve)
	VCS_ARGS	+= +vcs+vcdpluson -debug_access+all
	SIMV_ARGS	+= -gui=dve
endif

-include local.mk

VCS_ARGS	+= $(addprefix -f , $(FILE_LISTS))
VCS_ARGS	+= $(SOURCE_FILES)

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
