# Apache Dummy Log input plugin for Embulk

This is embulk-input plugin to generate apache combined dummy log. 

## Overview

* **Plugin type**: input
* **Load all or nothing**: yes
* **Resume supported**: no

## Configuration

- **size**: number of log size (long, default: 100)

## Example

```yaml
in:
  type: apache-dummy-log
  size: 100
```

## Build

```
$ rake
```

## Note

This code based on 
[sample_apache_gen.rb](https://github.com/treasure-data/td/blob/master/data/sample_apache_gen.rb) at treasure-data.
