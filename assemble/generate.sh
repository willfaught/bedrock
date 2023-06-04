#!/bin/bash

set -x

BASE='github.com/willfaught/bedrock/assemble'
RESULT=$(pwd)
WORK=$(mktemp -d)

function cleanup {
  rm -rf $WORK
}

trap "cleanup" ERR EXIT

cd $WORK
git clone --branch go1.20.4 --depth 1 https://github.com/golang/go

find $RESULT -type d -mindepth 1 -maxdepth 1 -exec rm -rf {} \;

mkdir -p $RESULT/asm

cp -R $WORK/go/LICENSE $RESULT/LICENSE
cp -R $WORK/go/src/cmd/asm/internal/arch $RESULT/asm/arch
cp -R $WORK/go/src/cmd/internal/bio $RESULT/bio
cp -R $WORK/go/src/cmd/internal/dwarf $RESULT/dwarf
cp -R $WORK/go/src/cmd/internal/goobj $RESULT/goobj
cp -R $WORK/go/src/cmd/internal/notsha256 $RESULT/notsha256
cp -R $WORK/go/src/cmd/internal/obj $RESULT/obj
cp -R $WORK/go/src/cmd/internal/objabi $RESULT/objabi
cp -R $WORK/go/src/cmd/internal/src $RESULT/src
cp -R $WORK/go/src/cmd/internal/sys $RESULT/sys
cp -R $WORK/go/src/internal/abi $RESULT/abi
cp -R $WORK/go/src/internal/buildcfg $RESULT/buildcfg
cp -R $WORK/go/src/internal/goarch $RESULT/goarch
cp -R $WORK/go/src/internal/goexperiment $RESULT/goexperiment
cp -R $WORK/go/src/internal/unsafeheader $RESULT/unsafeheader

cp -R $WORK/go/src/internal/cfg $RESULT/cfg
cp -R $WORK/go/src/internal/goroot $RESULT/goroot
cp -R $WORK/go/src/internal/testenv $RESULT/testenv
cp -R $WORK/go/src/internal/platform $RESULT/platform

find $RESULT -type f -name '*.go' -exec sed -i '' "s_\"internal/_\"$BASE/_g" {} \;
find $RESULT -type f -name '*.go' -exec sed -i '' "s_\"cmd/internal/_\"$BASE/_g" {} \;

find $RESULT/abi -type f -name '*_test.go' -delete
rm $RESULT/testenv/testenv_test.go

cat >$RESULT/buildcfg/zbootstrap.go <<EOF
package buildcfg

import "runtime"

const defaultGO386 = "sse2"
const defaultGOAMD64 = "v1"
const defaultGOARCH = runtime.GOARCH
const defaultGOARM = "7"
const defaultGOEXPERIMENT = ""
const defaultGOMIPS = "hardfloat"
const defaultGOMIPS64 = "hardfloat"
const defaultGOOS = runtime.GOOS
const defaultGOPPC64 = "power8"
const defaultGO_EXTLINK_ENABLED = ""
const defaultGO_LDSO = ""

var version = runtime.Version()
EOF

cat >$RESULT/platform/zosarch.go <<EOF
package platform

var osArchSupportsCgo = map[string]bool{
	"aix/ppc64":       true,
	"darwin/amd64":    true,
	"darwin/arm64":    true,
	"dragonfly/amd64": true,
	"freebsd/386":     true,
	"freebsd/amd64":   true,
	"freebsd/arm":     true,
	"freebsd/arm64":   true,
	"freebsd/riscv64": true,
	"illumos/amd64":   true,
	"linux/386":       true,
	"linux/amd64":     true,
	"linux/arm":       true,
	"linux/arm64":     true,
	"linux/loong64":   true,
	"linux/ppc64":     false,
	"linux/ppc64le":   true,
	"linux/mips":      true,
	"linux/mipsle":    true,
	"linux/mips64":    true,
	"linux/mips64le":  true,
	"linux/riscv64":   true,
	"linux/s390x":     true,
	"linux/sparc64":   true,
	"android/386":     true,
	"android/amd64":   true,
	"android/arm":     true,
	"android/arm64":   true,
	"ios/arm64":       true,
	"ios/amd64":       true,
	"js/wasm":         false,
	"wasip1/wasm":     false,
	"netbsd/386":      true,
	"netbsd/amd64":    true,
	"netbsd/arm":      true,
	"netbsd/arm64":    true,
	"openbsd/386":     true,
	"openbsd/amd64":   true,
	"openbsd/arm":     true,
	"openbsd/arm64":   true,
	"openbsd/mips64":  true,
	"openbsd/ppc64":   false,
	"plan9/386":       false,
	"plan9/amd64":     false,
	"plan9/arm":       false,
	"solaris/amd64":   true,
	"windows/386":     true,
	"windows/amd64":   true,
	"windows/arm":     false,
	"windows/arm64":   true,
}
EOF

cd $RESULT
goimports -w .
