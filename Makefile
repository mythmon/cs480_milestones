CCC = ruby19
CCFLAGS =
OBJS =
SOURCE = parser.rb
RUNFLAGS =

clean:
	rm -f *.out
	ls

stutest.out:
	cat $(SOURCE)
	$(CCC) $(RUNFLAGS) $(SOURCE) stutest1.in > stutest1.out
	cat stutest1.out

proftest.out:
	cat $(PROFTEST)
	$(CCC) $(RUNFLAGS) $(SOURCE) $(PROFTEST) > proftest.out
	cat proftest.out
