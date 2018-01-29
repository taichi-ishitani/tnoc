FILE_LISTS		+= $(NOC_SV_HOME)/rtl/common/compile.f
FILE_LISTS		+= $(NOC_SV_HOME)/rtl/router/compile.f
FILE_LISTS		+= $(NOC_SV_HOME)/rtl/fabric/compile.f
FILE_LISTS		+= $(TUE_HOME)/compile.f
FILE_LISTS		+= $(NOC_SV_HOME)/env/bfm/compile.f
FILE_LISTS		+= $(NOC_SV_HOME)/env/common/compile.f
FILE_LISTS		+= $(NOC_SV_HOME)/env/fabric/compile.f
FILE_LISTS		+= $(NOC_SV_HOME)/test/fabric/compile.f

SOURCE_FILES	+= $(NOC_SV_HOME)/env/fabric/top.sv

DEFINES	+= NOC_FABRIC_ENV_DATA_WIDTH=64

