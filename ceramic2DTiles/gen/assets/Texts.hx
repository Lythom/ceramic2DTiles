package assets;

import assets.AllAssets;

#if !macro
@:build(ceramic.macros.AssetsMacro.buildNames('text'))
#end
class Texts {}
