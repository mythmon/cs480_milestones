#!/bin/bash

FILES="./test_grammars/good_expr/*"
ruby=/usr/bin/ruby19
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

echo "**************** Malformed Expressions ****************"
FILES="./test_grammars/bad_expr/*"
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
