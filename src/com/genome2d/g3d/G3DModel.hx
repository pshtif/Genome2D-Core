package com.genome2d.g3d;

import com.genome2d.context.renderers.G3DRenderer;
import com.genome2d.geom.GMatrix3D;

class G3DModel extends G3DNode {
	public var visible:Bool = true;
	
	public var renderer:G3DRenderer;
	
	public var inheritSceneMatrixMode:Int = G3DMatrixInheritMode.REPLACE;
	public var modelMatrix:GMatrix3D;
	
	public function new(p_id:String):Void {
		super(p_id);
		
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
}
