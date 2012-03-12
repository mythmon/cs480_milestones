#!/bin/bash

ruby=/usr/bin/ruby19
compiler="translator.rb"
gforth="gforth"
tmp_fs="./test_programs/tmp_test.fs" # Temporary output for compiles gforth
tmp_gforth_output="./test_programs/tmp_test.out" # Temporary outpur for results of compiled gforth program
test_dir="./test_programs"
DEBUG=1

function test_programs(){
FILES="./test_programs/*"
for file in $FILES
do
    if [ -f $file ]
    then
        echo "=============================================="
        echo "------- Compiling Testing [ "$(cat $file)" ]"
        if [ $DEBUG -eq 1 ]; then
            echo -n "[DEBUG] "
            echo "\$file: $file"
        fi
        # dirname
        dirname=`dirname "$file"`
        # everything before last '/'
        dirname=${file%/*}
        if [ $DEBUG -eq 1 ]; then
            echo -n "[DEBUG] "
            echo "\$dirname: $dirname"
        fi


        # basename
        basename=`basename "$file"`
        # everything after last '/'
        basename=${file##*/}
        if [ $DEBUG -eq 1 ]; then
            echo -n "[DEBUG] "
            echo "\$basename: $basename"
        fi

        # corename
        corename=$(echo "$basename" | sed 's/\..*//') # (testX) where X is a number
        if [ $DEBUG -eq 1 ]; then
            echo -n "[DEBUG] "
            echo "\$corename: $corename"
        fi

        ext=${file##*.}
        if [ $DEBUG -eq 1 ]; then
            echo -n "[DEBUG] "
            echo "\$ext: $ext"
        fi

        # Let's make sure this an ibtl file.
        if [ $ext != 'ibtl' ]
        then
            if [ $DEBUG -eq 1 ]; then
                echo -n "[DEBUG] "
                echo "Skipping $file"
            fi
            continue # Skip the expect only use the ibtl files.
        fi

        # Construct the ibtl file name
        expect_file=$dirname"/"$corename".expect"
        if [ $DEBUG -eq 1 ]; then
            echo -n "[DEBUG] "
            echo "\$expect_file: $expect_file"
        fi
        # Run the tests
        # ibtl -> gforth
        if [ $DEBUG -eq 1 ]; then
            echo -n "[DEBUG] "
            echo "$ruby $compiler $file > $tmp_fs"
        fi
        $ruby $compiler $file > $tmp_fs
        # gforth $(compiled_file)
        if [ $DEBUG -eq 1 ]; then
            echo -n "[DEBUG] HERE"
            echo "$gforth $tmp_fs > $tmp_gforth_output"
        fi
        $gforth $tmp_fs > $tmp_gforth_output
        # Compare output to expect
        if [ $DEBUG -eq 1 ]; then
            echo -n "[DEBUG] "
            echo "diff -w $tmp_gforth_output $expect_file"
        fi
        diff -w $tmp_gforth_output $expect_file
        # If things fail:
        if [ $? -eq 0 ]
        then
            echo "           [PASS]"
            rm -f $tmp_gforth_output
            rm -f $tmp_fs
            continue #Next test
        fi

        # Print ibtl
        echo "++++++ IBTL file"
        # Print expect
        if [ $DEBUG -eq 1 ]; then
            echo -n "[DEBUG] "
            echo "cat $file"
        fi
        cat $file
        echo "++++++ Compiled Gforth code"
        # Print expect
        if [ $DEBUG -eq 1 ]; then
            echo -n "[DEBUG] "
            echo "cat $tmp_fs"
        fi
        echo "++++++ Expected Result"
        # Print actual
        if [ $DEBUG -eq 1 ]; then
            echo -n "[DEBUG] "
            echo "cat $expect_file"
        fi
        cat $expect_file
        echo "++++++ Actual Result"
        if [ $DEBUG -eq 1 ]; then
            echo -n "[DEBUG] "
            echo "cat $tmp_gforth_output"
        fi
        cat $tmp_gforth_output

        rm -f $tmp_gforth_output
        rm -f $tmp_fs
    fi
done

}

args=`getopt agb:d $*`
if test $? != 0
     then
         echo 'Usage: -a'
         echo '-a: all tests'
         exit 1
fi

for arg in $args
do
    case $arg in
        *)
            test_programs
            ;;
    esac
done

exit

