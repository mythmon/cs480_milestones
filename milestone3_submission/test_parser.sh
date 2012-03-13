#!/bin/bash

ruby=/usr/bin/ruby19

function test_good(){
echo "**************** Valid Expressions ****************"
FILES="./*.good"
for file in $FILES
do
    if [ -f $file ]
    then
        echo "=============================================="
        echo "------- Testing [ "$(cat $file)" ]"
        $ruby ./parser.rb $file
        echo
        echo
    fi
done

}

function test_bad(){
echo "**************** Malformed Expressions ****************"
FILES="./*.bad"
for file in $FILES
do
    if [ -f $file ]
    then
        echo "=============================================="
        echo "------- Testing [ "$(cat $file)" ]"
        $ruby ./parser.rb $file
        echo
        echo
    fi
done
}

args=`getopt agb:d $*`
if test $? != 0
     then
         echo 'Usage: -a -g -b'
         echo '-a: all tests'
         echo '-g: good tests (correct expressions)'
         echo '-b: bad tests (invalid expressions)'
         exit 1
fi

for arg in $args
do
    case $arg in
        '-a')
            test_good
            test_bad
            ;;
        '-g')
            test_good
            ;;
        '--good')
            test_good
            ;;
        '-b')
            test_bad
            ;;
        '--bad')
            test_bad
            ;;
        *)
            test_good
            test_bad
            ;;
    esac
done

exit

