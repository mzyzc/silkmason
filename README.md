# SilkMason

A very simple static site generator based on pandoc

FeedMason is an auxiliary script that generates Atom feeds for an existing website. It requires a configuration file with the following options set:

## Usage

SilkMason will look for a `config.toml` file in its directory. A default configuration has been provided, which you can use by copying the example file in this repository:

`cp config-example.toml config.toml`

Once a configuration file exists, you can just run the executable:

`./silkmason.rb`

Source and destination directories can be overridden with command-line arguments:

`./silkmason.rb $INPUTDIR $OUTPUTDIR`

## Configuration

- `input_dir`: [string] the input directory
- `output_dir`: [string] the output directory
- `pandoc_args`: [string] arguments to use when calling Pandoc

- `feedmason.domain`: [string] the domain used to identify the website
- `feedmason.author`: [string] the owner of the website
- `feedmason.root`: [string] the directory where the website is located (usually the same as `output_dir`)
- `feedmason.feeds`: [array<string>] directories, relative to `feedmason.root`, for which feeds should be generated

## Dependencies

- `toml`
- `nokogiri` (FeedMason)
