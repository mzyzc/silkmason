#!/usr/bin/env python3

"""Generates Atom feeds for a static website"""

from bs4 import BeautifulSoup
from pathlib import Path
import lxml
import toml

def generate_entry(entry_file):
    """Extract Atom entry data from a HTML file"""
    data = {}
    with open(entry, 'r') as entry_file:
        soup = BeautifulSoup(entry_file, 'html.parser')
        data['id'] = f'https://{domain}/{entry.relative_to(root)}'
        data['title'] = soup.find('h1').string
        data['link'] = f'https://{domain}/{entry.relative_to(root)}'
        data['summary'] = soup.main.p
    return data

def add_tag(node, label, data, attributes):
    """Create a new tag and append it to a node"""
    tag = node.new_tag(label)
    tag.string = data
    for attr in attributes.keys():
        tag[attr] = attributes[attr]
    node.append(tag)

def convert_to_feed(data):
    """Convert a dictionary into an Atom feed"""
    soup = BeautifulSoup(features='xml')

    add_tag(soup, 'feed', None, {'xmlns': 'http://www.w3.org/2005/Atom'})
    add_tag(soup.feed, 'id', data['id'], None)
    add_tag(soup.feed, 'title', data['title'], None)
    add_tag(soup.feed, 'author', data['author'], None)
    add_tag(soup.feed, 'link', None, {'href': data['link']})

    for entry in data['entries']:
        subsoup = soup.new_tag('entry')

        add_tag(subsoup, 'id', entry['id'], None)
        add_tag(subsoup, 'title', entry['title'], None)
        add_tag(subsoup, 'link', None, {'href': entry['link']})
        # TODO: figure out why this doesn't work
        #add_tag(subsoup, 'summary', entry['summary'], {'type': 'html'})

        soup.feed.append(subsoup)

    return soup


config = toml.load('config.toml')
domain = config['feedmason']['domain']
author = config['feedmason']['author']
root = Path(config['feedmason']['root']).expanduser()
feeds = [Path(feed) for feed in config['feedmason']['feeds']]

output_feed = {
    'id': f'https://{domain}',
    'title': domain,
    'author': author,
    'link': f'https://{domain}/feed',
    'entries': [],
}

for feed in feeds:
    # Get absolute path
    feed = root / feed
    for entry in feed.iterdir():
        if not entry.is_file():
            continue

        data = generate_entry(entry)
        output_feed['entries'].append(data)

final = convert_to_feed(output_feed)
print(final)
