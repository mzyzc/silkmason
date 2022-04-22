#!/usr/bin/env ruby

require "fileutils"
require "toml"
require "pathname"

def handle_directory(in_dir, out_dir, config)
  in_dir.each_child do |in_file|
    next if in_file.basename.to_s.start_with? "."

    if in_file.directory?
      out_file = Pathname.new out_dir + in_file.relative_path_from(in_dir)
      Dir.mkdir out_file unless out_file.exist?
      handle_directory in_file, out_file, config
    elsif in_file.file?
      handle_file in_file, out_dir, config
    end
  end
end

def handle_file(in_file, out_dir, config)
  case in_file.extname
  when ".md"
    out_file = (Pathname.new out_dir + in_file.basename).sub_ext(".html")
    args = config["pandoc_args"].split " "
    IO.popen(["pandoc", *args, "-i", in_file.to_s, "-o", out_file.to_s])
  when ".html"
    out_file = (Pathname.new out_dir + in_file.basename).sub_ext(".html")
    args = config["pandoc_args"].split " "
    IO.popen(["pandoc", *args, "-f", "html+raw_html", "-t", "html+raw_html", "-i", in_file.to_s, "-o", out_file.to_s])
  else
    out_file = Pathname.new out_dir + in_file.basename
    FileUtils.cp in_file, out_file
  end

    puts out_file
end

config = TOML.load_file "config.toml"
config["input_dir"] = Pathname.new(if ARGV.length >= 2 then ARGV[1] else config["input_dir"] end).expand_path
config["output_dir"] = Pathname.new(if ARGV.length >= 3 then ARGV[2] else config["output_dir"] end).expand_path

handle_directory config["input_dir"], config["output_dir"], config