# SilkMason

A very simple static site generator based on pandoc

## Usage

`./silkmason.py $INPUTDIR $OUTPUTDIR`

Pandoc arguments can be provided via the `pandoc_args` option in the configuration file.

### FeedMason

FeedMason is an auxiliary script that generates Atom feeds for an existing website. It requires a configuration file with the following options set:

- `domain` (domain of the website)
- `author` (author of the website)
- `root` (the directory where the website files are located)
- `feeds` (a list of locations, relative to the root, for which feeds should be generated)

## Dependencies

- `toml`
- `lxml` (FeedMason)
- `bs4` (FeedMason)
