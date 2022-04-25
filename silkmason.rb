#!/usr/bin/env ruby

require "fileutils"
require "toml"
require "pathname"

class Pathname
  def hidden?() self.basename.to_path.start_with? "." end
end

def convert(in_file, out_file, template, filters, args, from=nil, to=nil)
  command = [
    "pandoc", *args,
    "--template", template,
    *filters,
    "-i", in_file.to_path,
    "-o", out_file.to_path,
  ]
  command += ["-f", from[:from]] if from
  command += ["-t", to[:to]] if to
  IO.popen command
end

# Recursively explore directory looking for files
def handle_directory(in_dir, out_dir, config)
  in_dir.each_child do |in_file|
    next if in_file.hidden?

    if in_file.directory?
      out_file = Pathname.new out_dir + in_file.basename
      out_file.mkdir unless out_file.exist?
      handle_directory in_file, out_file, config
    elsif in_file.file?
      handle_file in_file, out_dir, config
    end
  end
end

# Convert a file to an appropriate format based on extension
def handle_file(in_file, out_dir, config)
  case in_file.extname
  when ".md"
    out_file = (Pathname.new out_dir + in_file.basename).sub_ext ".html"
    convert in_file, out_file, config["template"], config["filters"], config["pandoc_args"]
  when ".html"
    out_file = (Pathname.new out_dir + in_file.basename).sub_ext ".html"
    convert in_file, out_file, config["template"], config["filters"], config["pandoc_args"], to: "html+raw_html", from: "html+raw_html"
  else
    out_file = Pathname.new out_dir + in_file.basename
    FileUtils.cp in_file, out_file
  end

  puts out_file
end

config = TOML.load_file "config.toml"
config["input_dir"] = Pathname.new(if ARGV.length >= 2 then ARGV[1] else config["input_dir"] end).expand_path
config["output_dir"] = Pathname.new(if ARGV.length >= 3 then ARGV[2] else config["output_dir"] end).expand_path
config["filters"] = (config["filters"].map do |f| ["--lua-filter",  f] end).flatten

handle_directory config["input_dir"], config["output_dir"], config
