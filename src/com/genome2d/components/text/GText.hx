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
import com.genome2d.context.GCamera;

/**
    Component used for rendering textures based text
**/
class GText extends GComponent implements IRenderable
{
    public var renderer:GTextRenderer;

    /*
     *  Character tracking
     *  Default 0
     */
    #if swc @:extern #end
	@prototype public var tracking(get, set):Float;
    #if swc @:getter(tracking) #end
	inline private function get_tracking():Float {
		return renderer.tracking;
	}
    #if swc @:setter(tracking) #end
	inline private function set_tracking(p_value:Float):Float {
		renderer.tracking = p_value;
		return p_value;
	}

    /*
     *  Line spacing
     *  Default 0
     */
    #if swc @:extern #end
	@prototype public var lineSpace(get, set):Float;
    #if swc @:getter(lineSpace) #end
	inline private function get_lineSpace():Float {
		return renderer.lineSpace;
	}
    #if swc @:setter(lineSpace) #end
	inline private function set_lineSpace(p_value:Float):Float {
		renderer.lineSpace = p_value;
		return p_value;
	}

    #if swc @:extern #end
	@prototype public var vAlign(get,set):Int;
    #if swc @:getter(vAlign) #end
	inline private function get_vAlign():Int {
		return renderer.vAlign;
	}
    #if swc @:setter(vAlign) #end
	inline private function set_vAlign(p_value:Int):Int {
		renderer.vAlign = p_value;
		return p_value;
	}

    #if swc @:extern #end
    @prototype public var hAlign(get,set):Int;
    #if swc @:getter(hAlign) #end
    inline private function get_hAlign():Int {
        return renderer.hAlign;
    }
    #if swc @:setter(hAlign) #end
    inline private function set_hAlign(p_value:Int):Int {
        renderer.hAlign = p_value;
        return p_value;
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
		return renderer.text;
	}

    /*
        Text should automatically resize width/height
     */
    #if swc @:extern #end
    @prototype public var autoSize(get, set):Bool;
    #if swc @:getter(autoSize) #end
    inline private function get_autoSize():Bool {
        return renderer.autoSize;
    }
    #if swc @:setter(autoSize) #end
    inline private function set_autoSize(p_value:Bool):Bool {
        renderer.autoSize = p_value;
        return p_value;
    }

    /*
        Width of the text
     */
    #if swc @:extern #end
	@prototype public var width(get, set):Float;
    #if swc @:getter(width) #end
	inline private function get_width():Float {
		if (renderer.autoSize && renderer.isDirty()) renderer.invalidate();

		return renderer.width;
	}
    #if swc @:setter(width) #end
    inline private function set_width(p_value:Float):Float {
        renderer.width = p_value;
        return p_value;
    }

    /*
        Height of the text
     */
    #if swc @:extern #end
	@prototype public var height(get, set):Float;
    #if swc @:getter(height) #end
	inline private function get_height():Float {
        if (renderer.autoSize && renderer.isDirty()) renderer.invalidate();
		
		return renderer.height;
	}
    #if swc @:setter(height) #end
    inline private function set_height(p_value:Float):Float {
        renderer.height = p_value;
        return p_value;
    }

    @:dox(hide)
	public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
		if (renderer.isDirty()) renderer.invalidate();

        if (renderer != null) renderer.render(node.transform.g2d_worldX, node.transform.g2d_worldY, node.transform.g2d_worldScaleX, node.transform.g2d_worldScaleY, node.transform.g2d_worldRotation);
	}
	
	@:dox(hide)
    override public function processContextMouseSignal(p_captured:Bool, p_cameraX:Float, p_cameraY:Float, p_contextSignal:GMouseSignal):Bool {
		if (renderer == null || renderer.width == 0 || renderer.height == 0) return false;

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

        tx /= node.transform.g2d_worldScaleX*renderer.width;
        ty /= node.transform.g2d_worldScaleY*renderer.height;

        var tw:Float = 0;
        var th:Float = 0;

        if (tx >= -tw && tx <= 1 - tw && ty >= -th && ty <= 1 - th) {
            node.dispatchNodeMouseSignal(p_contextSignal.type, node, tx*renderer.width, ty*renderer.height, p_contextSignal);
            if (node.g2d_mouseOverNode != node) {
                node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OVER, node, tx*renderer.width, ty*renderer.height, p_contextSignal);
            }

            return true;
        } else {
            if (node.g2d_mouseOverNode == node) {
                node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OUT, node, tx*renderer.width, ty*renderer.height, p_contextSignal);
            }
        }

        return false;
	}

    public function getBounds(p_bounds:GRectangle = null):GRectangle {
        if (p_bounds != null) p_bounds.setTo(0, 0, renderer.width, renderer.height);
        else p_bounds = new GRectangle(0, 0, renderer.width, renderer.height);

        return p_bounds;
    }
}