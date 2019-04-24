#!/usr/bin/python
import xml.etree.ElementTree as ET
import sys

XMLSTR=""

#tree = ET.parse("test.xml")
for line in sys.stdin:
    XMLSTR += line
tree = ET.fromstring(XMLSTR)
serverinstances = tree.findall("server-instances")
for serverinstance in serverinstances:
    url = serverinstance.find("server-url")
    print url.text
