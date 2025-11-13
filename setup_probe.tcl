database -open waves -shm -default

probe -create -all -depth all -shm

probe -create -unpacked 4194304 sdram_tb.dut.Bank0
probe -create -unpacked 4194304 sdram_tb.dut.Bank1
probe -create -unpacked 4194304 sdram_tb.dut.Bank2
probe -create -unpacked 4194304 sdram_tb.dut.Bank3

run

database -close waves

