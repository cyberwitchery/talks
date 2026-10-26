COMPILER=xelatex
TARGET=talk

all:
	${COMPILER} ${TARGET}
	${COMPILER} ${TARGET}
	make cleanup

cleanup:
	rm -f ${TARGET}.aux ${TARGET}.log ${TARGET}.nav ${TARGET}.out ${TARGET}.snm ${TARGET}.toc ${TARGET}.vrb

clean: cleanup
	rm -f ${TARGET}.pdf
