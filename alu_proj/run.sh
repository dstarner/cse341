#!/usr/bin/env bash

iverilog -t vvp alu_unit_temporal.v
vvp a.out > output.txt
python3 average.py output.txt
rm output.txt
