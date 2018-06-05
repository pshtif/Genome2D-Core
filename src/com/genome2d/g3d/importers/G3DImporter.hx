package com.genome2d.g3d.importers;
import com.genome2d.utils.GBytes;
import com.genome2d.g3d.G3DScene;
import com.genome2d.macros.MGDebug;
import haxe.io.Bytes;

/**
 * @author Peter @sHTiF Stefcek
 */
class G3DImporter extends G3DAbstractImporter
{
	inline static private var g2d_version:Int = 102;
	
	public var processed:Bool = false;
	
	public function new(p_processed:Bool = false) {
		super();
		processed = p_processed;
	}
	
	@:access(com.genome2d.g3d.G3DScene)
	override public function exportScene(p_scene:G3DScene, p_data:Bytes):Void {
		var wrap:GBytes = new GBytes(p_data);
		wrap.writeInt(g2d_version);
		for (node in p_scene.g2d_nodes) {
			if (Std.is(node, G3DTexture)) {
				wrap.writeByte(1);
				wrap.writeUTF(node.id);
				var texture:G3DTexture = cast node;
				wrap.writeUTF(texture.relativePath);
			}
			
			if (Std.is(node, G3DModel)) {
				wrap.writeByte(2);
				wrap.writeUTF(node.id);
				wrap.writeUTF(node.name);
			}
			
			if (Std.is(node, G3DMaterial)) {
				wrap.writeByte(3);
				wrap.writeUTF(node.id);
			}
			
			if (Std.is(node, G3DGeometry)) {
				wrap.writeByte(4);
				wrap.writeUTF(node.id);
				
				var geometry:G3DGeometry = cast node;
				wrap.writeInt(geometry.vertices.length);
				for (i in 0...geometry.vertices.length) {
					wrap.writeFloat(geometry.vertices[i]);
				}
				
				if (processed) {
					wrap.writeInt(geometry.uvs.length);
					for (i in 0...geometry.uvs.length) {
						wrap.writeFloat(geometry.uvs[i]);
					}
				} else {
					wrap.writeInt(geometry.importedUvs.length);
					for (i in 0...geometry.importedUvs.length) {
						wrap.writeFloat(geometry.importedUvs[i]);
					}
				}
				
				if (processed) {
					wrap.writeInt(geometry.indices.length);
					for (i in 0...geometry.indices.length) {
						wrap.writeInt(geometry.indices[i]);
					}
				} else {
					wrap.writeInt(geometry.importedIndices.length);
					for (i in 0...geometry.importedIndices.length) {
						wrap.writeInt(geometry.importedIndices[i]);
					}
				}
				
				wrap.writeInt(geometry.normals.length);
				for (i in 0...geometry.normals.length) {
					wrap.writeFloat(geometry.normals[i]);
				}
				
				if (!processed) {
					wrap.writeInt(geometry.importedUvIndices.length);
					for (i in 0...geometry.importedUvIndices.length) {
						wrap.writeInt(geometry.importedUvIndices[i]);
					}
				}
			}
		}
		
		var c:Int = 0;
		for (connection in p_scene.g2d_connections) {
			wrap.writeByte(5);
			wrap.writeUTF(connection.sourceId);
			wrap.writeUTF(connection.destinationId);
			c++;
		}
	}
	
	public function getSceneSize(p_scene:G3DScene):Void {
		var size:Int = 0;
	}

	override public function importScene(p_data:Bytes):G3DScene {
		var scene:G3DScene = new G3DScene();

		var wrap:GBytes = new GBytes(p_data);
		var version:Int = wrap.readInt();
		if (version != g2d_version) MGDebug.G2D_ERROR("G3D format version not compatible.");

		while (wrap.getBytesAvailable() > 0) {
			var type:Int = wrap.readByte();
			switch (type) {
				case 1:
					var id:String = wrap.readUTF();
					var relativePath:String = wrap.readUTF();
					var texture:G3DTexture = new G3DTexture(id, relativePath);
					scene.addNode(texture.id, texture);
				case 2:
					var id:String = wrap.readUTF();
					var model:G3DModel = new G3DModel(id);
					model.name = wrap.readUTF();
					scene.addNode(model.id, model);
				case 3:
					var id:String = wrap.readUTF();
					var material:G3DMaterial = new G3DMaterial(id);
					scene.addNode(material.id, material);
				case 4:
					var id:String = wrap.readUTF();
					var count:Int = wrap.readInt();
					var vertices:Array<Float> = new Array<Float>();
					for (i in 0...count) {
						vertices.push(wrap.readFloat());
					}
					var count:Int = wrap.readInt();
					var uvs:Array<Float> = new Array<Float>();
					for (i in 0...count) {
						uvs.push(wrap.readFloat());
					}
					
					var count:Int = wrap.readInt();
					var indices:Array<UInt> = new Array<UInt>();
					for (i in 0...count) {
						indices.push(wrap.readInt());
					}
					
					var count:Int = wrap.readInt();
					var normals:Array<Float> = new Array<Float>();
					for (i in 0...count) {
						normals.push(wrap.readFloat());
					}
					
					var uvIndices:Array<Int> = new Array<Int>();
					if (!processed) {
						var count:Int = wrap.readInt();
						for (i in 0...count) {
							uvIndices.push(wrap.readInt());
						}
					}
					
					var geometry:G3DGeometry = new G3DGeometry(id);
					if (processed) {
						geometry.initProcessed(vertices, uvs, indices, normals);
					} else {
						geometry.initImported(vertices, uvs, indices, uvIndices, normals);
					}
					scene.addNode(geometry.id, geometry);
				case 5:
					var sourceId:String = wrap.readUTF();
					var destinationId:String = wrap.readUTF();
					scene.addConnection(sourceId, destinationId);			
			}
		}
		
		return scene;
	}
	
}