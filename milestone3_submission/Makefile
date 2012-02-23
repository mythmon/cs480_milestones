CCC = ruby19
CCFLAGS =
OBJS =
SOURCE = parser.rb
RUNFLAGS =
PROFTEST = proftest.in

stutest.out:
	bash test_parser.sh > stutest1.out
	cat stutest1.out

proftest.out:
	$(CCC) $(RUNFLAGS) $(SOURCE) $(PROFTEST) > proftest.out
	cat proftest.out

clean:
	rm -f *.out
	ls

compile:
	@echo "Nothing to do"
