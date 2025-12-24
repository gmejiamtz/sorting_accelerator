database -open waves -shm -default

probe -create -all -depth all -shm

probe -create -unpacked 4194304 sdram_tb.uut.Bank0
probe -create -unpacked 4194304 sdram_tb.uut.Bank1
probe -create -unpacked 4194304 sdram_tb.uut.Bank2
probe -create -unpacked 4194304 sdram_tb.uut.Bank3

run

database -close waves

