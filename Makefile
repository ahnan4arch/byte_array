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

default: test lib${PROJECT}.a

all: clean default

OBJS = ${PROJECT}.o test_${PROJECT}_runner.o

${PROJECT}.o: byte_array.c byte_array.h
	@echo
	@echo Building library source
	@echo ----------------------------------------
	${CC} -c -o $@ $< ${CFLAGS}
	@echo

unity.o: unity/unity.c unity/unity.h unity/unity_internals.h
	@echo
	@echo Building Unity test framework
	@echo ----------------------------------------
	${CC} -c -o $@ $< ${CFLAGS_TEST}
	@echo

${TEST_EXECUTABLE}: test_${PROJECT}.c test_${PROJECT}_runner.o ${OBJS} unity.o
	@echo Building tests
	@echo ----------------------------------------
	${CC} -o $@ $< ${OBJS} unity.o ${CFLAGS_TEST} -I./unity
	@echo

test_${PROJECT}_runner.o: test_${PROJECT}.c
	@echo Creating test runner for $<
	@echo ----------------------------------------
	./generate_test_runner.sh $< > test_${PROJECT}_runner.c
	${CC} -o $@ -c test_${PROJECT}_runner.c ${CFLAGS_TEST} -I./unity

test: ${TEST_EXECUTABLE}
	@echo
	@echo Testing $(PROJECT)
	@echo ----------------------------------------; ./${TEST_EXECUTABLE}

lib${PROJECT}.a: ${OBJS}
	@echo
	@echo Building static library
	@echo ----------------------------------------
	ar -rcs $@ ${OBJS}
	@echo $@ built successfully!
	@echo

clean:
	rm -rf ${PROJECT} test_${PROJECT} *.o *.a *.core *.dSYM/ test_*_runner.c
	@echo

${PROJECT}.o: ${PROJECT}.h

test_${PROJECT}.o: ${PROJECT}.o
