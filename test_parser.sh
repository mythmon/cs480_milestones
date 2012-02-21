#!/bin/bash

FILES="./test_grammars/*"
ruby=/usr/bin/ruby19
for file in $FILES
do
    echo "=============================================="
    echo "------- Testing [ "$(cat $file)" ]"
    $ruby ./parser.rb $file
    echo
    echo
done
