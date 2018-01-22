#!/bin/bash

gawk '/{{ ca.pem }}/ {while(getline line<"ca.pem"){print "          " line}; next}; \
/{{ ca-key.pem }}/ {while(getline line<"ca-key.pem"){print "          " line}; next}; \
//' ../coreos_master.yml.skel > ../coreos_master.yml

gawk '/{{ ca.pem }}/ {while(getline line<"ca.pem"){print "          " line}; next}; \
/{{ ca-key.pem }}/ {while(getline line<"ca-key.pem"){print "          " line}; next}; \
//' ../coreos_node.yml.skel > ../coreos_node.yml
