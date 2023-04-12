-include .config

TOPDIR := ${shell pwd | sed -e 's/ /\\ /g'}

COLOR_RESET="\033[0m"
COLOR_RED="\033[0;31m"
COLOR_YELLOW="\033[1;33m"
COLOR_WHITE="\033[1;37m"

TARGET = product
TIZENRT_PATH = /root/product/.tizenrt
DACM_PATH = /root/product/.dacm

# Initialize values
VPATH =
CSRCS =
CFLAGS =
LDFLAGS =

# Default CFLAGS for the cortex-m33
CFLAGS += -g
CFLAGS += -Os
CFLAGS += -std=c99
CFLAGS += -Wall
CFLAGS += -Wstrict-prototypes
CFLAGS += -Wshadow
CFLAGS += -Wundef
CFLAGS += -Wno-implicit-function-declaration
CFLAGS += -Wno-unused-function
CFLAGS += -Wno-unused-but-set-variable
CFLAGS += -fno-strict-aliasing
CFLAGS += -fno-strength-reduce
CFLAGS += -fomit-frame-pointer
CFLAGS += -fno-builtin
CFLAGS += -mcpu=cortex-m33
CFLAGS += -mfpu=fpv5-sp-d16
CFLAGS += -fomit-frame-pointer
CFLAGS += -mcpu=cortex-m33
CFLAGS += -mthumb
CFLAGS += -mcmse
CFLAGS += -mfloat-abi=soft
CFLAGS += -pipe
CFLAGS += -ffunction-sections
CFLAGS += -fdata-sections
CFLAGS += -Wno-missing-braces
CFLAGS += -march=armv8-m.main+dsp
CFLAGS += -D__WITH_DTLS__
CFLAGS += -D__WITH_TLS__
CFLAGS += -DTCP_ADAPTER
CFLAGS += -DIP_ADAPTER
CFLAGS += -DWITH_BWT
CFLAGS += -DROUTING_EP
CFLAGS += -D__TIZENRT__
CFLAGS += -DCONFIG_PLATFORM_8721D
CFLAGS += -DCONFIG_USE_MBEDTLS_ROM_ALG
CFLAGS += -DDM_ODM_SUPPORT_TYPE=32
CFLAGS += -DSTD_PRINTF
CFLAGS += -DCONFIG_PLATFORM_TIZENRT_OS=1
CFLAGS += -DARM_CORE_CM4

CFLAGS += -I.
CFLAGS += -I$(DACM_PATH)

CSRCS =

CFLAGS += -I$(TIZENRT_PATH)/os/include
CFLAGS += -I$(TIZENRT_PATH)/os/net/lwip/src/include

include TizenRT.mk

SUBDIRS := $(dir $(wildcard */Make.defs))
SUBDIRS += $(dir $(wildcard */*/Make.defs))
SUBDIRS += $(dir $(wildcard */*/*/Make.defs))
SUBDIRS += $(dir $(wildcard */*/*/*/Make.defs))
SUBDIRS += $(dir $(wildcard */*/*/*/*/Make.defs))
SUBDIRS += $(dir $(wildcard */*/*/*/*/*/Make.defs))

define Add_Module
	MOD_CSRCS :=
	MOD_CFLAGS :=

	$(eval MOD_DIR := $(1))
	$(eval include $(1)Make.defs)

	CSRCS += $(addprefix $(1), $(MOD_CSRCS))
	CFLAGS += $(MOD_CFLAGS)
endef

$(foreach SDIR, $(SUBDIRS), $(eval $(call Add_Module,$(SDIR))))

OBJS = $(subst .c,.o, $(CSRCS))

all: $(TARGET)
	@echo ""
	@echo ${COLOR_RED}"All Done.."${COLOR_RESET}
	@echo ""

.c.o:
	@echo [${COLOR_YELLOW}Building C${COLOR_RESET}] ${COLOR_WHITE}$(notdir $<)${COLOR_RESET} ..
	@arm-none-eabi-gcc $(CFLAGS) -c $< -o $@ 2>&1 | sed -e 's/error:/\x1b[31mERROR:\x1b[0m/g' -e 's/warning:/\x1b[93mWARNING:\x1b[0m/g'

check_context:
	@if [ ! -e .config ]; then \
		echo "" ; \
		echo "Not configured:" ; \
		echo "  ./dbuild.sh menuconfig" ; \
		echo "" ; \
		exit 1 ; \
	fi

mkconfig:
ifeq ($(shell test -e utils/Makefile && echo -n yes),yes)
	@make -C utils
	@utils/mkconfig . > prconf.h
else
	@make -C tools
	@tools/mkconfig . > prconf.h
endif

$(TARGET): check_context mkconfig $(OBJS)
	@arm-none-eabi-ar rcs lib$(TARGET).a $(OBJS)

config:
	@kconfig-conf Kconfig

oldconfig:
	@kconfig-conf --oldconfig Kconfig

menuconfig: apps_preconfig
	@kconfig-mconf Kconfig

clean:
	@rm -rf output
	@find . -name "*.o" -delete \( ! -regex '.*/\..*' \)
	@find . -name "lib$(TARGET).a" -delete

apps_preconfig:
ifeq ($(shell test -e utils/fillkconf.py && echo -n yes),yes)
	@python3 utils/fillkconf.py $(TOPDIR)
else
	@python3 tools/fillkconf.py $(TOPDIR)
endif

update:
	@git submodule foreach git checkout -- .
	@git submodule foreach git checkout master
	@git submodule foreach git fetch --all
	@git submodule foreach git reset --hard origin/master
	@git submodule update --init --remote --recursive

setup:
	./utils/run_setup_docker.sh

dbuild:
	@utils/dbuild.sh

download:
	./utils/flash.sh ALL
