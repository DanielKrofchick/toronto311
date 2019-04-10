# toronto311
This project visualizes data sets from [Toronto Open Data](https://www.toronto.ca/city-government/data-research-maps/open-data/).

## Getting started
Clone the repository,
```
git clone https://github.com/DanielKrofchick/toronto311.git
```
and build with Xcode.

## Shapefile to GEOJSON
Toronto Open Data sometimes provides data sets as a [Shapefile](https://en.wikipedia.org/wiki/Shapefile). This data is converted to GEOJSON using [mapshaper](https://mapshaper.org) and ingested with [GEOSwift](https://github.com/GEOSwift/GEOSwift).

## Architecture
Data is persisted using [CoreData](https://developer.apple.com/documentation/coredata).

Uses a custom built bottom sheet controller, [Sheet.swift](https://github.com/DanielKrofchick/toronto311/blob/master/Toronto311/View/Sheet.swift), similar to iOS maps.

## Data sets:
Supported:
- [City Wards](https://www.toronto.ca/city-government/data-research-maps/open-data/open-data-catalogue/#29b6fadf-0bd6-2af9-4a8c-8c41da285ad7): [25 Ward Model - December 2018 (WGS84 - Latitude / Longitude)](http://opendata.toronto.ca/gcc/WARD25_OpenData_08072018_wgs84.zip)
- [City Wards](https://www.toronto.ca/city-government/data-research-maps/open-data/open-data-catalogue/#29b6fadf-0bd6-2af9-4a8c-8c41da285ad7): [44 Ward Model - May 2010 (WGS84 - Latitude / Longitude)](http://opendata.toronto.ca/gcc/wards_may2010_wgs84.zip)

## Built With
- [GEOSwift](https://github.com/GEOSwift/GEOSwift): Parse GEOJSON files, and geometry manipulation.
