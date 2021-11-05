#!/usr/bin/env python3

"""Generates Atom feeds for a static website"""

from bs4 import BeautifulSoup
from pathlib import Path
import lxml
import toml

def add_tag(node, label, data, attributes):
    """Create a new XML tag"""
    soup = BeautifulSoup(features='xml')
    tag = soup.new_tag(label)

    if data:
        tag.string = str(data)

    for attr in attributes.keys():
        tag[attr] = attributes[attr]

    node.append(tag)

def create_entry(path, root, domain):
    """Create an entry for an Atom feed"""
    soup = BeautifulSoup(features='xml')
    entry = root / path

    if (not entry.is_file()) or entry.name == 'feed.xml':
        return

    with open(entry, 'r') as entry_file:
        html = BeautifulSoup(entry_file, 'html.parser')
        title = html.find('h1').string
        summary = html.find('p')

        published_date = html.find('meta', attrs={'name': 'dcterms.date'})

    node = soup.new_tag('entry')
    add_tag(node, 'id', domain/path, {})
    add_tag(node, 'title', title, {})
    add_tag(node, 'link', '', {'href': f'https://{domain/path}'})

    if summary:
        add_tag(node, 'summary', summary.text, {})
    if published_date:
        add_tag(node, 'published', published_date['content'], {})

    return node

def create_feed(path, root, domain, author):
    """Create an Atom feed"""
    soup = BeautifulSoup(features='xml')

    with open(f'{root/path}/index.html', 'r') as page_file:
        html = BeautifulSoup(page_file, 'html.parser')
        title = html.title.string

    add_tag(soup, 'feed', '', {'xmlns': 'http://www.w3.org/2005/Atom'})
    add_tag(soup.feed, 'id', domain/path, {})
    add_tag(soup.feed, 'title', title, {})
    add_tag(soup.feed, 'author', author, {})
    add_tag(soup.feed, 'link', '', {'href': f'https://{domain/path}/feed.xml'})

    for entry_file in (root/path).iterdir():
        if entry_file.name == 'index.html':
            continue

        entry = create_entry(entry_file.relative_to(root), root, domain)
        if entry:
            soup.feed.append(entry)

    return soup

def combine_feeds(paths, root, domain, author):
    """Combine multiple Atom feeds into one"""
    soup = BeautifulSoup(features='xml')

    add_tag(soup, 'feed', '', {'xmlns': 'http://www.w3.org/2005/Atom'})
    add_tag(soup.feed, 'id', domain, {})
    add_tag(soup.feed, 'title', domain, {})
    add_tag(soup.feed, 'author', author, {})
    add_tag(soup.feed, 'link', '', {'href': f'https://{domain}/feed.xml'})

    for path in paths:
        with open(root/path/'feed.xml', 'r') as feed:
            xml = BeautifulSoup(feed.read(), 'lxml')
            for entry in xml.find_all('entry'):
                soup.feed.append(entry)

    return soup

def add_link(root, path):
    index_path = root/path/'index.html'

    with open(index_path, 'r') as index_file:
        html = BeautifulSoup(index_file, 'lxml')

    link = html.new_tag('a', href='feed.xml')
    link_image = html.new_tag('img', src='/assets/feed.svg', alt='Web feed')
    link.insert(0, link_image)

    heading = html.h1
    heading.insert(1, link)

    with open(index_path, 'w') as index_file:
        html = str(html)
        index_file.write(html)


# Load configuration file
config = toml.load('config.toml')
domain = config['feedmason']['domain']
author = config['feedmason']['author']
root = Path(config['feedmason']['root']).expanduser()
feeds = [Path(feed) for feed in config['feedmason']['feeds']]

for feed_path in feeds:
    with open(root/feed_path/'feed.xml', 'w') as feed_file:
        feed = create_feed(feed_path, root, domain, author)
        feed_file.write(str(feed))
    add_link(root, feed_path)

with open(root/'feed.xml', 'w') as feed_file:
    feed = combine_feeds(feeds, root, domain, author)
    feed_file.write(str(feed))
