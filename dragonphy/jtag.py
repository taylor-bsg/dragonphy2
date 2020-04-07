import sys
import os
from subprocess import call
from pathlib import Path
from dragonphy.files import get_file, get_dir

class JTAG:
    def __init__(self,  filename=None, **system_values):
        build_dir = Path(filename).parent

        justag_inputs = []
        justag_inputs += list(get_dir('md/reg').glob('*.md'))
        justag_inputs += [get_file('vlog/old_pack/all/const_pack.sv')]

        # call JusTAG
        self.justag(*justag_inputs, cwd=build_dir)

        # generate JTAG for the chip source

        TOP_NAME='raw_jtag'
        JUSTAG_DIR = os.environ['JUSTAG_DIR']
        PRIM_DIR=f'{JUSTAG_DIR}/rtl/primitives'
        DIGT_DIR=f'{JUSTAG_DIR}/rtl/digital'
        VERF_DIR=f'{JUSTAG_DIR}/verif'

        SVP_FILES = [
            f'{DIGT_DIR}/{TOP_NAME}.svp',
            f'{PRIM_DIR}/cfg_ifc.svp',
            f'{DIGT_DIR}/{TOP_NAME}_ifc.svp',
            f'{PRIM_DIR}/flop.svp',
            f'{DIGT_DIR}/tap.svp',
            f'{DIGT_DIR}/cfg_and_dbg.svp',
            f'{PRIM_DIR}/reg_file.svp'
        ]

        self.genesis(TOP_NAME, *SVP_FILES, cwd=build_dir)

        # generate the JTAG test harness

        self.genesis('JTAGDriver', f'{VERF_DIR}/JTAGDriver.svp', cwd=build_dir)

        # move the package containing register numbers

        old_cpu_models = get_dir('build/old_cpu_models/jtag')
        old_cpu_models.mkdir(exist_ok=True, parents=True)
        (build_dir / 'jtag_reg_pack.sv').replace(old_cpu_models / 'jtag_reg_pack.sv')

        # move the test harness and place inside a package

        old_tb = get_dir('build/old_tb')
        old_tb.mkdir(exist_ok=True, parents=True)
        with open(build_dir / 'genesis_verif' / 'JTAGDriver.sv', 'r') as orig:
            with open(old_tb / 'jtag_drv_pack.sv', 'w') as new:
                new.write('package jtag_drv_pack;\n')
                new.write(orig.read())
                new.write('endpackage\n')

        # move the generated source code for the JTAG implementation

        old_chip_src = get_dir('build/old_chip_src/jtag')
        old_chip_src.mkdir(exist_ok=True, parents=True)
        for file in (build_dir / 'genesis_verif').glob('*.sv'):
            file.replace(old_chip_src / file.name)

        # specify the generated files
        self.generated_files = []
        self.generated_files += [get_file('build/old_tb/jtag_drv_pack.sv')]
        self.generated_files += [get_file('build/old_cpu_models/jtag/jtag_reg_pack.sv')]
        self.generated_files += list(get_dir('build/old_chip_src/jtag').glob('*.sv'))

    @staticmethod
    def justag(*inputs, cwd=None):
        args = []
        args += [sys.executable]
        args += [f'{os.environ["JUSTAG_DIR"]}/JusTAG.py']
        args += list(inputs)
        call(args, cwd=cwd)

    @staticmethod
    def genesis(top, *inputs, cwd=None):
        args = []
        args += ['Genesis2.pl']
        args += ['-parse']
        args += ['-generate']
        args += ['-top', top]
        args += ['-input'] + list(inputs)
        call(args, cwd=cwd)

    @staticmethod
    def required_values():
        return []