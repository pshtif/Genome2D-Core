package com.genome2d.fbx;

import com.genome2d.context.renderers.G3DRenderer;
import com.genome2d.fbx.GFbxTools;
import com.genome2d.geom.GMatrix3D;

class GFbxModel extends GFbxNode {
	public var visible:Bool = true;
	
	public var renderer:G3DRenderer;
	
	public var inheritSceneMatrixMode:Int = GFbxMatrixInheritMode.REPLACE;
	public var modelMatrix:GMatrix3D;
	
	public function new(p_fbxNode:GFbxParserNode):Void {
		super(p_fbxNode);
		
		modelMatrix = new GMatrix3D();
	}
	
    public function getGeometry():GFbxGeometry {
        for (connection in connections) {
            if (Std.is(connection, GFbxGeometry)) return cast connection;
            if (Std.is(connection, GFbxModel)) return cast(connection,GFbxModel).getGeometry();
        }
        return null;
    }

    public function getMaterial():GFbxMaterial {
        for (connection in connections) {
            if (Std.is(connection, GFbxMaterial)) return cast connection;
            if (Std.is(connection, GFbxModel)) return cast(connection,GFbxModel).getMaterial();
        }
        return null;
    }
}
