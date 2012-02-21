#!/bin/bash

FILES="./test_grammars/*"
for file in $FILES
do
    echo "===== Testing [ "$(cat $file)" ]"
    cat $file | 
done
