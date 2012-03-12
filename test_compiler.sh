#!/bin/bash

ruby=/usr/bin/ruby19
compiler="translator.rb"
gforth="gforth"
tmp_fs="./test_programs/tmp_test.fs" # Temporary output for compiles gforth
tmp_gforth_output="./test_programs/tmp_test.out" # Temporary outpur for results of compiled gforth program
test_dir="./test_programs"
DEBUG=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_ERROR=0

# COLOR
FG_PASS="32m"
FG_FAIL="1;31m"
FG_ERROR="0;33m"
BG="1m"

function debug(){
    if [ $DEBUG -eq 1 ]; then
        echo -n "[DEBUG] "
        echo "$1"
    fi
}
function bad_programs(){

    echo "**************** Bad Programs ****************"
    FILES="./test_programs/bad_programs/*"
    for file in $FILES
    do
        if [ ! -f $file ]
        then
            continue
        fi
        # dirname
        dirname=`dirname "$file"`
        # everything before last '/'
        dirname=${file%/*}
        debug "\$dirname: $dirname"
        # basename
        basename=`basename "$file"`
        # everything after last '/'
        basename=${file##*/}
        debug "\$basename: $basename"

        ext=${file##*.}
        debug "\$ext: $ext"
        echo -n "--> Compiling Testing [ "$basename" ]"

        if [ "$ext" != 'ibtl' ]
        then
            debug "Skipping $file"
            continue # Skip the expect only use the ibtl files.
        fi
        # Test compiler. Should report error
        debug "$ruby $compiler $file > $tmp_fs"
        $ruby $compiler $file > $tmp_fs
        if [ $? -ne 1 ]; then
            TESTS_FAILED=$((TESTS_FAILED+1))
            echo -ne "\033[$FG_FAIL\033[$BG  FAIL \033[0m\n";
            echo "$basename reported a success error value"
            # Print ibtl
            echo "++++++ IBTL file"
            # Print expect
            if [ $DEBUG -eq 1 ]; then
                echo -n "[DEBUG] "
                echo "cat $file"
            fi
            cat $file
            rm -f $tmp_gforth_output
            rm -f $tmp_fs
            continue
        else
            TESTS_PASSED=$((TESTS_PASSED+1))
            echo -ne "\033[$FG_PASS\033[$BG  PASS  \033[0m\n";
        fi
        echo
        rm -f $tmp_gforth_output
        rm -f $tmp_fs

    done

}
function good_programs(){
    echo "**************** Good Programs ****************"
    FILES="./test_programs/good_programs/*"
    for file in $FILES
    do
        if [ -f $file ]
        then
            # dirname
            dirname=`dirname "$file"`
            # everything before last '/'
            dirname=${file%/*}
            debug "\$dirname: $dirname"


            # basename
            basename=`basename "$file"`
            # everything after last '/'
            basename=${file##*/}
            debug "\$basename: $basename"

            # corename
            corename=$(echo "$basename" | sed 's/\..*//') # (testX) where X is a number
            debug "\$corename: $corename"

            ext=${file##*.}
            debug "\$ext: $ext"


            # Construct the ibtl file name
            expect_file=$dirname"/"$corename".expect"
            debug "\$expect_file: $expect_file"

            if [ "$ext" != 'ibtl' ]
            then
                debug "Skipping $file"
                continue # Skip the expect only use the ibtl files.
            fi
            # Let's make sure this an ibtl file.
            echo -n "--> Compiling Testing [ "$basename" ]"
            debug "\$file: $file"
            # Run the tests
            # ibtl -> gforth
            debug "$ruby $compiler $file > $tmp_fs"
            $ruby $compiler $file > $tmp_fs

            if [ $? -eq 1 ]; then
                TESTS_FAILED=$((TESTS_FAILED+1))
                echo -ne "\033[$FG_FAIL\033[$BG  FAIL \033[0m\n";
                echo - "$basename did not compile"
                # Print IBTL
                echo "++++++ IBTL file"
                if [ $DEBUG -eq 1 ]; then
                    echo -n "[DEBUG] "
                    echo "cat $file"
                fi
                cat $file
                # Print compiled
                echo "++++++ Compiler Output"
                debug "cat $tmp_fs"
                cat $tmp_fs
                rm -f $tmp_gforth_output
                rm -f $tmp_fs
                continue
            fi
            debug "[DEBUG] Program succesfully compiled"

            # gforth $(compiled_file)
            debug "$gforth $tmp_fs > $tmp_gforth_output"
            $gforth $tmp_fs > $tmp_gforth_output
            if [ $? -eq 1 ]; then
                echo
                TESTS_ERROR=$((TESTS_ERROR+1))
                echo -ne "\033[$FG_ERROR\033[$BG  FAIL \033[0m\n";
                echo "$basename crashed gforth"
                # Print ibtl
                echo "++++++ IBTL file"
                if [ $DEBUG -eq 1 ]; then
                    echo -n "[DEBUG] "
                    echo "cat $file"
                fi
                cat $file
                # Print compiled gforth
                echo "++++++ Compiled gforth"
                debug "cat $tmp_fs"
                cat $tmp_fs
                continue
            fi

            # Compare output to expect
            debug "diff -w $tmp_gforth_output $expect_file"
            diff -w $tmp_gforth_output $expect_file
            # If things fail:
            if [ $? -eq 0 ]
            then
                echo -ne "\033[$FG_PASS\033[$BG  PASS  \033[0m\n";
                TESTS_PASSED=$((TESTS_PASSED+1))
                rm -f $tmp_gforth_output
                rm -f $tmp_fs
                continue #Next test
            fi

            # Print ibtl
            echo "++++++ IBTL file"
            # Print expect
            debug "cat $file"
            cat $file
            echo "++++++ Compiled Gforth code"
            # Print expect
            debug "cat $tmp_fs"
            cat $tmp_fs
            echo "++++++ Expected Result"
            # Print actual
            debug "cat $expect_file"
            cat $expect_file
            echo "++++++ Actual Result"
            debug "cat $tmp_gforth_output"
            cat $tmp_gforth_output
            echo

            rm -f $tmp_gforth_output
            rm -f $tmp_fs
        fi
    done

}
function stats(){
    echo -e "Tests passed: \033[$FG_PASS\033[$BG $TESTS_PASSED  \033[0m";
    echo -e "Tests failed: \033[$FG_FAIL\033[$BG $TESTS_FAILED  \033[0m";
    echo -e "Tests errored: \033[$FG_ERROR\033[$BG $TESTS_ERROR  \033[0m";
}
function usage(){
     echo 'Usage: -a -b'
     echo '-g: good tests'
     echo '-a: all tests'
     echo '-b: bad tests'
}

args=`getopt :dagb $*`
if test $? != 0
then
    usage
    exit 1
fi

for arg in $args
do
    case $arg in
        '-d')
            DEBUG=1
            ;;
    esac
done

for arg in $args
do
    case $arg in
        '-g')
            good_programs
            stats
            ;;
        '-b')
            bad_programs
            stats
            ;;
        '-a')
            good_programs
            bad_programs
            stats
            ;;
        *)
            ;;
    esac
done

exit
