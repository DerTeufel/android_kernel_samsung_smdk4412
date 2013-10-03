#!/bin/bash

find -name '*.rej' -exec rm -rf {} \;
find -name '*.orig' -exec rm -rf {} \;
rm -f ./orig
rm -f ./rej
rm -f ./patch-3.0.*
