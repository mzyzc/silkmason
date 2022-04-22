#!/usr/bin/env ruby

require "nokogiri"
require "toml"
require "pathname"

def create_entry(path, root, domain)
  entry_path = root + path
  
  exceptions = ["index.html"]
  return if (not entry_path.file?) or (entry_path.extname != ".html") or (exceptions.include? entry_path.basename.to_s)
  
  html = File.open entry_path, "r" do |f| Nokogiri::HTML f end
  title = (html.at "h1").content rescue nil
  summary = (html.at "main").at "p" rescue nil
  pub_date = html.at "meta[name='dcterms.date']" rescue nil
  
  node = Nokogiri::XML.fragment ""
  Nokogiri::XML::Builder.with(node) do
    entry {
      id_ (Pathname.new domain) + path
      title title
      link("href" => "https://#{domain}/#{path}")
      summary summary.content if summary
      published pub_date["content"] if pub_date
    }
  end
  
  return Nokogiri::XML.fragment node.to_xml
end

def create_feed(path, root, domain, author)
  html = File.open (root + path + "index.html"), "r" do |f| Nokogiri::HTML f end
  title = (html.at "title").content
  
  doc = Nokogiri::XML::Builder.new(:encoding => "utf-8") do
    feed("xmlns" => "http://www.w3.org/2005/Atom") {
      id_ ((Pathname.new domain) + path)
      title title
      author author
      link("href" => "https://#{domain}/#{path}/feed.xml")
    }
  end
  doc = Nokogiri::XML doc.to_xml
  
  feed = doc.at "feed"
  (root + path).each_child do |entry_file|
    next if (entry_file.extname != ".html") or (entry_file.basename == "index.html")
    
    entry = create_entry (entry_file.relative_path_from root), root, domain
    (feed << entry) if entry
  end
  
  return doc
end

def combine_feeds(paths, root, domain, author)
  doc = Nokogiri::XML::Builder.new(:encoding => "utf-8") do
    feed("xmlns" => "http://www.w3.org/2005/Atom") {
      id_ domain
      title domain
      author author
      link("href" => "https://#{domain}/feed.xml")
    }
  end
  doc = Nokogiri::XML doc.to_xml
  
  feed = doc.at "feed"
  paths.each do |path|
    feeds = File.open (root + path + "feed.xml"), "r" do |f| Nokogiri::XML f end
    (feeds.search "entry").each do |entry|
      feed << entry
    end if feeds.at "entry"
  end
  
  return doc
end

config = TOML.load_file "config.toml"
domain = config["feedmason"]["domain"]
author = config["feedmason"]["author"]
root = (Pathname.new config["feedmason"]["root"]).expand_path
feeds = config["feedmason"]["feeds"].map do |f| (Pathname.new f) end
  
  # Generate individual feeds
  feeds.each do |feed_path|
    path = root + feed_path + "feed.xml"
    feed = create_feed feed_path, root, domain, author
    File.write path, feed.to_s
  end
  
  # Generate combined feed
  combined_path = root + "feed.xml"
  combined_feed = combine_feeds feeds, root, domain, author
  File.write combined_path, combined_feed.to_xml