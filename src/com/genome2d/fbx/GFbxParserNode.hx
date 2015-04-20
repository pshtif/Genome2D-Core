package com.genome2d.fbx;

typedef GFbxParserNode = {
    var name : String;
    var props : Array<GFbxTools.FbxProp>;
    var childs : Array<GFbxParserNode>;
}
