#!/bin/bash

set -e

echo "testing google chrome dump-dom"
/usr/local/bin/chrome-dump-dom 2>/dev/null

echo "testing google chrome screenshot"
/usr/local/bin/chrome-screenshot 2>/dev/null

echo "testing puppeteer"
/usr/local/bin/puppeteer-test