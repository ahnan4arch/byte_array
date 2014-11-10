PROJECT = byte_array99
OPTIMIZE = -O3
WARN = -Wall -Wextra -pedantic

# Necessary to ensure C99 support w/array initialization is enabled
CDEFS += -D_POSIX_C_SOURCE=1 -D_C99_SOURCE

CFLAGS += -std=c99 -g ${WARN} ${CDEFS} ${OPTIMIZE}

CFLAGS_TEST = ${CFLAGS} -DTEST -DUNITY_SUPPORT_64

TEST_EXECUTABLE = test_${PROJECT}
ifeq ($(OS),Windows_NT)
	TEST_EXECUTABLE += .exe
endif

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
