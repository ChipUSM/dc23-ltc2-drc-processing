from pathlib import Path
import xml.etree.ElementTree as ET
from xml.etree.ElementTree import Element
import sys

## See this format document
## https://www.klayout.de/rdb_format.html


def get_child(root: Element, tag) -> Element | None:
    for child in root:
        if child.tag == tag:
            return child

    return None


to_filter = {
    "DCF.1a",
}


def filter_out_childs(root: Element, exclusion_criteria):
    new_element: Element = Element(root.tag)
    for child in root:
        if exclusion_criteria(child):
            continue

        new_element.append(child)

    return new_element


def filter_report(report: Element):
    exclude_items = (
        lambda item: get_child(item, "category").text.strip("'") in to_filter
    )
    exclude_categories = lambda category: get_child(category, "name").text in to_filter

    new_report = Element(report.tag)

    new_report.append(get_child(report, "description"))
    new_report.append(get_child(report, "original-file"))
    new_report.append(get_child(report, "generator"))
    new_report.append(get_child(report, "top-cell"))
    new_report.append(get_child(report, "tags"))
    new_report.append(
        filter_out_childs(get_child(report, "categories"), exclude_categories)
    )
    new_report.append(get_child(report, "cells"))
    new_report.append(filter_out_childs(get_child(report, "items"), exclude_items))

    return new_report


def clean_items(items):
    for item in items:
        if get_child(item, "visited").text == "true":
            get_child(item, "visited").text = "false"


def main(lyrdb_file: Path):
    etree = ET.parse(lyrdb_file.resolve())
    filtered_etree: ET.ElementTree = ET.ElementTree(filter_report(etree.getroot()))

    # items.item.visited->false
    clean_items(get_child(filtered_etree.getroot(), "items"))

    report_path = Path(f"{lyrdb_file.parent}/{lyrdb_file.stem}.filtered.lyrdb")
    filtered_etree.write(report_path.resolve())

    print(report_path.resolve())


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("No lyrdb file given as argument")
        exit(-1)

    lyrdb_file = Path(sys.argv[-1])

    if not lyrdb_file.exists():
        print("lyrdb file doens't exists")
        exit(-1)

    main(lyrdb_file)
