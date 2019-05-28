package com.genome2d.g3d;
import com.genome2d.textures.GTexture;

/**
 * @author Peter @sHTiF Stefcek
 */
@:access(com.genome2d.g3d.G3DScene)
class G3DFactory
{
	static private var g2d_ids:Int = 0;
	static public function createBox(p_width:Float, p_height:Float, p_depth:Float, p_texture:GTexture):G3DScene {
		var id:String = Std.string(g2d_ids++);
		var scene:G3DScene = new G3DScene();

		var texture:G3DTexture = new G3DTexture("gte"+id, p_texture.id);
		scene.addNode(texture.id, texture);
		
		var material:G3DMaterial = new G3DMaterial("gma" + id);
		scene.addNode(material.id, material);
		
		var model:G3DModel = new G3DModel("gmo"+id);
		scene.addNode(model.id, model);
		
		var vertices:Array<Float> = [ -p_width / 2, -p_height / 2, -p_depth / 2, -p_width / 2, p_height / 2, -p_depth / 2, p_width / 2, -p_height / 2, -p_depth / 2, p_width / 2, p_height / 2, -p_depth / 2,
									  -p_width / 2, -p_height / 2, p_depth / 2, -p_width / 2, p_height / 2, p_depth / 2, p_width / 2, -p_height / 2, p_depth / 2, p_width / 2, p_height / 2, p_depth / 2,
									  -p_width / 2, -p_height / 2, p_depth / 2, -p_width / 2, -p_height / 2, -p_depth / 2, -p_width / 2, p_height / 2, p_depth / 2, -p_width / 2, p_height / 2, -p_depth / 2,
									  p_width / 2, -p_height / 2, p_depth / 2, p_width / 2, -p_height / 2, -p_depth / 2, p_width / 2, p_height / 2, p_depth / 2, p_width / 2, p_height / 2, -p_depth / 2,
									  -p_width / 2, -p_height / 2, p_depth / 2, p_width / 2, -p_height / 2, p_depth / 2, -p_width / 2, -p_height / 2, -p_depth / 2, p_width / 2, -p_height / 2, -p_depth / 2,
									  -p_width / 2, p_height / 2, p_depth / 2, p_width / 2, p_height / 2, p_depth / 2, -p_width / 2, p_height / 2, -p_depth / 2, p_width / 2, p_height / 2, -p_depth / 2];
		var uvs:Array<Float> = [ 0, 0, 1, 0, 0, 1, 1, 1,
								 0, 0, 1, 0, 0, 1, 1, 1,
								 0, 0, 1, 0, 0, 1, 1, 1,
								 0, 0, 1, 0, 0, 1, 1, 1,
								 0, 0, 1, 0, 0, 1, 1, 1,
								 0, 0, 1, 0, 0, 1, 1, 1];

		var normals:Array<Float> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
									0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
									0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
									0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
									0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
									0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];


		var indices:Array<UInt> = [0, 1, 2, 2, 1, 3,
								   4, 6, 5, 5, 6, 7,
								   8, 10, 9, 9, 10, 11,
								   12, 13, 14, 14, 13, 15,
								   16, 18, 17, 17, 18, 19,
								   20, 21, 22, 22, 21, 23];
		
		var geometry:G3DGeometry = new G3DGeometry("gge"+id);
		geometry.initProcessed(vertices, uvs, indices, normals);
		scene.addNode(geometry.id, geometry);
		
		scene.addConnection(geometry.id, model.id);
		scene.addConnection(material.id, model.id);
		scene.addConnection(texture.id, material.id);
		
		return scene;
	}

	static public function createPlane(p_width:Float, p_height:Float, p_texture:GTexture):G3DScene {
		var id:String = Std.string(g2d_ids++);
		var scene:G3DScene = new G3DScene();

		var texture:G3DTexture = new G3DTexture("gte"+id, p_texture.id);
		scene.addNode(texture.id, texture);
		
		var material:G3DMaterial = new G3DMaterial("gma" + id);
		scene.addNode(material.id, material);
		
		var model:G3DModel = new G3DModel("gmo"+id);
		scene.addNode(model.id, model);
		
		var vertices:Array<Float> = [ -p_width / 2, -p_height / 2, 0, -p_width / 2, p_height / 2, 0, p_width / 2, -p_height / 2, 0, p_width / 2, p_height / 2, 0];
		var uvs:Array<Float> = [ 0, 0, 1, 0, 0, 1, 1, 1];

		var normals:Array<Float> = [0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0, -1];


		var indices:Array<UInt> = [0, 1, 2, 2, 1, 3];
		
		var geometry:G3DGeometry = new G3DGeometry("gge"+id);
		geometry.initProcessed(vertices, uvs, indices, normals);
		scene.addNode(geometry.id, geometry);
		
		scene.addConnection(geometry.id, model.id);
		scene.addConnection(material.id, model.id);
		scene.addConnection(texture.id, material.id);
		
		return scene;
	}
}