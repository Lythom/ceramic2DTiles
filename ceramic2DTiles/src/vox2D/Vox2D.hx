package vox2D;

import tracker.Tracker;
import haxe.io.BytesInput;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.EnumFlags;
import ceramic.Texture;
import tracker.Model;

using tracker.SaveModel;

class TilesetDefinition extends Model {
	public var tiles:Array<TileDefinition>;
}

class CellData {
	// index in <see cref="TilesetDefinition.tiles" />
	public var index:Int;
}

// Enums
enum Equipment {
	None;
	Novice;
	Apprentice;
	Mage;
	Master;
}

// Structures de données
class Cell {
	public var blockDefinitionIndex:Int;
	public var damageLevel:Int;

	public function new(idx:Int) {
		this.blockDefinitionIndex = idx;
	}
}

class BlockDefinition {
	public static var AIR:BlockDefinition = create(-1);
	public static var ALL:Array<BlockDefinition> = [AIR, create(55), create(5), create(20)];

	public var tilesetIndex:Int;
	public var miningLevel:Int;
	public var requiredEquipment:EnumFlags<Equipment>;

	public function new() {
		tilesetIndex = 0;
		miningLevel = 0;
		requiredEquipment = Equipment.None;
	}

	public static function create(tilesetIndex:Int) {
		var b = new BlockDefinition();
		b.tilesetIndex = tilesetIndex;
		return b;
	}
}

class TileDefinition {
	public var textures:Map<String, Texture>;
}

class Chunk extends Model {
	public var saveId:String;
	public var levelId:String;
	public var chX:Int;
	public var chY:Int;
	@serialize public var cells:Array<Array<Array<Cell>>>;
	public var isLoaded:Bool;

	public function new(saveId:String, levelId:String, chX:Int, chY:Int) {
		super();
		this.saveId = saveId;
		this.levelId = levelId;
		this.chX = chX;
		this.chY = chY;
		this.cells = new Array<Array<Array<Cell>>>();
		for (x in 0...16) {
			this.cells.push(new Array<Array<Cell>>());
			for (y in 0...16) {
				this.cells[x].push(new Array<Cell>());
				for (z in 0...7) {
					this.cells[x][y].push(new Cell(0));
				}
			}
		}
		this.isLoaded = false;
	}

	public function getKey():String {
		return Chunk.GetKey(saveId, levelId, chX, chY);
	}

	public static function GetKey(saveId:String, levelId:String, chX:Int, chY:Int):String {
		return saveId + "_" + levelId + "_" + chX + "_" + chY;
	};

	function serializeChunk():Bytes {
		var output = new BytesOutput();
		output.writeInt32(chX);
		output.writeInt32(chY);
		for (x in 0...16) {
			for (y in 0...16) {
				for (z in 0...7) {
					var cell = cells[x][y][z];
					output.writeInt32(cell.blockDefinitionIndex);
					output.writeInt32(cell.damageLevel);
				}
			}
		}
		return output.getBytes();
	}

	function unserializeChunk(input:BytesInput) {
		chX = input.readInt32();
		chY = input.readInt32();
		for (x in 0...16) {
			for (y in 0...16) {
				for (z in 0...7) {
					var cell = cells[x][y][z];
					cell.blockDefinitionIndex = input.readInt32();
					cell.damageLevel = input.readInt32();
				}
			}
		}
		isLoaded = true;
	}
}

class Level {
	public var chunks:Map<String, Chunk>;
	public var blockDefinitions:Array<BlockDefinition>;
	public var tileDefinitions:Array<TileDefinition>;

	public function new() {
		this.chunks = new Map<String, Chunk>();
		this.blockDefinitions = new Array<BlockDefinition>();
		this.tileDefinitions = new Array<TileDefinition>();
	}

	public function generateChunk(saveId:String, levelId:String, chX:Int, chY:Int, cX:Int, cY:Int, seed:Int):Chunk {
		trace("generateChunk " + chX + "," + chY);

		// Générer un nouveau chunk
		var chunk = new Chunk(saveId, levelId, chX, chY);
		// ... code de génération du chunk
		for (x in 0...16) {
			for (y in 0...16) {
				// put a wall sometimes
				var cell = chunk.cells[x][y][4];
				var chances = 0.08;
				if (x > 0) {
					var left = chunk.cells[x - 1][y][4];
					if (left.blockDefinitionIndex != 0)
						chances = 0.6;
				}
				cell.blockDefinitionIndex = Math.random() < chances ? 2 : 0;
				if (cell.blockDefinitionIndex == 2) {
					var wallTop = chunk.cells[x][y][5];
					wallTop.blockDefinitionIndex = Math.random() < 0.9 ? 2 : 0;
					if (wallTop.blockDefinitionIndex == 2) {
						var wallTop = chunk.cells[x][y][6];
						wallTop.blockDefinitionIndex = Math.random() < 0.75 ? 3 : 0;
					}
				}

				// ground everywhere
				var ground = chunk.cells[x][y][3];
				ground.blockDefinitionIndex = 1;
			}
		}

		chunk.isLoaded = true;
		var key = chunk.getKey();
		// chunk.autoSaveAsKey(key);
		chunks.set(key, chunk);
		return chunk;
	}

	public function getChunkFromFile(saveId:String, levelId:String, chX:Int, chY:Int):Null<Chunk> {
		var key = Chunk.GetKey(saveId, levelId, chX, chY);
		if (saveExists(key) && !SaveModel.isBusyKey(key)) {
			trace("loading from file " + chX + "," + chY);
			var chunk = new Chunk(saveId, levelId, chX, chY);
			chunk.loadFromKey(key);
			return chunk;
		} else {
			trace("load file failed " + chX + "," + chY);
			return null;
		}
	}

	public function saveExists(key:String):Bool {
		var rawId = Tracker.backend.readString('save_id_1_' + key);
		var id = rawId != null ? Std.parseInt(rawId) : -1;
		if (id != 1 && id != 2) {
			rawId = Tracker.backend.readString('save_id_2_' + key);
			id = rawId != null ? Std.parseInt(rawId) : -1;
		}
		var saveExists = id == 1 || id == 2;
		return saveExists;
	}

	public function getOrGenerateChunk(saveId:String, levelId:String, chX:Int, chY:Int, pX:Int, pY:Int, seed:Int):Null<Chunk> {
		var key = Chunk.GetKey(saveId, levelId, chX, chY);
		if (chunks.exists(key)) {
			var chunk = chunks[key];
			return chunk;
		} else {
			var chunk:Chunk;
			if (saveExists(key)) {
				trace("getChunkFromFile " + chX + "," + chY);
				chunk = getChunkFromFile(saveId, levelId, chX, chY);
				if (chunk == null) {
					chunk = generateChunk(saveId, levelId, chX, chY, pX, pY, seed);
				}
			} else {
				chunk = generateChunk(saveId, levelId, chX, chY, pX, pY, seed);
			}
			chunks.set(key, chunk);

			return chunk;
		}
	}

	public function getCell(saveId:String, levelId:String, x:Int, y:Int, z:Int):Null<Cell> {
		var chX = Math.floor(x / 16);
		var chY = Math.floor(y / 16);
		var chunk = getOrGenerateChunk(saveId, levelId, chX, chY, x, y, 1337);
		if (chunk != null) {
			return chunk.cells[x % 16][y % 16][z];
		}
		return null;
	}
}
