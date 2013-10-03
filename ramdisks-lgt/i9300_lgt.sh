#!/bin/bash
find . -name "*smdk4x12*" | while read file; do mv -f "$file" "$(echo $file | sed s/smdk4x12/SHV-E210L/g)"; done
find . -name "*rc*" | while read file; do sed -i s/smdk4x12/SHV-E210L/g $file ; done

find . -name "*rc*" | while read file; do sed -i -e s/mmcblk0p12/mmcblk0p13/g -e s/mmcblk0p11/mmcblk0p12/g -e s/mmcblk0p10/mmcblk0p11/g -e s/mmcblk0p9/mmcblk0p10/g -e s/mmcblk0p8/mmcblk0p9/g $file ; done
find . -name "*fstab*" | while read file; do sed -i -e s/mmcblk0p12/mmcblk0p13/g -e s/mmcblk0p11/mmcblk0p12/g -e s/mmcblk0p10/mmcblk0p11/g -e s/mmcblk0p9/mmcblk0p10/g -e s/mmcblk0p8/mmcblk0p9/g $file ; done

find . -name "init" | while read file; do sed -i s/smdk4x12/SHV-E210L/g $file ; done
find . -name "*init" | while read file; do sed -i -e s/mmcblk0p12/mmcblk0p13/g -e s/mmcblk0p11/mmcblk0p12/g -e s/mmcblk0p10/mmcblk0p11/g -e s/mmcblk0p9/mmcblk0p10/g -e s/mmcblk0p8/mmcblk0p9/g $file ; done
