awscli Cookbook
===================

awscli commandline tool installation cookbook.

Requirements
------------

* Depends "hostsfile" cookbook.
* Install python before use this cookbool.


Attributes
----------

global:

* `node['my_environment']` - environment name for setup data select that will be used by awscli::hosts.

default:

* `node['awscli']['aws_access_key_id']` - AWS access key id (required)
* `node['awscli']['aws_secret_access_key']` - AWS secret access key (required)
* `node['awscli']['aws_default_region']` - AWS region for aws cli tool (required)
* `node['awscli']['aws_command_path']` - path to aws cli tool that set automatically if nil. default is nil.

hosts:

* `node['awscli']['bag_name']` - default is 'hosts'.
* `node['awscli']['aws_tag_name_hostid']` - default is 'Name'.
* `node['awscli']['aws_tag_name_environment']` - default is 'Environment'.

If `ipaddr_aws_private` is true, this recipe will retrieve IP address from aws instance information.

For example, a instance has Tags information as
`[{"Name": "Name", "Value": "host-db1"}, {"Name": "Environment", "Value": "production"}]`.
This instance will match with `node['my_environment']=='production'` and `data_bag`'s 'host-db1'
entry.

If your instances have another field names for Tags, you can change field name by
`node['awscli']['aws_tag_name_hostid']` and `node['awscli']['aws_tag_name_environment']`
attributes.


Data bags
----------

file: `data_bags/<bag_name>/<my_environment>.json` used by `awscli::hosts`:

```json
{
  "id": "production",
  "host-workstation": {
    "ipaddr": "192.168.1.1",
    "aliases": [
      "host-ap1",
      "host-ap2"
    ]
  },
  "host-db1": {
    "ipaddr_aws_private": true,
    "aliases": [
      "db1"
    ]
  }
}
```

Recipes
-------

* `awscli::default` - install aws cli command.
* `awscli::hosts` - setup /etc/hosts from data bag.


Usage
-----
#### awscli::default

Just include `awscli::<any sub recipe>` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[awscli]"
  ]
}
```

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Takayuki Shimizukawa
License: Apache 2.0
