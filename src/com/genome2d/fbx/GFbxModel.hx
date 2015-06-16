package com.genome2d.fbx;

import com.genome2d.context.stage3d.renderers.GFbxRenderer;
import com.genome2d.fbx.GFbxTools;

class GFbxModel extends GFbxNode {
	public var visible:Bool = true;
	
	public var renderer:GFbxRenderer;
	
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
