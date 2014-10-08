/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components.renderables.text;

import com.genome2d.text.GTextRenderer;
import com.genome2d.geom.GRectangle;
import com.genome2d.signals.GMouseSignalType;
import com.genome2d.node.GNode;
import com.genome2d.signals.GMouseSignal;
import com.genome2d.context.GContextCamera;

/**
    Component used for rendering texture based text
**/
class GText extends GComponent implements IRenderable
{
    public var renderer:GTextRenderer;

	private var g2d_invalidate:Bool = false;
	
	private var g2d_tracking:Float = 0;
    /*
     *  Character tracking
     *  Default 0
     */
    #if swc @:extern #end
	@prototype public var tracking(get, set):Float;
    #if swc @:getter(tracking) #end
	inline private function get_tracking():Float {
		return g2d_tracking;
	}
    #if swc @:setter(tracking) #end
	inline private function set_tracking(p_tracking:Float):Float {
		g2d_tracking = p_tracking;
		g2d_invalidate = true;
		return g2d_tracking;
	}
	
	private var g2d_lineSpace:Float = 0;
    /*
     *  Line spacing
     *  Default 0
     */
    #if swc @:extern #end
	@prototype public var lineSpace(get, set):Float;
    #if swc @:getter(lineSpace) #end
	inline private function get_lineSpace():Float {
		return g2d_lineSpace;
	}
    #if swc @:setter(lineSpace) #end
	inline private function set_lineSpace(p_value:Float):Float {
		g2d_lineSpace = p_value;
		g2d_invalidate = true;
		return g2d_lineSpace;
	}
	
	private var g2d_vAlign:Int = 0;
    #if swc @:extern #end
	@prototype public var vAlign(get,set):Int;
    #if swc @:getter(vAlign) #end
	inline private function get_vAlign():Int {
		return g2d_vAlign;
	}
    #if swc @:setter(vAlign) #end
	inline private function set_vAlign(p_value:Int):Int {
		g2d_vAlign = p_value;
		g2d_invalidate = true;
		return g2d_vAlign;
	}

    private var g2d_hAlign:Int = 0;
    #if swc @:extern #end
    @prototype public var hAlign(get,set):Int;
    #if swc @:getter(hAlign) #end
    inline private function get_hAlign():Int {
        return g2d_hAlign;
    }
    #if swc @:setter(hAlign) #end
    inline private function set_hAlign(p_value:Int):Int {
        g2d_hAlign = p_value;
        g2d_invalidate = true;
        return g2d_hAlign;
    }
	
    /*
     *  Text
     */
    #if swc @:extern #end
	@prototype public var text(get, set):String;
    #if swc @:getter(text) #end
	inline private function get_text():String {
		return renderer.text;
	}
    #if swc @:setter(text) #end
	inline private function set_text(p_text:String):String {
		renderer.text = p_text;
		g2d_invalidate = true;
		return renderer.text;
	}

    private var g2d_autoSize:Bool = false;
    /*
        Text should automatically resize width/height
     */
    #if swc @:extern #end
    @prototype public var autoSize(get, set):Bool;
    #if swc @:getter(autoSize) #end
    inline private function get_autoSize():Bool {
        return g2d_autoSize;
    }
    #if swc @:setter(autoSize) #end
    inline private function set_autoSize(p_value:Bool):Bool {
        renderer.autoSize = p_value;
        g2d_invalidate = true;
        return g2d_autoSize;
    }
	
	private var g2d_width:Float = 100;
    /*
        Width of the text
     */
    #if swc @:extern #end
	@prototype public var width(get, set):Float;
    #if swc @:getter(width) #end
	inline private function get_width():Float {
		if (g2d_autoSize && g2d_invalidate) invalidate();
		
		return g2d_width;
	}
    #if swc @:setter(width) #end
    inline private function set_width(p_value:Float):Float {
        g2d_width = p_value;
        g2d_invalidate = true;
        return g2d_width;
    }
	
	private var g2d_height:Float = 100;
    /*
        Height of the text
     */
    #if swc @:extern #end
	@prototype public var height(get, set):Float;
    #if swc @:getter(height) #end
	public function get_height():Float {		
		if (g2d_autoSize && g2d_invalidate) invalidate();
		
		return g2d_height;
	}
    #if swc @:setter(height) #end
    public function set_height(p_value:Float):Float {
        g2d_height = p_value;
        g2d_invalidate = true;
        return g2d_height;
    }

    @:dox(hide)
	public function render(p_camera:GContextCamera, p_useMatrix:Bool):Void {
		if (g2d_invalidate) invalidate();

        if (renderer != null) renderer.render(node.transform.g2d_worldX, node.transform.g2d_worldY, node.transform.g2d_worldScaleX, node.transform.g2d_worldScaleY, node.transform.g2d_worldRotation);
	}
		
	private function invalidate():Void {
        if (renderer != null) renderer.invalidate();

		g2d_invalidate = false;
	}
	
	@:dox(hide)
    override public function processContextMouseSignal(p_captured:Bool, p_cameraX:Float, p_cameraY:Float, p_contextSignal:GMouseSignal):Bool {
		if (g2d_width == 0 || g2d_height == 0) return false;

		if (p_captured) {
            if (node.g2d_mouseOverNode == node) node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OUT, node, 0, 0, p_contextSignal);
            return false;
		}

        // Invert translations
        var tx:Float = p_cameraX - node.transform.g2d_worldX;
        var ty:Float = p_cameraY - node.transform.g2d_worldY;

        if (node.transform.g2d_worldRotation != 0) {
            var cos:Float = Math.cos(-node.transform.g2d_worldRotation);
            var sin:Float = Math.sin(-node.transform.g2d_worldRotation);

            var ox:Float = tx;
            tx = (tx*cos - ty*sin);
            ty = (ty*cos + ox*sin);
        }

        tx /= node.transform.g2d_worldScaleX*g2d_width;
        ty /= node.transform.g2d_worldScaleY*g2d_height;

        var tw:Float = 0;
        var th:Float = 0;

        if (tx >= -tw && tx <= 1 - tw && ty >= -th && ty <= 1 - th) {
            node.dispatchNodeMouseSignal(p_contextSignal.type, node, tx*g2d_width, ty*g2d_height, p_contextSignal);
            if (node.g2d_mouseOverNode != node) {
                node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OVER, node, tx*g2d_width, ty*g2d_height, p_contextSignal);
            }

            return true;
        } else {
            if (node.g2d_mouseOverNode == node) {
                node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OUT, node, tx*g2d_width, ty*g2d_height, p_contextSignal);
            }
        }

        return false;
	}

    public function getBounds(p_bounds:GRectangle = null):GRectangle {
        if (p_bounds != null) p_bounds.setTo(0, 0, g2d_width, g2d_height);
        else p_bounds = new GRectangle(0, 0, g2d_width, g2d_height);

        return p_bounds;
    }
}