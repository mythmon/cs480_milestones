#!/bin/bash

ruby=/usr/bin/ruby19
compiler="translator.rb"
gforth="gforth"
tmp_fs="./test_programs/tmp_test.fs" # Temporary output for compiles gforth
tmp_gforth_output="./test_programs/tmp_test.out" # Temporary outpur for results of compiled gforth program
test_dir="./test_programs"
DEBUG=0

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

        ext=${file##*.}
        if [ $DEBUG -eq 1 ]; then
            echo -n "[DEBUG] "
            echo "\$ext: $ext"
        fi
        echo -n "--> Compiling Testing [ "$basename" ] |||| [ "$(cat $file)" ]"

        if [ "$ext" != 'ibtl' ]
        then
            if [ $DEBUG -eq 1 ]; then
                echo
                echo -n "[DEBUG] "
                echo "Skipping $file"
            fi
            continue # Skip the expect only use the ibtl files.
        fi
        # Test compiler. Should report error
        if [ $DEBUG -eq 1 ]; then
            echo -n "[DEBUG] "
            echo "$ruby $compiler $file > $tmp_fs"
        fi
        $ruby $compiler $file > $tmp_fs
        if [ $? -ne 1 ]; then
            echo
            echo "        [FAIL] $file reported a success return value"
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
            echo "        [PASS]"
        fi
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


            # Construct the ibtl file name
            expect_file=$dirname"/"$corename".expect"
            if [ $DEBUG -eq 1 ]; then
                echo -n "[DEBUG] "
                echo "\$expect_file: $expect_file"
            fi

            if [ "$ext" != 'ibtl' ]
            then
                if [ $DEBUG -eq 1 ]; then
                    echo -n "[DEBUG] "
                    echo "Skipping $file"
                fi
                continue # Skip the expect only use the ibtl files.
            fi
            # Let's make sure this an ibtl file.
            echo -n "--> Compiling Testing [ "$basename" ] |||| [ "$(cat $file)" ]"
            if [ $DEBUG -eq 1 ]; then
                echo
                echo -n "[DEBUG] "
                echo "\$file: $file"
            fi
            # Run the tests
            # ibtl -> gforth
            if [ $DEBUG -eq 1 ]; then
                echo -n "[DEBUG] "
                echo "$ruby $compiler $file > $tmp_fs"
            fi
            $ruby $compiler $file > $tmp_fs

            if [ $? -eq 1 ]; then
                echo
                echo "        [FAIL] $file did not compile"
                # Print ibtl
                echo "++++++ IBTL file"
                if [ $DEBUG -eq 1 ]; then
                    echo -n "[DEBUG] "
                    echo "cat $tmp_fs"
                fi
                cat $tmp_fs
                # Print expect
                if [ $DEBUG -eq 1 ]; then
                    echo -n "[DEBUG] "
                    echo "cat $file"
                fi
                cat $file
                rm -f $tmp_gforth_output
                rm -f $tmp_fs
                continue
            fi
            if [ $DEBUG -eq 1 ]; then
                echo "[DEBUG] Program succesfully compiled"
            fi

            # gforth $(compiled_file)
            if [ $DEBUG -eq 1 ]; then
                echo -n "[DEBUG] "
                echo "$gforth $tmp_fs > $tmp_gforth_output"
            fi
            $gforth $tmp_fs > $tmp_gforth_output
            if [ $? -eq 1 ]; then
                echo
                echo "        [FAIL] $file crashed gforth"
                # Print ibtl
                echo "++++++ IBTL file"
                if [ $DEBUG -eq 1 ]; then
                    echo -n "[DEBUG] "
                    echo "cat $tmp_fs"
                fi
                cat $tmp_fs
                # Print expect
                if [ $DEBUG -eq 1 ]; then
                    echo -n "[DEBUG] "
                    echo "cat $file"
                fi
                cat $file
                continue
            fi

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
            cat $tmp_fs
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
            echo

            rm -f $tmp_gforth_output
            rm -f $tmp_fs
        fi
    done

}
function usage(){
     echo 'Usage: -a -b'
     echo '-g: good tests'
     echo '-a: all tests'
     echo '-b: bad tests'
}

args=`getopt :agb $*`
if test $? != 0
then
    usage
    exit 1
fi

for arg in $args
do
    case $arg in
        '-g')
            good_programs
            ;;
        '-b')
            bad_programs
            ;;
        '-a')
            good_programs
            bad_programs
            ;;
        *)
            ;;
    esac
done

exit
