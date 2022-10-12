import json
import sys
from pathlib import Path
import re
import os
ENV = os.environ["ENVIRONMENT"]
actions_report = []
create_report = []
delete_report = []
with open("src/"+ENV+".json") as json_file:
    jsonplan2 = json.loads(json_file.read())
    count = 0
    for i in jsonplan2['resource_changes']:
        if i['change']['actions'][0] != "no-op":
            if i['change']['actions'][0] == "delete":
                try:
                    action = json.dumps(i['change']['actions'][0] , indent=4)
                    principal_id = json.dumps(i['change']['before']["principal_id"], indent=4)
                    scope = json.dumps(i['change']['before']["scope"], indent=4)
                    role_definition_name = json.dumps(i['change']['before']["role_definition_name"], indent=4)
                    tmp = [role_definition_name, principal_id, scope]                                  
                    actions_report.append(tmp)
                    delete_report.append(tmp)
                    # print(tmp)
                except:
                    pass
            elif i['change']['actions'][0] == "create":
                try:
                    action = json.dumps(i['change']['actions'][0] , indent=4)
                    principal_id = json.dumps(i['change']['after']["principal_id"], indent=4)
                    scope = json.dumps(i['change']['after']["scope"], indent=4)
                    role_definition_name = json.dumps(i['change']['after']["role_definition_name"], indent=4)
                    tmp = [role_definition_name, principal_id, scope]
                    actions_report.append(tmp)
                    create_report.append(tmp)
                    # print(tmp)
                except:
                    pass
            else:
                # print("op_time not define")
                continue
        count += 1
# match function
def return_non_matches(a, b):
    return [x for x in a if x not in b]
print("{} {:<40} {:<54} {:<40}".format('action', 'role_definition_name', 'principal_id', 'scope', ))
delete_create_compare = return_non_matches(delete_report, create_report)
if delete_create_compare == []:
    print("All deleted roles are being created.")
else:
    for d in delete_create_compare:
        print("Roles that were deleted but not created:")
        principal_id, role_definition_name, scope = d
        mp = "%s %s %s %s"%('"delete"', principal_id, role_definition_name, scope, )
        print(mp)
create_delete_compare = return_non_matches(create_report, delete_report)
if create_delete_compare == []:
    print("All deleted roles are being created.")
else:
    for d in delete_create_compare:
        print("New Roles to create that did not exist or were deleted:")
        principal_id, role_definition_name, scope = d
        mp = "%s %s %s %s"%('"create"', principal_id, role_definition_name, scope, )
        print(mp)
print()
#parsing both table for discrepencies..
merged_summary = [] 
for vDelete in delete_report:
    role_definition_name, principal_id, scope = vDelete
    if vDelete in create_report:
        c_action = '"true"'
    else:
        c_action = '"false"'
    if vDelete in delete_report:
        d_action = '"true"'
    else:
        d_action = '"false"'
    pt = [d_action, c_action, principal_id, role_definition_name, scope,]
    merged_summary.append(pt)
    # print(pt)
for vCreate in create_report:
    role_definition_name, principal_id, scope = vDelete
    if vCreate in create_report:
        c_action = '"true"'
    else:
        c_action = '"false"'
    if vCreate in delete_report:
        d_action = '"true"'
    else:
        d_action = '"false"'
    pt = [d_action, c_action, principal_id, role_definition_name, scope,]
    merged_summary.append(pt)
    # print(pt)
print()
print("Summary")
print("{} {} {:<40} {:<44} {:<40}".format('delete', 'create', 'principal_id', 'role_definition_name', 'scope', ))
for m in merged_summary:
    # print(m)
    if '"false"' in m:        
        d_action, c_action, principal_id, role_definition_name, scope = m
        mp = "%s %s %s %s %s"%(d_action, c_action, principal_id, role_definition_name, scope, )
        print(mp)
print()
print("Roles to Delete")
print("count:", len(delete_report))
print("{:<8} {:<38} {:<30} {:<40}".format('action', 'principal_id', 'role_definition_name', 'scope', ))
for i in delete_report:
    role_definition_name, principal_id, scope = i
    print("delete: {} {} {:<38}".format(principal_id, role_definition_name, scope))
print()
print("Roles to Create")
print("count:", len(create_report))
print("{:<8} {:<38} {:<30} {:<40}".format('action', 'principal_id', 'role_definition_name', 'scope', ))
for i in create_report:
    role_definition_name, principal_id, scope = i
    print("create: {} {} {:38}".format(principal_id, role_definition_name, scope))
