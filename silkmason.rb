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
    puts out_file

    args = config["pandoc_args"].split " "
    puts out_file
    fork do exec("pandoc", *args, "-i", in_file.to_s, "-o", out_file.to_s) end
  when ".html"
    out_file = (Pathname.new out_dir + in_file.basename).sub_ext(".html")
    puts out_file

    args = config["pandoc_args"].split " "
    puts out_file
    fork do exec("pandoc", *args, "-i", in_file.to_s, "-o", out_file.to_s) end

    #`pandoc -i in_file -o temp.html`
    #replace_file_contents out_file, Pathname.new("temp.html"), in_file
    #File.delete "temp.html"
  else
    out_file = Pathname.new out_dir + in_file.basename
    puts out_file

    FileUtils.cp in_file, out_file
  end
end

def replace_file_contents(target_path, from_path, to_path)
  target_text = target_path.read

  from_text = File.read from_path
  to_text = File.read to_path

  target_text = target_file.read target_path
  target_text = target_text.gsub! from_text, to_text
  File.open(target_path, "w") do |f| f.puts(target_text) end
end

config = TOML.load_file "config.toml"
config["input_dir"] = Pathname.new(if ARGV.length >= 2 then ARGV[1] else config["input_dir"] end).expand_path
config["output_dir"] = Pathname.new(if ARGV.length >= 3 then ARGV[2] else config["output_dir"] end).expand_path

handle_directory config["input_dir"], config["output_dir"], config