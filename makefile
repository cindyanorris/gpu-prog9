NVCC = /usr/local/cuda-8.0/bin/nvcc
CC = g++
GENCODE_FLAGS = -arch=sm_30
CC_FLAGS = -c 
#NVCCFLAGS = -m64 -O2 -Xptxas -v
#uncomment NVCCFLAGS below and comment out above, if you want to use cuda-gdb
NVCCFLAGS = -g -G -m64
OBJS = wrappers.o scan.o h_scan.o d_scan.o
.SUFFIXES: .cu .o .h 
.cu.o:
	$(NVCC) $(CC_FLAGS) $(NVCCFLAGS) $(GENCODE_FLAGS) $< -o $@

scan: $(OBJS)
	$(CC) $(OBJS) -L/usr/local/cuda/lib64 -lcuda -lcudart -o scan

scan.o: scan.cu h_scan.h d_scan.h config.h

h_scan.o: h_scan.cu h_scan.h CHECK.h

d_scan.o: d_scan.cu d_scan.h CHECK.h config.h

wrappers.o: wrappers.cu wrappers.h

clean:
	rm scan *.o
