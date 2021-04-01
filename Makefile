VER = 8.7pre3
BRANCH = core-8-branch
# Use core-8-branch to get the latest check-in on the core 8.x branch
#BRANCH = core-8-branch

SOURCES = \
		  context/tcl.tar.gz \
		  context/tclconfig.tar.gz \
		  context/thread.tar.gz \
		  context/tdbc.tar.gz \
		  context/tdbcpostgres.tar.gz \
		  context/tdom.tar.gz \
		  context/sqlite.tar.gz \
		  context/tcltls.tar.gz \
		  context/tcllib.tar.gz \
		  context/rl_json.tar.gz \
		  context/parse_args.tar.gz \
		  context/hash.tar.gz \
		  context/unix_sockets.tar.gz \
		  context/critcl.tar.gz \
		  context/tcc4tcl.tar.gz \
		  context/rl_http.tar.gz

all: image

context/tcl.tar.gz:
	wget https://core.tcl-lang.org/tcl/tarball/$(BRANCH)/tcl.tar.gz -O context/tcl.tar.gz

context/tclconfig.tar.gz:
	wget https://core.tcl-lang.org/tclconfig/tarball/trunk/tclconfig.tar.gz -O context/tclconfig.tar.gz

context/thread.tar.gz:
	wget https://core.tcl-lang.org/thread/tarball/thread-2-8-branch/thread.tar.gz -O context/thread.tar.gz

context/tdbc.tar.gz:
	#wget https://core.tcl-lang.org/tdbc/tarball/tdbc-1-1-1/tdbc.tar.gz -O context/tdbc.tar.gz
	#-rm -rf /tmp/dist
	#make -C ~/fossil/tdbc dist PKG_DIR=tdbc
	#cp /tmp/dist/tdbc.tar.gz context/tdbc.tar.gz
	wget https://github.com/cyanogilvie/tdbc/archive/connection-pool-git.tar.gz -O context/tdbc.tar.gz

context/tdbcpostgres.tar.gz:
	#-rm -rf /tmp/dist
	#make -C ~/fossil/tdbcpostgres dist PKG_DIR=tdbcpostgres
	#cp /tmp/dist/tdbcpostgres.tar.gz context/tdbcpostgres.tar.gz
	wget https://github.com/cyanogilvie/tdbcpostgres/archive/detach-git.tar.gz -O context/tdbcpostgres.tar.gz

context/tdom.tar.gz:
	wget https://github.com/RubyLane/tdom/archive/master.tar.gz -O context/tdom.tar.gz

context/sqlite.tar.gz:
	wget https://sqlite.org/2021/sqlite-autoconf-3340100.tar.gz -O context/sqlite.tar.gz

context/tcltls.tar.gz:
	wget https://core.tcl-lang.org/tcltls/tarball/tls-1-7-22/tcltls.tar.gz -O context/tcltls.tar.gz

context/tcllib.tar.gz:
	# Doesn't work on this repo for some reason - requires a captcha login
	#wget https://core.tcl-lang.org/tcllib/tarball/tcllib-1-20/tcllib.tar.gz -O context/tcllib.tar.gz
	wget https://core.tcl-lang.org/tcllib/uv/tcllib-1.20.tar.gz -O context/tcllib.tar.gz

context/rl_json.tar.gz:
	wget https://github.com/RubyLane/rl_json/archive/master.tar.gz -O context/rl_json.tar.gz

context/parse_args.tar.gz:
	wget https://github.com/RubyLane/parse_args/archive/master.tar.gz -O context/parse_args.tar.gz

context/hash.tar.gz:
	wget https://github.com/cyanogilvie/hash/archive/master.tar.gz -O context/hash.tar.gz

context/unix_sockets.tar.gz:
	wget https://github.com/cyanogilvie/unix_sockets/archive/master.tar.gz -O context/unix_sockets.tar.gz

context/critcl.tar.gz:
	wget https://github.com/andreas-kupries/critcl/archive/master.tar.gz -O context/critcl.tar.gz

context/tcc4tcl.tar.gz:
	wget https://github.com/cyanogilvie/tcc4tcl/archive/master.tar.gz -O context/tcc4tcl.tar.gz
	#fossil clone http://chiselapp.com/user/rkeene/repository/tcc4tcl
	#fossil tarball --repository tcc4tcl.fossil --name tcc4tcl -l trunk context/tcc4tcl.tar.gz

context/gc_class.tar.gz:
	wget https://github.com/RubyLane/gc_class/archive/master.tar.gz -O context/gc_class.tar.gz

context/rl_http.tar.gz:
	wget https://github.com/RubyLane/rl_http/archive/master.tar.gz -O context/rl_http.tar.gz

image: $(SOURCES)
	#docker build --squash --network=host -t tcl:$(VER) -t tcl:latest -f Dockerfile context
	docker build --network=host -t tcl:$(VER) -t tcl:latest -f Dockerfile context

test: image
	echo 'package require platform; puts "Tcl [info patchlevel] on [platform::identify], packages:\\n\\t[join [lmap e {Thread tdbc tdbc::postgres sqlite3 tdom tls uri rl_json parse_args hash unix_sockets critcl tcc4tcl gc_class rl_http} {format {%14s: %s} [set e] [package require [set e]]}] \\n\\t]"' | docker run --rm -i tcl:$(VER)

inspect: image
	docker run --rm -it --entrypoint=/bin/sh --network=host tcl:$(VER)

run: image
	docker run --rm -it tcl:$(VER)

publish: image
	docker tag tcl:$(VER) cyanogilvie/tcl:$(VER)
	docker tag tcl:$(VER) cyanogilvie/tcl:latest
	docker push cyanogilvie/tcl:$(VER)
	docker push cyanogilvie/tcl:latest

clean:
	-rm -rf $(SOURCES)
