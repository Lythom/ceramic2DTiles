package entities;

import vox2D.Orientation;
import ceramic.Quad;
import ceramic.Tileset;
import ceramic.Texture;
import vox2D.Vox2D;

using ceramic.VisualTransition;

class LevelView extends ceramic.Visual {
	var level:Level;
	var tileset:Tileset;

	@observe public var orientation:Orientation = Orientation.North;
	public var chunks:Map<String, ChunkView>;

	public function new(tileset:Tileset) {
		super();
		level = new Level();
		chunks = new Map<String, ChunkView>();
		this.tileset = tileset;
	}

	public function update(delta:Float, player:Character, o:Orientation) {
		var cX = Math.floor(player.worldX / Project.cellWidth);
		var cY = Math.floor(player.worldY / Project.cellHeight);
		var chX = Math.floor(cX / 16);
		var chY = Math.floor(cY / 16);
		var currentChunkKey = Chunk.GetKey("test", "0", chX, chY);
		var currentChunk = level.getOrGenerateChunk("test", "0", chX, chY, Std.int(player.worldX), Std.int(player.worldY), 1337);
		var cv:ChunkView;
		if (!chunks.exists(currentChunkKey)) {
			cv = new ChunkView(currentChunk);
			cv.redraw(tileset, o);
			add(cv);
			chunks.set(currentChunkKey, cv);
			var worldX = cv.chunk.chX * 16 * tileset.tileWidth;
			var worldY = cv.chunk.chY * 16 * tileset.tileHeight;
			cv.projectedPos(o, worldX, worldY);
		} else {
			cv = chunks.get(currentChunkKey);
		}
	}

	public function redraw(o:Orientation) {
		for (key => cv in chunks) {
			cv.redraw(this.tileset, o);
			cv.transition(QUAD_EASE_OUT, 4, p -> {
				var worldX = cv.chunk.chX * 16 * tileset.tileWidth;
				var worldY = cv.chunk.chY * 16 * tileset.tileHeight;
				p.x = OrientationHelper.worldToViewX(o, worldX, worldY);
				p.y = OrientationHelper.worldToViewY(o, worldX, worldY);
			});
		}
	}
}
