# See, https://www.tinytapeout.com/guides/local-hardening/
export PDK_ROOT=$(HOME)/projects/ASIC/ttsetup/pdk
export PDK=sky130A
export OPENLANE2_TAG=2.1.7

all:
	. ../ttsetup/venv/bin/activate; tt/tt_tool.py --harden --create-png --openlane2
