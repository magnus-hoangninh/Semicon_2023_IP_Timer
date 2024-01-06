TNAME        ?=

all: build run

build:
	mkdir -p log
	mkdir -p wave	
	vlib work	
	vmap work work	
	vlog -f compile.f

run:	
	vsim -l $(TESTNAME).log -voptargs=+acc work.$(TESTNAME) -do "log -r /*;run -all; exit"	
	mv $(TESTNAME).log ./log
	cp -rf vsim.wlf wave/$(TESTNAME).wlf
	ln -sf ./log/$(TESTNAME).log sim.log

clean:
	rm -rf work
	rm -rf log
	rm -rf wave
	rm -rf *.ini
	rm -rf *.log
	rm -rf *.wlf
	rm -rf transcript
dump:
	vsim -gui work.${TESTNAME}
