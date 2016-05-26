package com.genome2d.g3d;

import com.genome2d.assets.GAssetManager;
import com.genome2d.context.GBlendMode;
import com.genome2d.context.stage3d.GProjectionMatrix;
import com.genome2d.context.stage3d.GStage3DContext;
import com.genome2d.context.stage3d.renderers.G3DRenderer;
import com.genome2d.debug.GDebug;
import com.genome2d.fbx.GFbxParserNode;
import com.genome2d.fbx.GFbxTools;
import com.genome2d.macros.MGDebug;
import flash.utils.ByteArray;

import com.genome2d.geom.GFloat4;
import com.genome2d.geom.GMatrix3D;
import com.genome2d.Genome2D;
import com.genome2d.context.IGContext;
import com.genome2d.textures.GTextureManager;

class G3DScene {
    public var lightDirection:GFloat4;
    public var ambientColor:GFloat4;
    public var lightColor:GFloat4;
    public var tintColor:GFloat4;
	
    private var g2d_models:Array<G3DModel>;
	public function getModelByName(p_name:String):G3DModel {
		for (model in g2d_models) {
			if (model.name == p_name) return model;
		}
		return null;
	}
	
    private var g2d_nodes:Map<String,G3DNode>;
	public function addNode(p_id:String, p_node:G3DNode):Void {
		g2d_nodes.set(p_id, p_node);
	}
	public function getNode(p_id:String):G3DNode {
		return g2d_nodes.get(p_id);
	}
	
	private var g2d_sceneMatrix:GMatrix3D;
	public function getSceneMatrix():GMatrix3D {
		return g2d_sceneMatrix;
	}
	
	private var g2d_projectionMatrix:GProjectionMatrix;
	public function getProjectionMatrix():GProjectionMatrix {
		return g2d_projectionMatrix;
	}
	public function setProjectionMatrix(p_value:GProjectionMatrix):Void {
		g2d_projectionMatrix = p_value;
	}
	
	private var g2d_connections:Array<G3DConnection>;
	public function addConnection(p_sourceId:String, p_destinationId:String):Void {
		if (p_sourceId == "0" || p_destinationId == "0") return;
		var source:G3DNode = g2d_nodes.get(p_sourceId);
        var destination:G3DNode = g2d_nodes.get(p_destinationId);
		if (destination != null && source != null) {
			destination.connections.set(source.id, source);
			g2d_connections.push(new G3DConnection(p_sourceId, p_destinationId));
		} else {
			MGDebug.WARNING("Invalid connection", p_sourceId, p_destinationId, source, destination);
		}
	}

    public function new() {
        g2d_nodes = new Map<String,G3DNode>();
		g2d_connections = new Array<G3DConnection>();

        lightDirection = new GFloat4(1,1,1,1);
        ambientColor = new GFloat4(1,1,1,1);
        tintColor = new GFloat4(1,1,1,1);
        lightColor = new GFloat4(1,1,1,1);
    }
	
	public function exportBinary(p_byteArray:ByteArray):Void {
		for (node in g2d_nodes) {
			if (Std.is(node, G3DTexture)) {
				p_byteArray.writeByte(1);
				p_byteArray.writeUTF(node.id);
				var texture:G3DTexture = cast node;
				p_byteArray.writeUTF(texture.relativePath);
			}
			
			if (Std.is(node, G3DModel)) {
				p_byteArray.writeByte(2);
				p_byteArray.writeUTF(node.id);
			}
			
			if (Std.is(node, G3DMaterial)) {
				p_byteArray.writeByte(3);
				p_byteArray.writeUTF(node.id);
			}
			
			if (Std.is(node, G3DGeometry)) {
				p_byteArray.writeByte(4);
				p_byteArray.writeUTF(node.id);
				
				var geometry:G3DGeometry = cast node;
				p_byteArray.writeInt(geometry.vertices.length);
				for (i in 0...geometry.vertices.length) {
					p_byteArray.writeFloat(geometry.vertices[i]);
				}
				
				p_byteArray.writeInt(geometry.importedUvs.length);
				for (i in 0...geometry.importedUvs.length) {
					p_byteArray.writeFloat(geometry.importedUvs[i]);
				}
				
				p_byteArray.writeInt(geometry.importedIndices.length);
				for (i in 0...geometry.importedIndices.length) {
					p_byteArray.writeInt(geometry.importedIndices[i]);
				}
				
				p_byteArray.writeInt(geometry.importedUvIndices.length);
				for (i in 0...geometry.importedUvIndices.length) {
					p_byteArray.writeInt(geometry.importedUvIndices[i]);
				}
			}
		}
		
		var c:Int = 0;
		for (connection in g2d_connections) {
			p_byteArray.writeByte(5);
			p_byteArray.writeUTF(connection.sourceId);
			p_byteArray.writeUTF(connection.destinationId);
			c++;
		}
		trace(c);
	}
	
