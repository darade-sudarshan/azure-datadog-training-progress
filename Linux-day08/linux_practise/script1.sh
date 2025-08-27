#!/bin/bash

mkdir linux_practise/magic 
cd linux_practise/magic
touch file{1..100}
ls -lh  > magic.log
cd ..
rm -rf magic
