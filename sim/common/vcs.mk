ifeq ($(SIMULATOR), vcs)
	RUN_SIMULATION	:= run_simv
endif

CLEAN_TARGETS	+= simv* csrc

VCS_ARGS	+= -full64 -sverilog -timescale="1ns/1ps" -l vcs.log
VCS_ARGS	+= -ntb_opts uvm +define+UVM_NO_DEPRECATED +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTO
SIMV_ARGS	+= +vcs+lic+wait -l simv.log +UVM_TESTNAME=$(TEST_NAME)

ifeq ($(GUI), verdi)
	VCS_ARGS	+= -lca -debug_access+all -kdb +vcs+fsdbon
	SIMV_ARGS	+= -gui=verdi +fsdb+struct=on
	ifeq ($(TR_DEBUG), on)
		SIMV_ARGS	+= +UVM_VERDI_TRACE +UVM_TR_RECORD
	endif
endif
ifeq ($(GUI), dve)
	VCS_ARGS	+= -debug_access+all +vcs+vcdpluson
	SIMV_ARGS	+= -gui=dve
endif

ifeq ($(DUMP), fsdb)
	VCS_ARGS	+= -lca -debug_access -kdb +vcs+fsdbon
	SIMV_ARGS	+= +fsdb+struct=on +fsdbfile+dump.fsdb
endif
ifeq ($(DUMP), vpd)
	VCS_ARGS	+= -debug_access +vcs+vcdpluson
	SIMV_ARGS	+= -vpd_file dump.vpd
endif

ifeq ($(RANDOM_SEED), auto)
	SIMV_ARGS	+= +ntb_random_seed_automatic
else
	SIMV_ARGS	+= +ntb_random_seed=$(RANDOM_SEED)
endif

ifdef TOP_MODULE
	VCS_ARGS	+= -top $(TOP_MODULE)
endif

VCS_ARGS	+= $(addprefix -f , $(FILE_LISTS))
VCS_ARGS	+= $(SOURCE_FILES)
VCS_ARGS	+= $(addprefix +define+, $(DEFINES))

.PHONY: run_simv compile_simv

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
