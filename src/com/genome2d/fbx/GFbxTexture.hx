package com.genome2d.fbx;

import com.genome2d.fbx.GFbxTools;
import com.genome2d.fbx.GFbxParserNode;

class GFbxTexture extends GFbxNode {
    public var relativePath:String;

    public function new(p_fbxNode:GFbxParserNode):Void {
        super(p_fbxNode);

        relativePath = GFbxTools.toString(GFbxTools.get(p_fbxNode, "RelativeFilename", true).props[0]);
    }
}
