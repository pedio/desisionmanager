#!/usr/bin/python
import xml.etree.ElementTree as ET
import sys

CONTAINERID=sys.argv[1]
CONTAINERNAME=sys.argv[2]
ARTIFACTID=sys.argv[3]
GROUPID=sys.argv[4]
VERSION=sys.argv[5]

XMLSTR=""

# first list
root = ET.Element("container-spec-details")
container_id = ET.SubElement(root,"container-id")
container_name = ET.SubElement(root,"container-name")
server_template_key = ET.SubElement(root,"server-template-key")
release_id = ET.SubElement(root, "release-id")
#configs = ET.SubElement(root, "configs")
#status = ET.SubElement(root, "status")

#second level
server_id = ET.SubElement(server_template_key,"server-id")
artifact_id = ET.SubElement(release_id,"artifact-id")
group_id = ET.SubElement(release_id,"group-id")
version = ET.SubElement(release_id,"version")
#config_PROCESS =  ET.SubElement(configs,"entry")
#config_RULE =  ET.SubElement(configs,"entry")


container_id.text=CONTAINERID
container_name.text=CONTAINERNAME
server_id.text="default-kieserver"
artifact_id.text=ARTIFACTID
group_id.text=GROUPID
version.text=VERSION
ET.dump(root)

