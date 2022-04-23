#!/usr/bin/env ruby

require "nokogiri"
require "toml"
require "pathname"
require "fileutils"

def handle_directory(dir, root)
  dir.each_child do |file|
    next if file.basename.to_path.start_with? "."

    if file.directory?
      handle_directory file, root
    elsif file.file?
      handle_file file, root
    end
  end
end

def handle_file(file, root)
  return if file.extname != ".html"
  html = File.open file do |f| Nokogiri::HTML f end

  tags = html.at "#tags"
  return unless tags

  keywords = (html.at "meta[name='keywords']")["content"].split ", "

  keywords.each do |keyword|
    node = create_tag keyword
    tags << node

    tags_file = (root + (Pathname.new "tags") + (Pathname.new keyword)).sub_ext ".html"
    link_page tags_file, (file.relative_path_from root)
  end

  file.write html.to_s
end

def create_tag(tag)
  node = Nokogiri::HTML.fragment ""
  Nokogiri::HTML::Builder.with(node) do
    li {
      a(:href => "/tags/#{tag}.html") {
        text tag
      }
    }
  end

  Nokogiri::HTML.fragment node.to_html
end

def link_page(tags_file, page_file)
  node = Nokogiri::HTML.fragment ""
  Nokogiri::HTML::Builder.with(node) do
    li {
      a(:href => "/#{page_file}") {
        text "#{page_file.parent}/#{page_file.basename}"
      }
    }
  end

  tags_file.write node.to_s, mode: "a"
end

config = TOML.load_file "config.toml"
config["filters"] = (config["filters"].map do |f| ["--lua-filter",  f] end).flatten
root = (Pathname.new config["tagmason"]["root"]).expand_path

tags_dir = root + (Pathname.new "tags")
FileUtils.rm_rf tags_dir if tags_dir.exist?
tags_dir.mkdir

handle_directory root, root

tags_dir.each_child do |file|
  title = file.basename.sub_ext ""

  data = file.read
  file.write "<h1>##{title}</h1>" + "<ul>#{data}</ul>"

  IO.popen([
    "pandoc",
    "--template", config["template"],
    *config["filters"],
    "-f", "html+raw_html",
    "-t", "html+raw_html",
    "-i", file.to_path,
    "-o", file.to_path,
  ])
end