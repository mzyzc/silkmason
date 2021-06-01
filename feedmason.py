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

    if not entry.is_file():
        return

    with open(entry, 'r') as entry_file:
        html = BeautifulSoup(entry_file, 'html.parser')
        title = html.find('h1').string
        summary = html.main.p

    node = soup.new_tag('entry')
    add_tag(node, 'id', domain/path, {})
    add_tag(node, 'title', title, {})
    add_tag(node, 'link', '', {'href': f'https://{domain/path}'})
    #add_tag(node, 'summary', summary, {})

    return node

def create_feed(path, root, domain, author):
    """Create an Atom feed"""
    soup = BeautifulSoup(features='xml')

    with open(f'{root/path}.html', 'r') as page_file:
        html = BeautifulSoup(page_file, 'html.parser')
        title = html.title.string

    add_tag(soup, 'feed', '', {'xmlns': 'http://www.w3.org/2005/Atom'})
    add_tag(soup.feed, 'id', domain/path, {})
    add_tag(soup.feed, 'title', title, {})
    add_tag(soup.feed, 'author', author, {})
    add_tag(soup.feed, 'link', '', {'href': f'https://{domain}/feed'})

    for entry_file in (root/path).iterdir():
        entry = create_entry(entry_file.relative_to(root), root, domain)
        if entry:
            soup.feed.append(entry)

    return soup

def combine_feeds(feeds, domain):
    """Combine multiple Atom feeds into one"""
    # TODO
    pass


# Load configuration file
config = toml.load('config.toml')
domain = config['feedmason']['domain']
author = config['feedmason']['author']
root = Path(config['feedmason']['root']).expanduser()
feeds = [Path(feed) for feed in config['feedmason']['feeds']]

for feed_path in feeds:
    feed = create_feed(feed_path, root, domain, author)
    print(feed, end='\n\n')
