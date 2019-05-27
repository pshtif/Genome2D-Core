package com.genome2d.g3d;

class G3DNode {
    public var id:String;
    public var name:String;

    public var connections:Map<String,G3DNode>;

    public function new(p_id:String) {
        id = p_id;
        name = "";

        connections = new Map<String,G3DNode>();
    }
}
