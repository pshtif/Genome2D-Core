package com.genome2d.fbx;

import com.genome2d.assets.GAssetManager;
import com.genome2d.context.GBlendMode;
import com.genome2d.context.stage3d.GProjectionMatrix;
import com.genome2d.context.stage3d.GStage3DContext;
import com.genome2d.context.stage3d.renderers.GFbxRenderer;
import com.genome2d.fbx.GFbxParserNode;
import com.genome2d.fbx.GFbxTools;

import com.genome2d.geom.GFloat4;
import com.genome2d.geom.GMatrix3D;
import com.genome2d.Genome2D;
import com.genome2d.context.IGContext;
import com.genome2d.textures.GTextureManager;

class GFbxScene {
    public var lightDirection:GFloat4;
    public var ambientColor:GFloat4;
    public var lightColor:GFloat4;
    public var tintColor:GFloat4;
	
    private var g2d_models:Array<GFbxModel>;
	public function getModelByName(p_name:String):GFbxModel {
		for (model in g2d_models) {
			if (model.name == p_name) return model;
		}
		return null;
	}
	
    private var g2d_fbxData:GFbxParserNode;
    private var g2d_nodes:Map<String,GFbxNode>;
	
	private var g2d_projectionMatrix:GProjectionMatrix;
	public function getProjectionMatrix():GProjectionMatrix {
		return g2d_projectionMatrix;
	}
	public function setProjectionMatrix(p_value:GProjectionMatrix):Void {
		g2d_projectionMatrix = p_value;
	}

    private var g2d_modelMatrix:GMatrix3D;
    public function getModelMatrix():GMatrix3D {
        return g2d_modelMatrix;
    }

    public function new() {
        g2d_nodes = new Map<String,GFbxNode>();

        lightDirection = new GFloat4(1,1,1,1);
        ambientColor = new GFloat4(1,1,1,1);
        tintColor = new GFloat4(1,1,1,1);
        lightColor = new GFloat4(1,1,1,1);
    }

    public function init(p_fbxData:GFbxParserNode):Void {
        g2d_fbxData = p_fbxData;

        initTextures();
        initMaterials();
        initModels();
        initGeometry();

        initConnections();

        create();
    }

    private function initTextures():Void {
        var textureNodes:Array<GFbxParserNode> = GFbxTools.getAll(g2d_fbxData, "Objects.Texture");
        for (node in textureNodes) {
            var texture:GFbxTexture = new GFbxTexture(node);
            g2d_nodes.set(texture.id, texture);
        }
    }

    private function initModels():Void {
        var modelNodes:Array<GFbxParserNode> = GFbxTools.getAll(g2d_fbxData, "Objects.Model");

        for (node in modelNodes) {
            var model:GFbxModel = new GFbxModel(node);
            g2d_nodes.set(model.id, model);
        }
    }

    private function initMaterials():Void {
        var materialNodes:Array<GFbxParserNode> = GFbxTools.getAll(g2d_fbxData, "Objects.Material");

        for (node in materialNodes) {
            var material:GFbxMaterial = new GFbxMaterial(node);
            g2d_nodes.set(material.id, material);
        }
    }

    private function initGeometry():Void {
        var geometryNodes:Array<GFbxParserNode> = GFbxTools.getAll(g2d_fbxData,"Objects.Geometry");

        for (node in geometryNodes) {
            var geometry:GFbxGeometry = new GFbxGeometry(node);

            g2d_nodes.set(geometry.id, geometry);
        }
    }

    private function initConnections():Void {
        var connectionNodes:Array<GFbxParserNode> = GFbxTools.getAll(g2d_fbxData, "Connections.C");

        for (node in connectionNodes) {
            var sourceId:String = Std.string(GFbxTools.toFloat(node.props[1]));
            var source:GFbxNode = g2d_nodes.get(sourceId);
            var destinationId:String = Std.string(GFbxTools.toFloat(node.props[2]));
            var destination:GFbxNode = g2d_nodes.get(destinationId);
            if (destination != null && source != null) {
                destination.connections.set(source.id, source);
            }
        }
    }

    private function create():Void {
        g2d_modelMatrix = new GMatrix3D();
        g2d_models = new Array<GFbxModel>();

        for (node in g2d_nodes) {
            var model:GFbxModel = (Std.is(node,GFbxModel)) ? cast node : null;
            if (model != null) {
				var fbxGeometry:GFbxGeometry = model.getGeometry();
				if (fbxGeometry == null) throw "Invalid model.";
				
				var fbxRenderer:GFbxRenderer = new GFbxRenderer(fbxGeometry.vertices, fbxGeometry.uvs, fbxGeometry.indices, fbxGeometry.vertexNormals, false);

				var fbxTexture:GFbxTexture = model.getMaterial().getTexture();
				if (fbxTexture == null) throw "Invalid texture.";

				fbxRenderer.texture = GTextureManager.getTexture(fbxTexture.relativePath.substring(0, fbxTexture.relativePath.lastIndexOf(".")));
				model.renderer = fbxRenderer;
				g2d_models.push(model);
            }
        }
    }

    public function render(p_cameraMatrix:GMatrix3D, p_type:Int = 1):Void {
		var renderer:GFbxRenderer;
        for (model in g2d_models) {
			if (model.visible) {
				renderer = model.renderer;
				renderer.lightDirection = lightDirection;
				renderer.ambientColor = ambientColor;
				renderer.lightColor = lightColor;
				renderer.tintColor = tintColor;
				renderer.modelMatrix = g2d_modelMatrix;
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

        }
    }
}
