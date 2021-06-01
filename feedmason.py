#!/usr/bin/env python3

"""Generates Atom feeds for a static website"""

from bs4 import BeautifulSoup
from pathlib import Path
import lxml
import toml

def add_tag(node, label, data, attributes):
    """Create a new tag and append it to a node"""
    soup = BeautifulSoup(features='xml')

    # Set tag label
    tag = soup.new_tag(label)

    # Set tag data
    if data:
        tag.string = data

    # Set tag attributes
    for attr in attributes.keys():
        tag[attr] = attributes[attr]

    node.append(tag)

def generate_feed(feeds, root, domain, author):
    """Generate one or more Atom feeds"""
    soup = BeautifulSoup(features='xml')

    # node, label, data, attributes
    # Create root node
    add_tag(soup, 'feed', '', {'xmlns': 'http://www.w3.org/2005/Atom'})

    # Set global feed data
    add_tag(soup.feed, 'id', domain, {})
    add_tag(soup.feed, 'title', domain, {})
    add_tag(soup.feed, 'author', author, {})
    add_tag(soup.feed, 'link', '', {'href': f'https://{domain}/feed'})

    # Create entry nodes
    for feed in feeds:
        feed = root / feed  # Get absolute path of entry

        for entry in feed.iterdir():
            if not entry.is_file():
                continue

            with open(entry, 'r') as entry_file:
                html = BeautifulSoup(entry_file, 'html.parser')
                title = html.find('h1').string
                summary = html.main.p

                # Set entry-specific data
                node = soup.new_tag('entry')
                add_tag(node, 'id', f'{domain}/{entry.relative_to(root)}', {})
                add_tag(node, 'title', title, {})
                add_tag(node, 'link', '', {'href': f'https://{domain}/{entry.relative_to(root)}'})
            soup.feed.append(node)

    return soup


# Load configuration file
config = toml.load('config.toml')
domain = config['feedmason']['domain']
author = config['feedmason']['author']
root = Path(config['feedmason']['root']).expanduser()
feeds = [Path(feed) for feed in config['feedmason']['feeds']]

# Create combined feed
feed = generate_feed(feeds, root, domain, author)
print(feed, end='\n\n')

# Create individual feeds
for feed_path in feeds:
    feed = generate_feed([feed_path], root, domain, author)
    print(feed, end='\n\n')
