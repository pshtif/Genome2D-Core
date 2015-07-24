package com.genome2d.fbx;
import com.genome2d.fbx.GFbxTools;
import com.genome2d.fbx.GFbxParserNode;

class GFbxMaterial extends GFbxNode {
	
    public function getTexture():GFbxTexture {
        for (connection in connections) {
            if (Std.is(connection, GFbxTexture)) return cast connection;
        }
        return null;
    }

    public function new(p_fbxNode:GFbxParserNode):Void {
        super(p_fbxNode);
    }
}
