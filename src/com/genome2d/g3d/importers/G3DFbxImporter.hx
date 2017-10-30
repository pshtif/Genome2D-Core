package com.genome2d.g3d.importers;

import com.genome2d.fbx.GFbxParser;
import com.genome2d.fbx.GFbxParserNode;
import com.genome2d.fbx.GFbxTools;
import com.genome2d.g3d.G3DScene;
import com.genome2d.g3d.G3DTexture;
import haxe.io.BytesData;
import haxe.io.Bytes;

/**
 * @author Peter @sHTiF Stefcek
 */
class G3DFbxImporter extends G3DAbstractImporter
{
	override public function importScene(p_data:Bytes):G3DScene {
		var scene:G3DScene = new G3DScene();

		var fbxData:GFbxParserNode = GFbxParser.parse(p_data.getString(0, p_data.length));
		
		g2d_initTextures(scene, fbxData);
		g2d_initModels(scene, fbxData);
		g2d_initMaterials(scene, fbxData);
		g2d_initGeometry(scene, fbxData);
		
		g2d_initConnections(scene, fbxData);
		
		return scene;
	}
	
	private function g2d_initTextures(p_scene:G3DScene, p_fbxData:GFbxParserNode):Void {
        var textureNodes:Array<GFbxParserNode> = GFbxTools.getAll(p_fbxData, "Objects.Texture");
        for (node in textureNodes) {
			var id:String = Std.string(GFbxTools.toFloat(node.props[0]));
			var relativePathNode:GFbxParserNode = GFbxTools.get(node, "RelativeFilename", true);
			var relativePath:String = GFbxTools.toString(relativePathNode.props[0]);	
			
            var texture:G3DTexture = new G3DTexture(id, relativePath);
            p_scene.addNode(texture.id, texture);
        }
    }
	
	private function g2d_initModels(p_scene:G3DScene, p_fbxData:GFbxParserNode):Void {
        var modelNodes:Array<GFbxParserNode> = GFbxTools.getAll(p_fbxData, "Objects.Model");

        for (node in modelNodes) {
			var id:String = Std.string(GFbxTools.toFloat(node.props[0]));
			
            var model:G3DModel = new G3DModel(id);
			model.name = GFbxTools.toString(node.props[1]);
			p_scene.addNode(model.id, model);
        }
    }
	
	private function g2d_initMaterials(p_scene:G3DScene, p_fbxData:GFbxParserNode):Void {
        var materialNodes:Array<GFbxParserNode> = GFbxTools.getAll(p_fbxData, "Objects.Material");

        for (node in materialNodes) {
			var id:String = Std.string(GFbxTools.toFloat(node.props[0]));
			
            var material:G3DMaterial = new G3DMaterial(id);
            p_scene.addNode(material.id, material);
        }
    }
	
	private function g2d_initGeometry(p_scene:G3DScene, p_fbxData:GFbxParserNode):Void {
        var geometryNodes:Array<GFbxParserNode> = GFbxTools.getAll(p_fbxData,"Objects.Geometry");

        for (node in geometryNodes) {
			var id:String = Std.string(GFbxTools.toFloat(node.props[0]));
			
			var vertexNode:GFbxParserNode = GFbxTools.getAll(node,"Vertices")[0];
			var vertexIndexNode:GFbxParserNode = GFbxTools.getAll(node,"PolygonVertexIndex")[0];

			var uvNode:GFbxParserNode = GFbxTools.getAll(node,"LayerElementUV.UV")[0];
			var uvIndexNode:GFbxParserNode = GFbxTools.getAll(node, "LayerElementUV.UVIndex")[0];
			
			var vertices:Array<Float> = GFbxTools.getFloats(vertexNode);
			
			// TODO normal usage?
			//var normalsNode:GFbxParserNode = GFbxTools.getAll(node, "LayerElementNormal.Normals")[0];
			//var normals:Array<Float> = GFbxTools.getFloats(normalsNode);
			
			var indices:Array<UInt> = cast GFbxTools.getInts(vertexIndexNode);
			var uvs:Array<Float> = GFbxTools.getFloats(uvNode);
			var uvIndices:Array<Int> = GFbxTools.getInts(uvIndexNode);
			
            var geometry:G3DGeometry = new G3DGeometry(id);
			geometry.initImported(vertices, uvs, indices, uvIndices);
            p_scene.addNode(geometry.id, geometry);
        }
    }
	
	private function g2d_initConnections(p_scene:G3DScene, p_fbxData:GFbxParserNode):Void {
        var connectionNodes:Array<GFbxParserNode> = GFbxTools.getAll(p_fbxData, "Connections.C");

        for (node in connectionNodes) {
            var sourceId:String = Std.string(GFbxTools.toFloat(node.props[1]));
            var destinationId:String = Std.string(GFbxTools.toFloat(node.props[2]));
			p_scene.addConnection(sourceId, destinationId);
        }
    }
	
}