#!/bin/bash -e

# This script builds Google Performance Tools v. 2.6.90 using the cross toolchain, and packs it up
# into a tar ball.

usage="$0 [--help|-h] command [arg]..."

function print_usage {
  echo "usage: ${usage}" >&2
  if [[ $# -gt 0 ]]; then
    echo $@ >&2
  fi
  exit 1
}

function print_help {
  echo "usage: ${usage}"
  echo
  echo "builds the software"
  echo
  echo "positional arguments:"
  echo "  command       which action to take; 'build' builds the artifact,"
  echo "                'unpack' unpacks the Google code to the purpose of"
  echo "                analysis, and 'clean' cleans up nicely."
  echo
  echo "optional arguments:"
  echo "  -h, --help    shows this help text and exits"
}



GPERFTOOLS_VERSION=2.6.90
TARBALL=ur-tcmalloc

# Download
function download {
  if [ ! -f "gperftools-$GPERFTOOLS_VERSION.tar.gz" ]; then
    wget https://github.com/gperftools/gperftools/releases/download/gperftools-$GPERFTOOLS_VERSION/gperftools-$GPERFTOOLS_VERSION.tar.gz
  fi
}

# Unpack
function unpack {
  rm -rf gperftools-$GPERFTOOLS_VERSION
  tar xvzf gperftools-$GPERFTOOLS_VERSION.tar.gz
}

# Build
function build {
  mkdir gperftools-$GPERFTOOLS_VERSION/build
  cd gperftools-$GPERFTOOLS_VERSION/build
  ../configure --host=i686-unknown-linux-gnu --enable-minimal
  make
  cd -
}

# Pack
function pack {
  mkdir -p target/lib
  cp -ar gperftools-$GPERFTOOLS_VERSION/build/.libs/libtcmalloc_minimal.a target/lib

  cd target; tar -pczf ../$TARBALL.tar.gz ./*; cd -
}

# Clean
function clean() {
  rm -Rf gperftools-$GPERFTOOLS_VERSION
  rm -rf target
}

# PARSE COMMAND LINE ARGUMENT
cmd=build
if [[ $# -ge 1 ]]; then
  cmd=$1
  shift 1
fi

case "$cmd" in
--help | -h)
  print_help
  ;;

build)
  download
  unpack
  build
  pack
  ;;

unpack)
  unpack
  ;;

clean)
  clean
  ;;

*)
  print_usage "invalid command given"
  ;;
esac
