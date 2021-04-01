Tcl Docker Image
================

This is a docker image based on alpine linux with the Tcl runtime (8.7 latest) and a handful of standard packages I frequently need.  It isn't really intended for general use but you're welcome to it if you want.

Docker Hub
==========

Published on hub.docker.com as cyanogilvie/tcl

Included Packages
=================
~~~
	        Thread: 2.8.6
	          tdbc: 1.1.1     (modified to support connection pooling, from https://github.com/cyanogilvie/tdbc)
	tdbc::postgres: 1.1.1     (modified to support connection pooling, from https://github.com/cyanogilvie/tdbcpostgres)
	       sqlite3: 3.34.1
	          tdom: 0.8.3     (modified to better support html generation, from https://github.com/RubyLane/tdom)
	           tls: 1.7.20
	           uri: 1.2.7
	       rl_json: 0.11.0    (https://github.com/RubyLane/rl_json)
	    parse_args: 0.3.1     (https://github.com/RubyLane/parse_args)
	          hash: 0.3       (https://github.com/cyanogilvie/hash)
	  unix_sockets: 0.2       (https://github.com/cyanogilvie/unix_sockets)
	        critcl: 3.1.18    (modified to support defining NRE commands: https://github.com/cyanogilvie/critcl)
	       tcc4tcl: 0.30.1    (modified to support defining NRE commands: https://github.com/cyanogilvie/tcc4tcl)
          gc_class: 1.0       (https://github.com/RubyLane/gc_class)
           rl_http: 1.6       (https://github.com/RubyLane/rl_http)
~~~
