# DC23-LTC2 Scripts for DRC rule filtering

Chile, Korea and Japan achieve tapeout of DC23-LTC2 chip. The fabloop iteration involves a lot of work of solving issues that only appears on the fabric but not with the distributed pdk information.

This repository contains the scripts used to filter drc rules that came on the padring and other that were waived. Hopes this can be used as a reference for other projects.

## First DRC loop: With Michigan Team

LTC2 chip was designed and implemented using open source tools, those don't have all drc rules implemented so the first iteration process was with Michigan team, because they had the official gf180mcu calibre rule deck.
DRC rule results consists of:

- `LTC2.drc.results` with precise coordinates and drc information.
- `LTC2.drc.summary` with human readable information.

## Second DRC Loop: With CMC FAB

This iteration involves only the `.results` file. It has no relevant difference with the first version.

## Files on the repository

_**klayoutrc**_

Holds klayout configuration, since klayout base is a bit uncomfortable. This file is not required

_**parse_results.sh**_

This file contains functions to reduce the amount of information of `.results` and `.summary` files.
This makes easier to read information on klayout.

- `process_results`: Removes `Rule File Title` information, because it only has legal stuff. `Rule File Pathname` information is not relevant
- `process_summary`

`process_results` is not required, but helps **a lot** when viewing drc log on klayout. Recommended to use always.

_**parse_lyrdb.py**_

This python scripts uses `xml.etree` module to filter out nodes on the xml file used by klayout as drc database.
The global set `to_filter` contains rule names that should be removed from the database.

The script logic might be simplified with klayout api, but is not tested.

_**Makefile**_

Holds rules to parse files and run programs.

- `filter-results`: Applies `parse_results.sh` functions
- `filter-lyrdb`: Applies `parse_lyrdb.py` to filter out some of the errors encoded in xml.
- `raw`: Run klayout with the edited drc result file. It doesn't filter any rule, just content.
- `klayout`:  Run klayout with the filtered drc results. This is the final command.
- by default runs `klayout` rule

## Usage

The process is:

1. Clean `*.drc.results` file, generating `*.drc.results.edited`.
2. Open `*.drc.results.edited` with klayout and store it as a `*.lyrdb` file
3. Filter arbitrary rules on `*.lyrdb` file generating the `*.filtered.lyrdb` file
4. Open the `*.filtered.lyrdb` file with klayout and analyze results.

~~~bash
make raw
# Store drc results as a .lyrdb file. It doesn't filter any rule

make
# Opens the filtered drc error file.
~~~