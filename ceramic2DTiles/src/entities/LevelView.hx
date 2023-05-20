package entities;

import vox2D.Orientation;
import ceramic.Quad;
import ceramic.Tileset;
import ceramic.Texture;
import vox2D.Vox2D;

class LevelView extends ceramic.Visual {
	var level:Level;
	var tileset:Tileset;

	public var chunks:Map<String, ChunkView>;

	public function new(tileset:Tileset) {
		super();
		level = new Level();
		chunks = new Map<String, ChunkView>();
		this.tileset = tileset;
	}

	public function update(delta:Float, player:Character) {
		var cX = Math.floor(player.x / Project.cellWidth);
		var cY = Math.floor(player.y / Project.cellHeight);
		var chX = Math.floor(cX / 16);
		var chY = Math.floor(cY / 16);
		var currentChunkKey = Chunk.GetKey("test", "0", chX, chY);
		var currentChunk = level.getOrGenerateChunk("test", "0", chX, chY, Std.int(player.x), Std.int(player.y), 1337);
		if (!chunks.exists(currentChunkKey)) {
			var cv = new ChunkView(currentChunk);
			cv.redraw(tileset);
			cv.pos(cv.chunk.chX * 16 * Project.cellWidth, cv.chunk.chY * 16 * Project.cellHeight);
			add(cv);
			chunks.set(currentChunkKey, cv);
			trace("New ChunkView at " + cv.x + "," + cv.y);
		}
	}
}
