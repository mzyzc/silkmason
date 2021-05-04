#!/usr/bin/env python3

from multiprocessing import Process
from os import system
from pathlib import Path
from sys import argv
from shutil import copy

def handle_directory(in_dir, out_dir):
    """Explore a directory for files to convert"""
    for in_file in in_dir.iterdir():
        # Ignore hidden files
        if in_file.name[0] == '.':
            return

        if in_file.is_dir():
            out_file = Path(out_dir, in_file.relative_to(in_dir))
            out_file.mkdir(exist_ok=True)
            # Explore further directories recursively
            process = Process(target=handle_directory, args=(in_file, out_file))
            process.start()
        elif in_file.is_file():
            handle_file(in_file, out_dir)

def handle_file(in_file, out_dir):
    suffix = in_file.suffix.lower()

    if suffix == '.md':
        out_file = Path(out_dir, in_file.name).with_suffix('.html')
        system(f'pandoc -i {in_file} -o {out_file}')
    else:
        out_file = Path(out_dir, in_file.name)
        copy(in_file, out_file)

    print(out_file)


in_dir = Path(argv[1])
out_dir = Path(argv[2])

handle_directory(in_dir, out_dir)
