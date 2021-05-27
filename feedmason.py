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

def convert_to_feed(data):
    """Convert a dictionary into an Atom feed"""
    soup = BeautifulSoup(features='xml')

    tag = soup.new_tag('feed', xmlns='http://www.w3.org/2005/Atom')
    soup.append(tag)

    tag = soup.new_tag('id')
    tag.string = data['id']
    soup.feed.append(tag)

    tag = soup.new_tag('title')
    tag.string = data['title']
    soup.feed.append(tag)

    tag = soup.new_tag('author')
    tag.string = data['author']
    soup.feed.append(tag)

    tag = soup.new_tag('link', href=data['link'])
    soup.feed.append(tag)

    for entry in data['entries']:
        subsoup = soup.new_tag('entry')

        tag = soup.new_tag('id')
        tag.string = entry['id']
        subsoup.append(tag)

        tag = soup.new_tag('title')
        tag.string = entry['title']
        subsoup.append(tag)

        tag = soup.new_tag('link', href=entry['link'])
        subsoup.append(tag)

        # TODO: figure out why this doesn't work
        #tag = soup.new_tag('summary', type='html')
        #tag.string = entry['summary']
        #subsoup.append(tag)

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
