package com.genome2d.g3d;

class G3DMaterial extends G3DNode {
	
    public function getTexture():G3DTexture {
        for (connection in connections) {
            if (Std.is(connection, G3DTexture)) return cast connection;
        }
		
        return null;
    }

    public function new(p_id:String):Void {
        super(p_id);
    }
}
