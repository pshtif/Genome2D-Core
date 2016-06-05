package com.genome2d.g3d;

import com.genome2d.assets.GAssetManager;
import com.genome2d.context.GBlendMode;
import com.genome2d.context.GProjectionMatrix;
import com.genome2d.context.GStage3DContext;
import com.genome2d.context.renderers.G3DRenderer;
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

    public function invalidate():Void {
		g2d_sceneMatrix = new GMatrix3D();
        g2d_models = new Array<G3DModel>();

        for (node in g2d_nodes) {
            var model:G3DModel = (Std.is(node,G3DModel)) ? cast node : null;
            if (model != null) {
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