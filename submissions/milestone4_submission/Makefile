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

test:
	@tar -zxf test_programs.tar
	@./test_compiler.sh -a > stutest1.out
	@cat stutest1.out
	@rm -rf test_programs

clean:
	rm -f *.out
	ls

compile:
	@echo "Nothing to do"
