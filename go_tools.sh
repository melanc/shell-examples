#!/bin/bash

gosrc=/home/smile/workspace/go/src
gobin=/usr/local/go/bin/

echo "build start..."

cd $gosrc/github.com/nsf/gocode
go build
cp gocode $gobin

cd $gosrc/github.com/rogpeppe/godef
go build
cp godef $gobin

cd $gosrc/github.com/bradfitz/goimports
go build
cp goimports $gobin

cd $gosrc/golang.org/x/tools/cmd/oracle
go build
cp oracle $gobin

cd $gosrc/golang.org/x/tools/cmd/gorename
go build
cp gorename $gobin

cd $gosrc/github.com/golang/lint/golint
go build
cp golint $gobin

cd $gosrc/github.com/kisielk/errcheck
go build
cp errcheck $gobin

cd $gosrc/github.com/jstemmer/gotags
go build
cp gotags $gobin

cd $gosrc/github.com/tools/godep
go build
cp godep $gobin

cd $gosrc/github.com/pote/gpm
./configure
make install

echo "build finish..."
