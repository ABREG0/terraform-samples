# abrego 20221006 - 
# after running terraform show -json file.json, reads json file and displays deletes and creates for azure RBAC
import json
import sys
from pathlib import Path
import re
data_folder = Path("c:/temp")
output_data_folder = Path("c:/temp/output")
actions_report = []
create_report = []
delete_report = []
with open(data_folder / "1.json") as json_file:
  jsonplan2 = json.loads(json_file.read())
  count = 0
  for i in jsonplan2['resource_changes']:
      if i['change']['actions'][0] != "no-op":
          if i['change']['actions'][0] == "delete":
              try:
                action = json.dumps(i['change']['actions'][0] , indent=4)
                principal_id = json.dumps(i['change']['before']['principal_id'], indent=4)
                scope = json.dumps(i['change']['before']["scope"], indent=4)
                role_definition_name = json.dumps(i['change']['before']['role_definition_name'], indent=4)
                tmp = [role_definition_name, principal_id, scope]                                  
                actions_report.append(tmp)
                delete_report.append(tmp)
                # print(tmp)
                del tmp
              except:
                pass
          elif i['change']['actions'][0] == "create":
              try:
                action = json.dumps(i['change']['actions'][0] , indent=4)
                principal_id = json.dumps(i['change']['after']['principal_id'], indent=4)
                scope = json.dumps(i['change']['after']["scope"], indent=4)
                role_definition_name = json.dumps(i['change']['after']['role_definition_name'], indent=4)
                tmp = [role_definition_name, principal_id, scope]
                actions_report.append(tmp)
                create_report.append(tmp)
                # print(tmp)
                del tmp
              except:
                pass
          else:
              print("op_time not define")
              continue
      count += 1
def return_non_matches(a, b):
    return [x for x in a if x not in b]
print("List of roles deleted not being created.")
print("return_non_patches:", return_non_matches(delete_report, create_report))
print()
print("Roles to Delete")
print("count:", len(delete_report))
print()
print("{} {} {:<38} {:<32} {:<40}".format('delete', 'create', 'principal_id', 'role_definition_name', 'scope', ))
for i in delete_report:
    role_definition_name, principal_id, scope = i
#     print("{:<10} {:<12} {:<14}".format( role_definition_name, principal_id, scope))
    if i in create_report:
        pt = "%s %s %s %s %s"%('"true"', '"true"', principal_id, role_definition_name, scope, )
        print(pt)
    else:
        pt = "%s %s %s %s %s"%('"true"', '"false"', principal_id, role_definition_name, scope, )
        print(pt)
#     print(tmp)
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
