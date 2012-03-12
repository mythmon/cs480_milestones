CCC = ruby19
CCFLAGS =
OBJS =
SOURCE = translator.rb
RUNFLAGS =

stutest.out:
	./test_compiler.sh -a > stutest1.out
	cat stutest1.out

proftest.out:
	cat $(PROFTEST)
	$(CCC) $(RUNFLAGS) $(SOURCE) $(PROFTEST) > proftest.out
	cat proftest.out

test:
	@./test_compiler.sh -a

clean:
	rm -f *.out
	ls

compile:
	@echo "Nothing to do"
