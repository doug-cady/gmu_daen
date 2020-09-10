#!/bin/bash
# my fizzbuzz implementation in bash

for i in {1..100}
do
	if [ $(($i % 15)) -eq 0 ];
	then echo "fizzbuzz"

	elif [ $(($i % 5)) -eq 0 ];
	then echo "buzz"

	elif [ $(($i % 3)) -eq 0 ];
	then echo "fizz"

	else echo $i
	fi
done
