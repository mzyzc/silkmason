#!/usr/bin/env python3

"""Converts a collection of files into a static website"""

from multiprocessing import Process
from os import system
from pathlib import Path
from sys import argv
from shutil import copy

import toml

def handle_directory(in_dir, out_dir, config):
    """Explore a directory recursively to look for files"""
    for in_file in in_dir.iterdir():
        # Ignore hidden files
        if in_file.name[0] == '.':
            continue

        if in_file.is_dir():
            # Create empty directory in the output location
            out_file = Path(out_dir, in_file.relative_to(in_dir))
            out_file.mkdir(exist_ok=True)

            # Explore further directories recursively
            process = Process(target=handle_directory, args=(in_file, out_file, config))
            process.start()
        elif in_file.is_file():
            handle_file(in_file, out_dir, config)

def handle_file(in_file, out_dir, config):
    """Handle files based on their extension"""
    suffix = in_file.suffix.lower()

    if suffix == '.md':
        out_file = Path(out_dir, in_file.name).with_suffix('.html')
        args = config['pandoc_args']
        system(f'pandoc {args} -i {in_file} -o {out_file}')
    else:
        out_file = Path(out_dir, in_file.name)
        copy(in_file, out_file)

    print(out_file)


# Load config and override some settings with command-line arguments
config = toml.load('config.toml')
config['input_dir'] = Path(argv[1] if len(argv) >= 2 else config['input_dir']).expanduser()
config['output_dir'] = Path(argv[2] if len(argv) >= 3 else config['output_dir']).expanduser()

handle_directory(config['input_dir'], config['output_dir'], config)
