#!/usr/bin/env python3

"""Converts a collection of files into a static website"""

import os
import subprocess
import asyncio
from pathlib import Path
from sys import argv
from shutil import copy

import toml

async def handle_directory(in_dir, out_dir, config):
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
            await handle_directory(in_file, out_file, config)
        elif in_file.is_file():
            await handle_file(in_file, out_dir, config)

async def handle_file(in_file, out_dir, config):
    """Handle files based on their extension"""
    suffix = in_file.suffix.lower()

    if suffix == '.md':
        out_file = Path(out_dir, in_file.name).with_suffix('.html')
        args = config['pandoc_args'].split(' ')
        subprocess.run(['pandoc', *args, '-i', in_file, '-o', out_file])
    elif suffix == '.html':
        out_file = Path(out_dir, in_file.name).with_suffix('.html')
        args = config['pandoc_args'].split(' ')
        subprocess.run(['pandoc', *args, '-i', in_file, '-o', out_file])

        subprocess.run(['pandoc', '-i', in_file, '-o', 'temp.html'])
        replace_file_contents(out_file, 'temp.html', in_file)
        os.remove('temp.html')
    else:
        out_file = Path(out_dir, in_file.name)
        copy(in_file, out_file)

    print(out_file)

def replace_file_contents(target_path, from_path, to_path):
    """Replaces contents of 'from' file with contents of 'to' file inside 'target' file."""
    with open(target_path, 'r+') as target_file:
        target_text = target_file.read()

        with open(from_path, 'r') as from_file:
            from_text = from_file.read()

        with open(to_path, 'r') as to_file:
            to_text = to_file.read()

        target_file.seek(0)
        target_text = target_text.replace(from_text, to_text)
        target_file.write(target_text)
        target_file.truncate()


# Load config and override some settings with command-line arguments
config = toml.load('config.toml')
config['input_dir'] = Path(argv[1] if len(argv) >= 2 else config['input_dir']).expanduser()
config['output_dir'] = Path(argv[2] if len(argv) >= 3 else config['output_dir']).expanduser()

asyncio.run(handle_directory(config['input_dir'], config['output_dir'], config))
