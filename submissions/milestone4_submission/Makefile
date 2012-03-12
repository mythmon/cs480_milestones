CCC = ruby19
CCFLAGS =
OBJS =
SOURCE = translator.rb
RUNFLAGS =

stutest.out:
	@tar -zxf test_programs.tar
	@./test_compiler.sh -a > stutest1.out
	@cat stutest1.out
	@rm -rf test_programs

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
