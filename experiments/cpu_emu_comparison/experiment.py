#!/usr/bin/env python3

# general imports
import pickle
from argparse import ArgumentParser
from pathlib import Path

# DragonPHY-specific
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

parser = ArgumentParser()
parser.add_argument('--fast_jtag', action='store_true', help='Use hierarchical I/O rather than true JTAG commands for reading and writing registers.  Useful for test development.')
parser.add_argument('--dump_waveforms', action='store_true', help='Dump waveforms for debugging purposes.  Useful for debugging, but should be disabled when gathering experimental data.')
parser.add_argument('--jitter_rms', default=0, type=float, help='RMS sampling jitter (seconds)')
parser.add_argument('--noise_rms', default=0, type=float, help='RMS ADC noise (Volts)')
parser.add_argument('--nbits', default=600000, type=int, help='Number of bits run through link during testing.')
parser.add_argument('--cached_deps', action='store_true', help='Read dependencies that were cached in a file (creating the cache file if necessary).')
args = parser.parse_args()

# read dependencies from a pickle file if desired
deps = None
if args.cached_deps:
    try:
        with open('deps.pickle', 'rb') as f:
            deps = pickle.load(f)
    except:
        print('Failed to load dependencies from file.')

# determine the dependencies from scratch if necessary
if deps is None:
    deps = get_deps_cpu_sim(
        impl_file=THIS_DIR / 'test.sv',
        override={
            'snh': THIS_DIR / 'snh.sv',
            'V2T_clock_gen_S2D': THIS_DIR / 'V2T_clock_gen_S2D.sv',
            'stochastic_adc_PR': THIS_DIR / 'stochastic_adc_PR.sv',
            'phase_interpolator': THIS_DIR / 'phase_interpolator.sv',
            'input_divider': THIS_DIR / 'input_divider.sv',
            'output_buffer': THIS_DIR / 'output_buffer.sv',
            'mdll_r1_top': 'chip_stubs'
        }
    )

# pickle dependencies for future use
with open('deps.pickle', 'wb') as f:
    pickle.dump(deps, f)

defines = {
    'JITTER_RMS': args.jitter_rms,
    'NOISE_RMS': args.noise_rms,
    'NBITS': args.nbits
}
if args.fast_jtag:
    defines['FAST_JTAG'] = True

DragonTester(
    ext_srcs=deps,
    directory=BUILD_DIR,
    defines=defines,
    dump_waveforms=args.dump_waveforms
).run()
