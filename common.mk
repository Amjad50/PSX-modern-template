PSN00BSDK  ?= /opt/psn00bsdk/
PREFIX		= mipsel-unknown-elf-
#INCLUDE	   := # -I$(realpath $(PSN00BSDK)/libpsn00b/include)
#LIBDIRS	   :=  -L$(realpath $(PSN00BSDK)/libpsn00b)
GCC_VERSION	= 7.4.0
GCC_BASE	= /usr/local/mipsel-unknown-elf

CFLAGS	   ?= -g -msoft-float -O3 -D__PLAYSTATION__ -fno-builtin -fdata-sections -ffunction-sections -Wall -Wextra -Wno-strict-aliasing -Wno-sign-compare
CPPFLAGS   ?= $(CFLAGS) -fno-exceptions -std=c++1z
AFLAGS	   ?= -g -msoft-float
LDFLAGS	   ?= -g -Ttext=0x80010000 -gc-sections -T $(GCC_BASE)/mipsel-unknown-elf/lib/ldscripts/elf32elmip.x

# Toolchain programs
CC			= $(PREFIX)gcc
CXX			= $(PREFIX)g++
AS			= $(PREFIX)as
AR		    = $(PREFIX)ar
LD			= $(PREFIX)ld
RANLIB	    = $(PREFIX)ranlib
OBJCOPY     = $(PREFIX)objcopy

LIBS	   ?= 

CFILES		= $(notdir $(wildcard *.c))
CPPFILES 	= $(notdir $(wildcard *.cpp))
AFILES		= $(notdir $(wildcard *.s))
OFILES     += $(addprefix build/,$(CFILES:.c=.o) $(CPPFILES:.cpp=.o) $(AFILES:.s=.o))
	
build/%.o: %.c
	@mkdir -p $(dir $@)
	@echo "CC     $<"
	@$(CC) $(CFLAGS) $(INCLUDE) -c $< -o $@
	
build/%.o: %.cpp
	@mkdir -p $(dir $@)
	@echo "CXX    $<"
	@$(CXX) $(CPPFLAGS) $(INCLUDE) -c $< -o $@
	
build/%.o: %.s
	@mkdir -p $(dir $@)
	@echo "AS     $<"
	@$(AS) $(AFLAGS) $(INCLUDE) $< -o $@

BASEDIR = $(dir $(lastword $(MAKEFILE_LIST)))

INCLUDE	    += -I$(realpath $(BASEDIR)/INCLUDE)
LIBDIRS		+= -L$(realpath $(BASEDIR)/LIB)
# default libs (check later for explaination on -lpsnoobc)
LIBS        += -lpsnoobc -lc -lc2 -lapi

TARGET_EXE  := $(TARGET:.elf=.exe)

# Here, we are going to copy the libc.a from the PSN00BSDK to our LIB directory
# we don't want to rely on psn00bsdk libraries, since this defeats the purpose of using PSYQ libraries
# we are only using the libc.a from the PSN00BSDK
# This is only used because we need export for `_start` symbol since it does setup before calling `main`
# and PSYQ doesn't do that.
# TODO: would be better to have our own small library that has this `_start` symbol functionality
LIBC_START := $(realpath $(BASEDIR)/LIB)/libpsnoobc.a

# we copy the file needed, and then remove it after linking
build/$(TARGET): $(OFILES)
	@cp $(realpath $(PSN00BSDK)/libpsn00b)/libc.a $(LIBC_START)
	@echo "LD     $(TARGET)"
	@$(LD) $(LDFLAGS) $(LIBDIRS) $(OFILES) $(LIBS) -o build/$(TARGET)
	@rm $(LIBC_START)

$(TARGET_EXE): build/$(TARGET)
	@echo "ELF2X  $(TARGET:.elf=.exe)"
	@elf2x -q build/$(TARGET) $(TARGET_EXE)

all: $(TARGET_EXE)

clean:
	rm -rf build $(TARGET) $(TARGET_EXE)

.PHONY: all clean
.DEFAULT_GOAL := $(TARGET_EXE)
