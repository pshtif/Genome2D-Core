package com.genome2d.g3d;

import com.genome2d.context.renderers.G3DRenderer;
import com.genome2d.geom.GMatrix3D;
import com.genome2d.geom.GVector3D;
import com.genome2d.macros.MGDebug;
import com.genome2d.textures.GTextureManager;
import com.genome2d.debug.GDebug;

class G3DModel extends G3DNode {
	public var visible:Bool = true;
	
	public var renderer:G3DRenderer;
	
	public var inheritSceneMatrixMode:G3DMatrixInheritMode = G3DMatrixInheritMode.REPLACE;
	public var modelMatrix:GMatrix3D;
	public var transparent:Bool = false;
	public var center:GVector3D;
	
	public function new(p_id:String):Void {
		super(p_id);
		
		center = new GVector3D();
		modelMatrix = new GMatrix3D();
	}
	
    public function getGeometry():G3DGeometry {
        for (connection in connections) {
            if (Std.is(connection, G3DGeometry)) return cast connection;
            if (Std.is(connection, G3DModel)) return cast(connection,G3DModel).getGeometry();
        }
        return null;
    }

    public function getMaterial():G3DMaterial {
        for (connection in connections) {
            if (Std.is(connection, G3DMaterial)) return cast connection;
            if (Std.is(connection, G3DModel)) return cast(connection,G3DModel).getMaterial();
        }
        return null;
    }
	
	public function dispose():Void {
		if (renderer != null) renderer.dispose();
		renderer = null;
	}
	
	public function invalidate():Void {
		// Hack to check for transparency based on name suffix
		transparent = name.indexOf("_T") == name.length - 2;
		
		var geometry:G3DGeometry = getGeometry();
		if (geometry == null) MGDebug.G2D_ERROR("Model has no geometry.");
		
		if (renderer == null) {
			renderer = new G3DRenderer(geometry.vertices, geometry.uvs, geometry.indices, geometry.normals, false);
		} else {
			renderer.invalidateGeometry(geometry.vertices, geometry.uvs, geometry.indices, geometry.normals);
		}
		
		
		var material:G3DMaterial = getMaterial();
		if (material == null) MGDebug.G2D_ERROR("Model has no material.");
		
		var texture:G3DTexture = getMaterial().getTexture();
		if (texture == null) {
			MGDebug.WARNING("Model material has no texture.");
			renderer.texture = GTextureManager.getTexture("g2d_internal");
		} else {				
			var textureId:String = texture.relativePath;
			renderer.texture = GTextureManager.getTexture(textureId);
			if (renderer.texture == null) {
				MGDebug.WARNING("Couldn't find texture", textureId);
				renderer.texture = GTextureManager.getTexture("g2d_internal");
			}
		}
	}
	
	public function calculateCenter():Void {
		center = new GVector3D();
		var vertices:Array<Float> = getGeometry().vertices;
		for (i in 0...Std.int(vertices.length/3)) {
			center.x += vertices[i * 3];
			center.y += vertices[i * 3 + 1];
			center.z += vertices[i * 3 + 2];
		}
		center.x /= vertices.length;
		center.y /= vertices.length;
		center.z /= vertices.length;
	}
}
