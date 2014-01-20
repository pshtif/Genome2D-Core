package com.genome2d.signals;
import com.genome2d.node.GNode;
class GNodeMouseSignal {
    public var target:GNode;
    public var dispatcher:GNode;
    public var type:String;

    public var localX:Float;
    public var localY:Float;

    public function new(p_type:String, p_target:GNode, p_dispatcher:GNode, p_localX:Float, p_localY:Float, p_contextSignal:GMouseSignal) {
        type = p_type;
        target = p_target;
        dispatcher = p_dispatcher;

        localX = p_localX;
        localY = p_localY;
    }
}
