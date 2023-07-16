CC=gcc
CXX=g++
CFLAGS=-I. -O3 -std=c11 -fPIC
CXXFLAGS=-I. -O3 -std=c++11 -fPIC
LDFLAGS=-pthread
UNAME_S := $(shell uname -s)
UNAME_P := $(shell uname -p)
UNAME_M := $(shell uname -m)

# Warnings
CFLAGS += -Wall -Wextra -Wpedantic -Wcast-qual -Wdouble-promotion -Wshadow -Wstrict-prototypes -Wpointer-arith
CXXFLAGS += -Wall -Wextra -Wpedantic -Wcast-qual -Wno-unused-function -Wno-multichar

# OS specific
ifeq ($(UNAME_S),Linux) 
    CFLAGS += -pthread
    CXXFLAGS += -pthread
endif
ifeq ($(UNAME_S),Darwin)
    CFLAGS += -pthread
    CXXFLAGS += -pthread
endif
ifeq ($(UNAME_S),FreeBSD)
    CFLAGS += -pthread
    CXXFLAGS += -pthread
endif
ifeq ($(UNAME_S),NetBSD)
    CFLAGS += -pthread
    CXXFLAGS += -pthread
endif
ifeq ($(UNAME_S),OpenBSD)
    CFLAGS += -pthread
    CXXFLAGS += -pthread
endif
ifeq ($(UNAME_S),Haiku)
    CFLAGS += -pthread
    CXXFLAGS += -pthread
endif

# Architecture specific
ifeq ($(UNAME_M),$(filter $(UNAME_M),x86_64 i686))
    CFLAGS += -march=native -mtune=native
    CXXFLAGS += -march=native -mtune=native
endif
ifneq ($(filter ppc64%,$(UNAME_M)),)
    POWER9_M := $(shell grep "POWER9" /proc/cpuinfo)
    ifneq (,$(findstring POWER9,$(POWER9_M)))
        CFLAGS += -mcpu=power9
        CXXFLAGS += -mcpu=power9
    endif
    ifeq ($(UNAME_M),ppc64)
        CXXFLAGS += -std=c++23 -DGGML_BIG_ENDIAN
    endif
endif
ifndef NO_ACCELERATE
    ifeq ($(UNAME_S),Darwin)
        CFLAGS += -DGGML_USE_ACCELERATE
        LDFLAGS += -framework Accelerate
    endif
endif
ifdef OPENBLAS
    CFLAGS += -DGGML_USE_OPENBLAS -I/usr/local/include/openblas
    ifneq ($(shell grep -e "Arch Linux" -e "ID_LIKE=arch" /etc/os-release 2>/dev/null),)
        LDFLAGS += -lopenblas -lcblas
    else
        LDFLAGS += -lopenblas
    endif
endif
ifdef GPROF
    CFLAGS += -pg
    CXXFLAGS += -pg
endif
ifdef PERF
    CFLAGS += -DGGML_PERF
    CXXFLAGS += -DGGML_PERF
endif
ifneq ($(filter aarch64%,$(UNAME_M)),)
    CFLAGS += -mcpu=native
    CXXFLAGS += -mcpu=native
endif

.PHONY: all clean

all: main

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

main: ggml.o common.o common-ggml.o main.o
	$(CXX) $^ -o $@ $(LDFLAGS)

clean:
	rm -f *.o main
