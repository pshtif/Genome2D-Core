package com.genome2d.g3d;

import com.genome2d.fbx.GFbxTools;
import com.genome2d.fbx.GFbxParserNode;

class G3DTexture extends G3DNode {
    public var relativePath:String;

    public function new(p_id:String, p_relativePath:String):Void {
        super(p_id);

        relativePath = p_relativePath;
    }
}
