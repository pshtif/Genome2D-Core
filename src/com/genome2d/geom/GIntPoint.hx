package com.genome2d.geom;
import com.genome2d.proto.IGPrototypable;
class GIntPoint implements IGPrototypable {
    public var x:Int = 0;
    public var y:Int = 0;

    public function new(p_x:Int = 0, p_y:Int = 0) {
        x = p_x;
        y = p_y;
    }

    public function equals(p_point:GIntPoint):Bool {
        return x == p_point.x && y == p_point.y;
    }
}
