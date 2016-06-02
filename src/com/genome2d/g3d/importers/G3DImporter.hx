package com.genome2d.g3d.importers;
import com.genome2d.g3d.G3DScene;
import com.genome2d.macros.MGDebug;
import haxe.io.BytesData;

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
	override public function exportScene(p_scene:G3DScene, p_data:BytesData):Void {
		p_data.writeInt(g2d_version);
		for (node in p_scene.g2d_nodes) {
			if (Std.is(node, G3DTexture)) {
				p_data.writeByte(1);
				p_data.writeUTF(node.id);
				var texture:G3DTexture = cast node;
				p_data.writeUTF(texture.relativePath);
			}
			
			if (Std.is(node, G3DModel)) {
				p_data.writeByte(2);
				p_data.writeUTF(node.id);
				p_data.writeUTF(node.name);
			}
			
			if (Std.is(node, G3DMaterial)) {
				p_data.writeByte(3);
				p_data.writeUTF(node.id);
			}
			
			if (Std.is(node, G3DGeometry)) {
				p_data.writeByte(4);
				p_data.writeUTF(node.id);
				
				var geometry:G3DGeometry = cast node;
				p_data.writeInt(geometry.vertices.length);
				for (i in 0...geometry.vertices.length) {
					p_data.writeFloat(geometry.vertices[i]);
				}
				
				if (processed) {
					p_data.writeInt(geometry.uvs.length);
					for (i in 0...geometry.uvs.length) {
						p_data.writeFloat(geometry.uvs[i]);
					}
				} else {
					p_data.writeInt(geometry.importedUvs.length);
					for (i in 0...geometry.importedUvs.length) {
						p_data.writeFloat(geometry.importedUvs[i]);
					}
				}
				
				if (processed) {
					p_data.writeInt(geometry.indices.length);
					for (i in 0...geometry.indices.length) {
						p_data.writeInt(geometry.indices[i]);
					}
				} else {
					p_data.writeInt(geometry.importedIndices.length);
					for (i in 0...geometry.importedIndices.length) {
						p_data.writeInt(geometry.importedIndices[i]);
					}
				}
				
				if (processed) {
					p_data.writeInt(geometry.vertexNormals.length);
					for (i in 0...geometry.vertexNormals.length) {
						p_data.writeFloat(geometry.vertexNormals[i]);
					}
				} else {
					p_data.writeInt(geometry.importedUvIndices.length);
					for (i in 0...geometry.importedUvIndices.length) {
						p_data.writeInt(geometry.importedUvIndices[i]);
					}
				}
			}
		}
		
		var c:Int = 0;
		for (connection in p_scene.g2d_connections) {
			p_data.writeByte(5);
			p_data.writeUTF(connection.sourceId);
			p_data.writeUTF(connection.destinationId);
			c++;
		}
	}
	
	override public function importScene(p_data:BytesData):G3DScene {
		var scene:G3DScene = new G3DScene();
		p_data.position = 0;
		
		var version:Int = p_data.readInt();
		if (version != g2d_version) MGDebug.G2D_ERROR("G3D format version not compatible.");
		
		while (p_data.bytesAvailable > 0) {
			var type:Int = p_data.readByte();
			switch (type) {
				case 1:
					var id:String = p_data.readUTF();
					var relativePath:String = p_data.readUTF();
					var texture:G3DTexture = new G3DTexture(id, relativePath);
					scene.addNode(texture.id, texture);
				case 2:
					var id:String = p_data.readUTF();
					var model:G3DModel = new G3DModel(id);
					model.name = p_data.readUTF();
					scene.addNode(model.id, model);
				case 3:
					var id:String = p_data.readUTF();
					var material:G3DMaterial = new G3DMaterial(id);
					scene.addNode(material.id, material);
				case 4:
					var id:String = p_data.readUTF();
					var count:Int = p_data.readInt();
					var vertices:Array<Float> = new Array<Float>();
					for (i in 0...count) {
						vertices.push(p_data.readFloat());
					}
					var count:Int = p_data.readInt();
					var uvs:Array<Float> = new Array<Float>();
					for (i in 0...count) {
						uvs.push(p_data.readFloat());
					}
					
					var count:Int = p_data.readInt();
					var indices:Array<UInt> = new Array<UInt>();
					for (i in 0...count) {
						indices.push(p_data.readInt());
					}
					
					var count:Int = p_data.readInt();
					var normals:Array<Float> = new Array<Float>();
					var uvIndices:Array<Int> = new Array<Int>();
					if (processed) {
						for (i in 0...count) {
							normals.push(p_data.readFloat());
						}
					} else {
						for (i in 0...count) {
							uvIndices.push(p_data.readInt());
						}
					}
					var geometry:G3DGeometry = new G3DGeometry(id);
					if (processed) {
						geometry.initProcessed(vertices, uvs, indices, normals);
					} else {
						geometry.initImported(vertices, uvs, indices, uvIndices);
					}
					scene.addNode(geometry.id, geometry);
				case 5:
					var sourceId:String = p_data.readUTF();
					var destinationId:String = p_data.readUTF();
					scene.addConnection(sourceId, destinationId);			
			}
		}
		
		return scene;
	}
	
}