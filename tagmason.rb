#!/usr/bin/env ruby

require "nokogiri"
require "toml"
require "pathname"
require "fileutils"

class Pathname
  def convert(out_file, template, filters, args)
    command = [
      "pandoc", *args,
      "--template", template,
      *filters,
      "-i", self.to_path,
      "-o", out_file.to_path,
    ]
    IO.popen command
  end

  def hidden?()
    self.basename.to_path.start_with? "."
  end
end

# Recursively explore directory looking for files
def handle_directory(dir, root)
  dir.each_child do |file|
    next if file.hidden?

    if file.directory?
      handle_directory file, root
    elsif file.file?
      handle_file file, root
    end
  end
end

# Add tags to a page using its metadata
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

# Create link from page to tag index
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

# Create link from tag index to page
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
config["filters"] = (config["tagmason"]["filters"].map do |f| ["--lua-filter",  f] end).flatten
root = (Pathname.new config["tagmason"]["root"]).expand_path

tags_dir = root + (Pathname.new "tags")
FileUtils.rm_rf tags_dir if tags_dir.exist?
tags_dir.mkdir

handle_directory root, root

# Improve tag index pages
tags_dir.each_child do |file|
  tags = file.read
  title = file.basename.sub_ext ""
  file.write "<h1>##{title}</h1>" + "<ul>#{tags}</ul>"
  file.convert file, config["template"], config["filters"], ["--from", "html+raw_html"] + ["--to", "html+raw_html"]
end