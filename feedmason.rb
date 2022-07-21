#!/usr/bin/env ruby

require "nokogiri"
require "toml"
require "pathname"

class Pathname
  def hidden?()
    self.basename.to_path.start_with? "."
  end
end

# Create XML node representing an Atom entry
def create_entry(path, root, domain)
  entry_path = root + path
  
  html = entry_path.open do |f| Nokogiri::HTML f end
  title = html.at "h1"
  summary = html.at "main p"
  pub_date = html.at "meta[name='dcterms.date']"

  return unless title

  # Strip 'index.html' for index files
  if path.basename == (Pathname.new "index.html")
    path = path.dirname
  end

  node = Nokogiri::XML.fragment ""
  Nokogiri::XML::Builder.with(node) do
    entry {
      id_ (Pathname.new domain) + path
      title title.content
      link(:href => "https://#{domain}/#{path}")
      category(
        :term => path.dirname,
        :scheme => "https://#{((Pathname.new domain) + path.dirname).to_path}"
      )
      summary summary.content if summary
      updated pub_date["content"] if pub_date
      published pub_date["content"] if pub_date
    }
  end
  
  Nokogiri::XML.fragment node.to_xml
end

# Create Atom feed for a directory of files
def create_feed(path, root, domain, author)
  html = (root + path + "index.html").open do |f| Nokogiri::HTML f end
  title = (html.at "title")
  
  doc = Nokogiri::XML::Builder.new(:encoding => "utf-8") do
    feed(:xmlns => "http://www.w3.org/2005/Atom") {
      id_ ((Pathname.new domain) + path)
      title title.content
      author author
      link(:href => "https://#{domain}/#{path}/feed.xml")
    }
  end
  doc = Nokogiri::XML doc.to_xml
  
  feed = doc.at "feed"
  (root + path).each_child do |entry_file|
    next if entry_file.hidden?

    if entry_file.file?
      next if entry_file.basename.to_path == "index.html"
      next if entry_file.basename.to_path == "feed.xml"
    end

    # Check for index files in directories
    if entry_file.directory?
      entry_file = entry_file + (Pathname.new "index.html")
      next unless entry_file.exist?
    end

    next if entry_file.extname != ".html"

    entry = create_entry (entry_file.relative_path_from root), root, domain
    (feed << entry) if entry
  end
  
  doc
end

# Combine multiple Atom feeds into one
def combine_feeds(paths, root, domain, author)
  doc = Nokogiri::XML::Builder.new(:encoding => "utf-8") do
    feed(:xmlns => "http://www.w3.org/2005/Atom") {
      id_ domain
      title domain
      author author
      link(:href => "https://#{domain}/feed.xml")
    }
  end
  doc = Nokogiri::XML doc.to_xml
  
  feed = doc.at "feed"
  paths.each do |path|
    entries = (root + path + "feed.xml").open do |f| Nokogiri::XML f end
    (entries.search "entry")&.each do |entry|
      feed << entry
    end
  end
  
  doc
end

config = TOML.load_file "config.toml"
domain = config["feedmason"]["domain"]
author = config["feedmason"]["author"]
root = (Pathname.new config["feedmason"]["root"]).expand_path
feeds = config["feedmason"]["feeds"].map do |f| (Pathname.new f) end

# Generate individual feeds
feeds.each do |feed_path|
  feed = create_feed feed_path, root, domain, author
  (root + feed_path + "feed.xml").write feed.to_s
end

# Generate combined feed
combined_feed = combine_feeds feeds, root, domain, author
(root + "feed.xml").write combined_feed.to_s
