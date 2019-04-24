#!/usr/bin/python
import xml.etree.ElementTree as ET
import sys

XMLSTR=""

#tree = ET.parse("test.xml")
for line in sys.stdin:
    XMLSTR += line
tree = ET.fromstring(XMLSTR)
for child in tree:
   if child.tag.find("groupId") >= 0:
     print "groupId="+child.text
   if child.tag.find("artifactId") >= 0:
     print "artifactId="+child.text
   if child.tag.find("version") >= 0:
     print "version="+child.text

