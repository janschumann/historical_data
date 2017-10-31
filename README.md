# Simple test for es date histogram

This is an example for using the [date histogram](https://www.elastic.co/guide/en/elasticsearch/reference/5.5/search-aggregations-bucket-datehistogram-aggregation.html) aggregation.

## General objectives

- Automatic installation using [ansible](https://www.ansible.com) as it is
our primary provisioning tool
- ES version should be configurable to adjust to AWS es version, which will be
used in production
- Simple fixture setup
- Future changes of the OS platform should be easy

## Used tools

- [test kitchen](http://kitchen.ci) for simple startup and provision an
elasticsearch instance
- [docker](https://www.docker.com) for lightweight and fast virtualisation

## Usage

### Prerequisites

- ruby >= 2.4.0
- bundler gem installed (`gem install bundler`)
- docker up and running

### Start the container

- clone this repo with --recursive OR clone and update submodules
```
$ git clone --recursive git@github.com:janschumann/historical_data.git
$ cd historical_data

# OR

$ git clone git@github.com:janschumann/historical_data.git
$ cd historical_data
$ git submodule init
$ git submodule update
```
- bundle ruby gems
```
$ bundle install
```
- start instance
```
$ kitchen converge
```
- verify cluster health
```
$ PORT=$(./es/es_port.sh)
$ curl "localhost:$PORT/_cluster/health?pretty"
```

### Configuration

#### Container Setup

To initially setup a new instance, issue
```
$ kitchen converge
```

The container configuration is done in the driver config section in
`.kitchen.yml`.

Please read [docs](https://github.com/test-kitchen/kitchen-docker) for detailed
description.

The container is based on
[ubuntu:xenial](https://hub.docker.com/r/library/ubuntu/). Please note, that
this image is not intended for production use.

For compatibility reasons, the following settings should not be changed:
- [driver_config/forward](https://github.com/test-kitchen/kitchen-docker#forward)
  - The default es port (9200) is forwarded to a random docker port
  - This prevents port conflicts with existing instances
  - The allocated port can be easily retrieved by `docker container list`
  - If, however, the port needs to be changed for some reason, make sure to
  change `ansible/playbook.yml` accordingly

Changing the kitchen configuration always requires a restart:
```
$ kitchen destroy
$ kitchen converge
```

#### ES

##### Provisioning

ES is installed through the [official ansible playbook](https://github.com/elastic/ansible-elasticsearch).
The configuration is located in `ansible/playbook.yml`.

Changing the playbook config, only requires a provisioner re-run:
```
$ kitchen converge
```

Exception: Changing the ES version (vars/es_version) also requires a restart:
```
$ kitchen destroy
$ kitchen converge
```

*NOTE* This cluster is configured as single node. Therefore `node.data` and `node.master` must be set to `true`


##### Index Setup

- Index: `historical_data`
- Only one single type is used: `doc`
- The field `date` is mapped as a date field type

### Fixture data

Fixture documents are located in `es/data`. Each of these documents match the
following specs:
- `date`: an es supported date string
- `field_name`: the name of the field to store by date (for filtering)
- `user_id`: an integer value representing a user id (for filtering)
- `value`: a numeric value (used for aggregation)

To create a fresh index issue:
```
$ ./es/init.sh
```

### Execute example queries

- Show all docs
```
$ ./es/query.sh
```
- Execute specific query
```
$ ./es/query.sh es/queries/agg.json 1
$ ./es/query.sh es/queries/agg.json 2
```