	public function importBinary(p_byteArray:ByteArray):Void {
		p_byteArray.position = 0;
		var c:Int = 0;
		while (p_byteArray.bytesAvailable > 0) {
			var type:Int = p_byteArray.readByte();
			switch (type) {
				case 1:
					var id:String = p_byteArray.readUTF();
					var relativePath:String = p_byteArray.readUTF();
					var texture:G3DTexture = new G3DTexture(id, relativePath);
					addNode(texture.id, texture);
				case 2:
					var id:String = p_byteArray.readUTF();
					var model:G3DModel = new G3DModel(id);
					addNode(model.id, model);
				case 3:
					var id:String = p_byteArray.readUTF();
					var material:G3DMaterial = new G3DMaterial(id);
					addNode(material.id, material);
				case 4:
					var id:String = p_byteArray.readUTF();
					var count:Int = p_byteArray.readInt();
					var vertices:Array<Float> = new Array<Float>();
					for (i in 0...count) {
						vertices.push(p_byteArray.readFloat());
					}
					var count:Int = p_byteArray.readInt();
					var uvs:Array<Float> = new Array<Float>();
					for (i in 0...count) {
						uvs.push(p_byteArray.readFloat());
					}
					
					var count:Int = p_byteArray.readInt();
					var indices:Array<Int> = new Array<Int>();
					for (i in 0...count) {
						indices.push(p_byteArray.readInt());
					}
					
					var count:Int = p_byteArray.readInt();
					var uvIndices:Array<Int> = new Array<Int>();
					for (i in 0...count) {
						uvIndices.push(p_byteArray.readInt());
					}
					var geometry:G3DGeometry = new G3DGeometry(id, vertices, null, uvs, indices, uvIndices);
					addNode(geometry.id, geometry);
				case 5:
					var sourceId:String = p_byteArray.readUTF();
					var destinationId:String = p_byteArray.readUTF();
					addConnection(sourceId, destinationId);			
					c++;
			}
		}
		
		trace(c);
		
		create();
	}

    private function create():Void {
		g2d_sceneMatrix = new GMatrix3D();
        g2d_models = new Array<G3DModel>();

        for (node in g2d_nodes) {
            var model:G3DModel = (Std.is(node,G3DModel)) ? cast node : null;
            if (model != null) {
				trace("here");
				var geometry:G3DGeometry = model.getGeometry();
				if (geometry == null) MGDebug.G2D_ERROR("Model has no geometry.");
				
				var renderer:G3DRenderer = new G3DRenderer(geometry.vertices, geometry.uvs, geometry.indices, geometry.vertexNormals, false);
				var material:G3DMaterial = model.getMaterial();
				if (material == null) MGDebug.G2D_ERROR("Model has no material.");
				
				var texture:G3DTexture = model.getMaterial().getTexture();
				if (texture == null) MGDebug.G2D_ERROR("Model material has no texture.");
				
				renderer.texture = GTextureManager.getTexture(texture.relativePath.substring(texture.relativePath.lastIndexOf("\\") + 1, texture.relativePath.lastIndexOf(".")));
				if (renderer.texture == null) MGDebug.G2D_ERROR("Couldn't find FBX texture ", texture.relativePath.substring(texture.relativePath.lastIndexOf("\\") + 1, texture.relativePath.lastIndexOf(".")));
				
				model.renderer = renderer;
				g2d_models.push(model);
            }
        }
    }

    public function render(p_cameraMatrix:GMatrix3D, p_type:Int = 1):Void {
		var renderer:G3DRenderer;
        for (model in g2d_models) {
			if (model.visible) {
				renderer = model.renderer;
				renderer.lightDirection = lightDirection;
				renderer.ambientColor = ambientColor;
				renderer.lightColor = lightColor;
				renderer.tintColor = tintColor;
				switch (model.inheritSceneMatrixMode) {
					case G3DMatrixInheritMode.REPLACE:
						renderer.renderMatrix = g2d_sceneMatrix;
					case G3DMatrixInheritMode.IGNORE:
						renderer.renderMatrix = model.modelMatrix;
					case G3DMatrixInheritMode.APPEND:
						renderer.renderMatrix = model.modelMatrix.clone();
						renderer.renderMatrix.append(g2d_sceneMatrix);
				}
				renderer.cameraMatrix = p_cameraMatrix;
				renderer.projectionMatrix = g2d_projectionMatrix;
			}
        }		
		
		var context:GStage3DContext = cast Genome2D.getInstance().getContext();
        context.setBlendMode(GBlendMode.NORMAL, true);
		
        switch (p_type) {
			// Unlit
			case 0:
                for (model in g2d_models) {
					if (model.visible) {
						renderer = model.renderer;
						context.setRenderer(renderer);
						renderer.draw(2, 0);
					}
                }
            // Normal
            case 1:
                for (model in g2d_models) {
					if (model.visible) {
						renderer = model.renderer;
						context.setRenderer(renderer);
						renderer.draw(2, 1);
					}
                }
            // Reflection
            case 2:
                for (model in g2d_models) {
					if (model.visible) {
						renderer = model.renderer;
						context.setRenderer(renderer);
						renderer.draw(1, 1);
					}
                }
            // Shadow
            case 3:
                for (model in g2d_models) {
					if (model.visible) {
						renderer = model.renderer;
						context.setRenderer(renderer);
						renderer.draw(1, 2);
					}
                }
            // Invisible
            case 4:
                for (model in g2d_models) {
					if (model.visible) {
						renderer = model.renderer;
						context.setRenderer(renderer);
						renderer.tintColor.w = 0;
						renderer.draw(2, 1);
						renderer.tintColor.w = 0;
					}
                }
			// Depth reflection
            case 5:
                for (model in g2d_models) {
					if (model.visible) {
						renderer = model.renderer;
						context.setRenderer(renderer);
						renderer.draw(1, 3);
					}
                }

        }
    }
}

class G3DConnection {
    public var sourceId:String;
    public var destinationId:String;
	
	public function new(p_sourceId:String, p_destinationId:String) {
		sourceId = p_sourceId;
		destinationId = p_destinationId;
	}
}