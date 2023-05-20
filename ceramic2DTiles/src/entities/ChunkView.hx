package entities;

import vox2D.Orientation.OrientationHelper;
import vox2D.Orientation;
import ceramic.Quad;
import ceramic.Tileset;
import ceramic.Texture;
import vox2D.Vox2D;

using ceramic.VisualTransition;

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
		this.rotation = 0;
	}

	public inline function projectedPos(o:Orientation, x:Float, y:Float) {
		x = OrientationHelper.worldToViewX(o, x, y);
		y = OrientationHelper.worldToViewY(o, x, y);
		// rotation = OrientationHelper.getAngle(o);
	}
}

class ChunkView extends ceramic.Visual {
	public var chunk:Chunk;
	public var tileViews:Map<String, TileView> = new Map<String, TileView>();

	public function new(chunk:Chunk) {
		super();
		this.chunk = chunk;
	}

	public function redraw(tileset:Tileset, o:Orientation) {
		for (cX => xArr in chunk.cells) {
			for (cY => yArr in xArr) {
				for (cZ => cell in yArr) {
					var key = cX + "_" + cY + "_" + cZ;
					var tv:TileView = tileViews.exists(key) ? tileViews.get(key) : null;
					if (tv == null && cell.blockDefinitionIndex > 0 && cell.blockDefinitionIndex < BlockDefinition.ALL.length) {
						var blockDef = BlockDefinition.ALL[cell.blockDefinitionIndex];
						tv = new TileView(tileset.texture, blockDef.tilesetIndex, tileset);
						tileViews.set(key, tv);
						tv.depth = -10 + cZ;
						add(tv);
						var worldX = cX * tileset.tileWidth;
						var worldY = cY * tileset.tileHeight;
						tv.x = OrientationHelper.worldToViewX(o, worldX, worldY);
						tv.y = OrientationHelper.worldToViewY(o, worldX, worldY) - cZ * Project.cellHeight * 0.6;
					}
					if (tv != null) {
						tv.transition(QUAD_EASE_OUT, 4, p -> {
							var worldX = cX * tileset.tileWidth;
							var worldY = cY * tileset.tileHeight;
							p.x = OrientationHelper.worldToViewX(o, worldX, worldY);
							p.y = OrientationHelper.worldToViewY(o, worldX, worldY) - cZ * Project.cellHeight * 0.6;
						});
					}
				}
			}
		}
	}

	public inline function projectedPos(o:Orientation, pX:Float, pY:Float) {
		this.x = OrientationHelper.worldToViewX(o, pX, pY);
		this.y = OrientationHelper.worldToViewY(o, pX, pY);
	}
}
