package plugin

import (
	_ "github.com/ganma/GM/plugin/consensus/init" //register consensus init package
	_ "github.com/ganma/GM/plugin/crypto/init"
	_ "github.com/ganma/GM/plugin/dapp/init"
	_ "github.com/ganma.n/plugin/store/init"
)
