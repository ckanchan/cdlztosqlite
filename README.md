# cdlztosqlite
Generates a SQLite store from Oracc CDL ZIP archives

## Introduction
This command line utility generates a SQLite cache file from Oracc JSON files for use in macOS/iOS apps. It converts a CDL file into a Swift object, then records string representations of that object, together with catalogue data, into a SQLite row.

## Advantages
- Fast retrieval of cuneiform, transliteration, normalisation and translations of text editions, eliminating JSON decoding overhead
- Slightly more efficient disk space usage than JSON ZIP archives

## Caveats
- Lossy encoding: the stored strings are just flat representations and lack the richness of the CDL objects
- Translations are scraped at runtime, requiring a connection to oracc.org, which is inherently fragile


## Specifications
Oracc XML standards are available on the [Oracc website](http://oracc.museum.upenn.edu/doc/about/standards/index.html) although many of them are inaccessible at the moment, so they can alternatively be found directly in the Oracc [Github repository](https://github.com/oracc/oracc/tree/master/doc/ns).

Oracc JSON specifications are available on the [Oracc website](http://oracc.museum.upenn.edu/doc/opendata/index.html).
