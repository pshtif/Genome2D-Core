package com.genome2d.fbx;
import com.genome2d.fbx.GFbxTools;
import com.genome2d.fbx.GFbxParserNode;

class GFbxNode {
    public var id:String;
    public var name:String;

    public var connections:Map<String,GFbxNode>;

    public function new(p_fbxNode:GFbxParserNode) {
        id = Std.string(GFbxTools.toFloat(p_fbxNode.props[0]));
        name = GFbxTools.toString(p_fbxNode.props[1]);

        connections = new Map<String,GFbxNode>();
    }
}
