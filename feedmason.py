#!/usr/bin/env python3

"""Generates Atom feeds for a static website"""

from bs4 import BeautifulSoup
from pathlib import Path
import lxml
import toml

def add_tag(node, label, data, attributes):
    """Create a new tag and append it to a node"""
    tag = soup.new_tag(label)

    if data:
        tag.string = data

    for attr in attributes.keys():
        tag[attr] = attributes[attr]

    node.append(tag)


config = toml.load('config.toml')
domain = config['feedmason']['domain']
author = config['feedmason']['author']
root = Path(config['feedmason']['root']).expanduser()
feeds = [Path(feed) for feed in config['feedmason']['feeds']]

soup = BeautifulSoup(features='xml')

# node, label, data, attributes
add_tag(soup, 'feed', '', {'xmlns': 'http://www.w3.org/2005/Atom'})
add_tag(soup.feed, 'id', f'https://{domain}', {})
add_tag(soup.feed, 'title', domain, {})
add_tag(soup.feed, 'author', author, {})
add_tag(soup.feed, 'link', '', {'href': f'https://{domain}/feed'})

for feed in feeds:
    # Get absolute path
    feed = root / feed
    for entry in feed.iterdir():
        if not entry.is_file():
            continue

        with open(entry, 'r') as entry_file:
            html = BeautifulSoup(entry_file, 'html.parser')
            title = html.find('h1').string
            summary = html.main.p

            node = soup.new_tag('entry')
            add_tag(node, 'id', f'https://{domain}/{entry.relative_to(root)}', {})
            add_tag(node, 'title', title, {})
            add_tag(node, 'link', '', {'href': f'https://{domain}/{entry.relative_to(root)}'})
        soup.feed.append(node)

print(soup)
