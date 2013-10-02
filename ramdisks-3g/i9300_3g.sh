#!/bin/bash

find . -name "*smdk4x12*" | while read file; do mv -f "$file" "$(echo $file | sed s/smdk4x12/SHW-M440S/g)"; done
find . -name "*rc*" | while read file; do sed -i -e s/smdk4x12/SHW-M440S/g $file ; done
find . -name "init" | while read file; do sed -i s/smdk4x12/SHW-M440S/g $file ; done
