/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.utils;

class GQuadTreeNode {
    static private var MIN_WIDTH:Int = 100;
    static private var MIN_HEIGHT:Int = 100;

    private var g2d_left:Float;
    private var g2d_right:Float;
    private var g2d_top:Float;
    private var g2d_bottom:Float;
    private var g2d_width:Float;
    private var g2d_height:Float;

    private var g2d_node1:GQuadTreeNode;
    private var g2d_node2:GQuadTreeNode;
    private var g2d_node3:GQuadTreeNode;
    private var g2d_node4:GQuadTreeNode;

    private var g2d_objects:Array<Container>;

    public function new(p_left:Float, p_top:Float, p_right:Float, p_bottom:Float) {
        g2d_left = p_left;
        g2d_top = p_top;
        g2d_right = p_right;
        g2d_bottom = p_bottom;
        g2d_width = p_right-p_left;
        g2d_height = p_bottom-p_top;

        g2d_objects = new Array<Container>();
    }

    public function add(p_object:Dynamic, p_left:Float, p_top:Float, p_right:Float, p_bottom:Float):GQuadTreeNode {
        if (intersects(g2d_left,g2d_top,g2d_right,g2d_bottom,p_left,p_top,p_right,p_bottom)) {
            return null;
        }

        var hw:Float = g2d_width*.5;
        var hh:Float = g2d_height*.5;

        if (w<MIN_WIDTH || h<MIN_HEIGHT) {
            g2d_objects.push(p_object);
            return this;
        }

        if (contains(g2d_left,g2d_top,g2d_left+hw,g2d_top+hh,p_left,p_top,p_right,p_bottom)) {
            if (g2d_node1 == null) {
                g2d_node1 = new GQuadTreeNode(g2d_left,g2d_top,g2d_left+hw,g2d_top+hh);
            }
            g2d_node1.add(p_object,p_left,p_top,p_right,p_bottom);
        } else if (contains(g2d_left+hw,g2d_top,g2d_left+hw,g2d_top+hh,p_left,p_top,p_right,p_bottom)) {
            if (g2d_node2 == null) {
                g2d_node2 = new GQuadTreeNode(g2d_left+hw,g2d_top,g2d_left+hw,g2d_top+hh);
            }
            g2d_node2.add(p_object,p_left,p_top,p_right,p_bottom);
        } else if (contains(g2d_left,g2d_top+hh,g2d_left+hw,g2d_top+hh,p_left,p_top,p_right,p_bottom)) {
            if (g2d_node3 == null) {
                g2d_node3 = new GQuadTreeNode(g2d_left+hw,g2d_top,g2d_left+hw,g2d_top+hh);
            }
            g2d_node3.add(p_object,p_left,p_top,p_right,p_bottom);
        } else if (contains(g2d_left+hw,g2d_top+hh,g2d_left+hw,g2d_top+hh,p_left,p_top,p_right,p_bottom)) {
            if (g2d_node4 == null) {
                g2d_node4 = new GQuadTreeNode(g2d_left+hw,g2d_top+hh,g2d_left+hw,g2d_top+hh);
            }
            g2d_node4.add(p_object,p_left,p_top,p_right,p_bottom);
        } else {
            g2d_objects.push(new Container(p_object,p_left,p_top,p_right,p_bottom));
            return this;
        }

        return null;
    }

    public function remove(p_object:Dynamic):Void {
        var count:Int = g2d_objects.length;
        for (i in 0...count) {
            var container:Container = g2d_objects[i];

            if (container.object == object) {
                g2d_objects.remove(container);
                return;
            }
        }
    }

    private function getObjectsInBounds(p_left:Float, p_top:Float, p_right:Float, p_bottom:Float, p_result:Array<Dynamic>):Void {
        if (!intersects(g2d_left, g2d_top, g2d_right, g2d_bottom, p_left, p_top, p_right, p_bottom)) {
            return;
        }

        for (container in g2d_objects) {
            if (intersects(g2d_left, g2d_top, g2d_right, g2d_bottom, container.left, container.top, container.right, container.bottom)) {
                p_result.push(container.object);
            }
        }

        if (g2d_node1 != null) {
            g2d_node1.getObjectsInBounds(p_left, p_top, p_right, p_bottom, p_result);
        }
        if (g2d_node2 != null) {
            g2d_node2.getObjectsInBounds(p_left, p_top, p_right, p_bottom, p_result);
        }
        if (g2d_node3 != null) {
            g2d_node3.getObjectsInBounds(p_left, p_top, p_right, p_bottom, p_result);
        }
        if (g2d_node4 != null) {
            g2d_node4.getObjectsInBounds(p_left, p_top, p_right, p_bottom, p_result);
        }
    }

    inline private function intersects(p_firstLeft:Float, p_firstTop:Float, p_firstRight:Float, p_firstBottom:Float, p_secondLeft:Float, p_secondTop:Float, p_secondRight:Float, p_secondBottom:Float):Bool {
        var x0 = p_firstLeft < p_secondLeft ? p_secondLeft : p_firstLeft;
        var x1 = p_firstRight > p_secondRight ? p_secondRight : p_firstRight;

        if (x1 <= x0) {
            return false;
        }

        var y0 = p_firstTop < p_secondTop ? p_secondTop : p_firstTop;
        var y1 = p_firstBottom > p_secondBottom ? p_secondBottom : p_firstBottom;

        return y1 > y0;
    }

    inline private function contains(p_firstLeft:Float, p_firstTop:Float, p_firstRight:Float, p_firstBottom:Float, p_secondLeft:Float, p_secondTop:Float, p_secondRight:Float, p_secondBottom:Float):Bool {
        if (p_secondRight-p_secondLeft <= 0 || p_secondBottom-p_secondTop <= 0) {
            return p_secondLeft > p_firstLeft && p_secondTop > p_firstTop && p_secondRight < p_firstRight && p_secondBottom < p_firstBottom;
        } else {
            return p_secondLeft >= p_firstLeft && p_secondTop >= p_firstTop && p_secondRight <= p_firstRight && p_secondBottom <= p_firstBottom;
        }
    }
}

class Container {
    public var object:Dynamic;

    public var left:Float;
    public var right:Float;
    public var top:Float;
    public var bottom:Float;

    public function new(p_object:Dynamic, p_left:Float, p_top:Float, p_right:Float, p_bottom:Float) {
        object = p_object;
        left = p_left;
        top = p_top;
        right = p_right;
        bottom = p_bottom;
    }
}