#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, os, subprocess, json, logging
from pprint import pprint

version = '0.1.0'

if len(sys.argv) < 2 or sys.argv[1] == '--help':
  print '''
get_group_ids.py [GROUP_NAME]...

  Finds the security group ID for each GROUP_NAME from Amazon's EC2. Especially
  useful for the Ansible ec2_elb_lb module, which does not accept security
  group names, only security group ids.

  Returns a comma seperated list of security group ID(s)

  Exits 1 if ANY of the GROUP_NAME(s) are not found

REQUIREMENTS

    awscli must be installed
    Credentials must be supplied
    ENV var AWS_REGION must be set

OPTIONS

    --help       This message
    --version    Program version number
'''
  exit(0)
elif sys.argv[1] == '--version':
  print "version: ", version
  exit(0)

get_groups_cmd = ['aws', 'ec2', '--region', os.environ['AWS_REGION'], 'describe-security-groups']

group_list = subprocess.check_output(
    get_groups_cmd,
    stderr=subprocess.STDOUT,
    shell=False)
data = json.loads(group_list)

group_id_list = []
for group in data['SecurityGroups']:
  if group['GroupName'] in sys.argv[1:]:
    group_id_list.append(group['GroupId'])

if group_id_list != [] and len(group_id_list) == len(sys.argv[1:]):
  print ','.join(map(str, group_id_list))
  exit(0)
else:
  print "Unable to find all group names"
  exit(1)
