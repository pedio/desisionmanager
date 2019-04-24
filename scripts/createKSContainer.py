#!/usr/bin/python
import xml.etree.ElementTree as ET
import sys

CONTAINERID=sys.argv[1]
ARTIFACTID=sys.argv[2]
GROUPID=sys.argv[3]
VERSION=sys.argv[4]

XMLSTR=""

# first list
root = ET.Element("kie-container")
container_id = ET.SubElement(root,"container-id")

# second level
release_id = ET.SubElement(root, "release-id")
group_id = ET.SubElement(release_id,"group-id")
artifact_id = ET.SubElement(release_id,"artifact-id")
version = ET.SubElement(release_id,"version")

container_id.text=CONTAINERID
artifact_id.text=ARTIFACTID
group_id.text=GROUPID
version.text=VERSION
ET.dump(root)

