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
