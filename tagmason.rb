#!/usr/bin/env ruby

require "nokogiri"
require "toml"
require "pathname"
require "fileutils"

def handle_directory(dir, root)
  dir.each_child do |file|
    next if file.basename.to_s.start_with? "."

    if file.directory?
      handle_directory file, root
    elsif file.file?
      handle_file file, root
    end
  end
end

def handle_file(file, root)
    return if file.extname != ".html"
    html = File.open file, "r" do |f| Nokogiri::HTML f end

    tags = html.at "#tags"
    return if not tags

    keywords = (html.at "meta[name='keywords']")["content"].split ", "

    keywords.each do |keyword|
      node = Nokogiri::HTML.fragment ""
      Nokogiri::HTML::Builder.with(node) do
        li {
          a(:href => "/tags/#{keyword}.html") {
            text keyword
          }
        }
      end
      node = Nokogiri::HTML.fragment node.to_xml

      tags << node

      tags_file = (root + (Pathname.new "tags") + (Pathname.new keyword)).sub_ext ".html"
      content = "<a href='/#{file.relative_path_from root}'>#{file.basename}</a><br>"
      tags_file.write content, mode: "a"
    end

    file.write html.to_xml
end

config = TOML.load_file "config.toml"
root = (Pathname.new config["tagmason"]["root"]).expand_path

tags_dir = root + (Pathname.new "tags")
FileUtils.rm_rf tags_dir unless not tags_dir.exist?
Dir.mkdir tags_dir

handle_directory root, root