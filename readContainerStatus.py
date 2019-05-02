#!/usr/bin/python
import xml.etree.ElementTree as ET
import sys

XMLSTR=""

#tree = ET.parse("test.xml")
for line in sys.stdin:
    XMLSTR += line
root = ET.fromstring(XMLSTR)
container = root.find("kie-container")
print container.get("status")

