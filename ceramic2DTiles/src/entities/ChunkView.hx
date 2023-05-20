package entities;

import ceramic.Quad;
import ceramic.Tileset;
import ceramic.Texture;
import vox2D.Vox2D;

class TileView extends ceramic.Quad {
	public function new(t:Texture, index:Int, tileset:Tileset) {
		super();
		this.roundTranslation = 0;
		this.alpha = alpha;
		this.blending = blending;
		this.visible = true;
		this.texture = t;
		this.frameX = (index % tileset.columns) * (tileset.tileWidth + tileset.margin * 2 + tileset.spacing) + tileset.margin;
		this.frameY = Math.floor(index / tileset.columns) * (tileset.tileHeight + tileset.margin * 2) + tileset.spacing;
		this.frameWidth = tileset.tileWidth;
		this.frameHeight = tileset.tileHeight;
	}
}

class ChunkView extends ceramic.Visual {
	public var chunk:Chunk;
	public var cells:Array<TileView> = new Array<TileView>();

	public function new(chunk:Chunk) {
		super();
		this.chunk = chunk;
	}

	public function redraw(tileset:Tileset) {
		var i = 0;
		for (x => cx in chunk.cells) {
			for (y => cy in cx) {
				for (z => cell in cy) {
					if (cells.length <= i && cell.blockDefinitionIndex > 0 && cell.blockDefinitionIndex < BlockDefinition.ALL.length) {
						var blockDef = BlockDefinition.ALL[cell.blockDefinitionIndex];
						var tv = new TileView(tileset.texture, blockDef.tilesetIndex, tileset);
						cells.push(tv);
						i++;
						tv.pos(x * tileset.tileWidth, y * tileset.tileHeight - z * tileset.tileHeight * 0.6);
						tv.depth = -10 + z;
						add(tv);
					}
				}
			}
		}
	}
}
