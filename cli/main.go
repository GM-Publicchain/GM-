// +build go1.8

package main

import (
	_ "github.com/GM/ganam/system"
	_ "github.com/ganma/GM/plugin"

	"github.com/GM/GANMA/util/cli"
	"github.com/ganma/ganma/cli/buildflags"
)

func main() {
	if buildflags.RPCAddr == "" {
		buildflags.RPCAddr = "http://localhost:8801"
	}
	cli.Run(buildflags.RPCAddr, buildflags.ParaName)
}
