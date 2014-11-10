PROJECT = byte_array

OPTIMIZE = -O3

WARN = -Wall -Wextra -pedantic

# Necessary to ensure C99 support w/array initialization is enabled
CDEFS += -D_POSIX_C_SOURCE=1 -D_C99_SOURCE

CFLAGS += -std=c99 -g ${WARN} ${CDEFS} ${OPTIMIZE}

CFLAGS_TEST = ${CFLAGS} -DTEST
# Need to update to append this option ONLY on 64-bit OS!
CFLAGS_TEST += -DUNITY_SUPPORT_64

TEST_EXECUTABLE = test_$(PROJECT)
ifeq ($(OS),Windows_NT)
	TEST_EXECUTABLE += .exe
endif

# LBITS = $(shell getconf LONG_BIT)
# config:
# 	ifeq ($(LBITS),64)
# 		CFLAGS_TEST += -DUNITY_SUPPORT_64
# 		$(echo 'Building/testing in 64-bit mode')
# 	else
# 		$(echo 'Building/testing in 32-bit mode')
# 	endif

default: all

all: ${TEST_EXECUTABLE} lib${PROJECT}.a

OBJS = ${PROJECT}.o

lib${PROJECT}.a: ${OBJS}
	ar -rcs lib${PROJECT}.a ${OBJS}

unity.o: unity/unity.c unity/unity.h unity/unity_internals.h
	${CC} -c -o $@ $< ${CFLAGS_TEST}

${TEST_EXECUTABLE}: test_${PROJECT}.c ${OBJS} unity.o
	${CC} -o $@ $< ${OBJS} unity.o ${CFLAGS_TEST} -I./unity

test: ${TEST_EXECUTABLE}
	./${TEST_EXECUTABLE}

clean:
	rm -f ${PROJECT} test_${PROJECT} *.o *.a *.core

${PROJECT}.o: ${PROJECT}.h
test_${PROJECT}.o: ${PROJECT}.o
