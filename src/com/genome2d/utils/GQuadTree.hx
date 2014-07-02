/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.utils;

import com.genome2d.geom.GRectangle;
import com.genome2d.utils.GQuadTreeNode;

class GQuadTree {
    private var g2d_root:GQuadTreeNode;

    private var g2d_left:Float;
    private var g2d_top:Float;
    private var g2d_right:Float;
    private var g2d_bottom:Float;

    private var g2d_map:Map<Dynamic,GQuadTreeNode>;

    public function new(p_x:Float, p_y:Float, p_width:Float, p_height:Float) {
        g2d_left = p_x;
        g2d_top = p_y;
        g2d_right = p_x+p_width;
        g2d_bottom = p_y+p_height;

        g2d_root = new GQuadTreeNode(g2d_left, g2d_top, g2d_right, g2d_bottom);

        g2d_map = new Map<Dynamic,GQuadTreeNode>();
    }

    public function add(p_object:Dynamic, p_left:Float, p_top:Float, p_right:Float, p_bottom:Float):Bool {
        var node:GQuadTreeNode = g2d_root.add(p_object, p_left, p_top, p_right, p_bottom);

        if (node != null) {
            g2d_map.set(p_object, node);
        }

        return node != null;
    }

    public function remove(p_object:Dynamic):Bool {
        var node:GQuadTreeNode = g2d_map.get(object);

        if (node == null) return false;

        node.remove(p_object);

        g2d_map.remove(p_object);

        return true;
    }

    public function getObjectsInBounds(p_bounds:GRectangle, p_result:Array<Dynamic>):Void {
        g2d_root.getObjectsInBounds(p_bounds.x, p_bounds.y, p_bounds.right, p_bounds.bottom, p_result);
    }
}