/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components.renderable.text;

import com.genome2d.utils.GHAlignType;
import com.genome2d.utils.GVAlignType;
import com.genome2d.proto.GPrototype;
import com.genome2d.proto.GPrototypeExtras;
import com.genome2d.text.GFontManager;
import com.genome2d.text.GTextRenderer;
import com.genome2d.geom.GRectangle;
import com.genome2d.input.GMouseInputType;
import com.genome2d.node.GNode;
import com.genome2d.input.GMouseInput;
import com.genome2d.context.GCamera;
import com.genome2d.text.GTextureTextRenderer;

/**
    Component used for rendering textures based text
**/
class GText extends GComponent implements IGRenderable
{
    public var renderer:GTextureTextRenderer;

    /*
     *  Character tracking
     *  Default 0
     */
    #if swc @:extern #end
	@prototype
	public var tracking(get, set):Float;
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
	@prototype
	public var lineSpace(get, set):Float;
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
	@prototype
	public var vAlign(get,set):GVAlignType;
    #if swc @:getter(vAlign) #end
	inline private function get_vAlign():GVAlignType {
		return renderer.vAlign;
	}
    #if swc @:setter(vAlign) #end
	inline private function set_vAlign(p_value:GVAlignType):GVAlignType {
		renderer.vAlign = p_value;
		return p_value;
	}

    #if swc @:extern #end
    @prototype
	public var hAlign(get,set):GHAlignType;
    #if swc @:getter(hAlign) #end
    inline private function get_hAlign():GHAlignType {
        return renderer.hAlign;
    }
    #if swc @:setter(hAlign) #end
    inline private function set_hAlign(p_value:GHAlignType):GHAlignType {
        renderer.hAlign = p_value;
        return p_value;
    }
	
    /*
     *  Text
     */
    #if swc @:extern #end
	@prototype
	public var text(get, set):String;
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
    @prototype
	public var autoSize(get, set):Bool;
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
	@prototype
	public var width(get, set):Float;
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
	@prototype
	public var height(get, set):Float;
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
	
	override public function init():Void {
		renderer = new GTextureTextRenderer();
	}

    @:dox(hide)
	public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
		if (renderer.isDirty()) renderer.invalidate();

        if (renderer != null) renderer.render(node.g2d_worldX, node.g2d_worldY, node.g2d_worldScaleX, node.g2d_worldScaleY, node.g2d_worldRotation, node.g2d_worldRed, node.g2d_worldGreen, node.g2d_worldBlue, node.g2d_worldAlpha);
	}
	
    public function captureMouseInput(p_input:GMouseInput):Void {
		/*
		if (renderer == null || renderer.width == 0 || renderer.height == 0) return false;

		if (p_captured) {
            if (node.g2d_mouseOverNode == node) node.dispatchMouseCallback(GMouseInputType.MOUSE_OUT, node, 0, 0, p_input);
            return false;
		}

        // Invert translations
        var tx:Float = p_input.worldX - node.g2d_worldX;
        var ty:Float = p_input.worldY - node.g2d_worldY;

        if (node.g2d_worldRotation != 0) {
            var cos:Float = Math.cos(-node.g2d_worldRotation);
            var sin:Float = Math.sin(-node.g2d_worldRotation);

            var ox:Float = tx;
            tx = (tx*cos - ty*sin);
            ty = (ty*cos + ox*sin);
        }

        tx /= node.g2d_worldScaleX*renderer.width;
        ty /= node.g2d_worldScaleY*renderer.height;

        var tw:Float = 0;
        var th:Float = 0;

        if (tx >= -tw && tx <= 1 - tw && ty >= -th && ty <= 1 - th) {
            node.dispatchMouseCallback(p_input.type, node, tx*renderer.width, ty*renderer.height, p_input);
            if (node.g2d_mouseOverNode != node) {
                node.dispatchMouseCallback(GMouseInputType.MOUSE_OVER, node, tx*renderer.width, ty*renderer.height, p_input);
            }

            return true;
        } else {
            if (node.g2d_mouseOverNode == node) {
                node.dispatchMouseCallback(GMouseInputType.MOUSE_OUT, node, tx*renderer.width, ty*renderer.height, p_input);
            }
        }
		/**/
	}

    public function getBounds(p_bounds:GRectangle = null):GRectangle {
        if (p_bounds != null) p_bounds.setTo(0, 0, renderer.width, renderer.height);
        else p_bounds = new GRectangle(0, 0, renderer.width, renderer.height);

        return p_bounds;
    }
	
	public function hitTest(p_x:Float, p_y:Float):Bool {
		return false;
	}
	
	override public function getPrototype(p_prototype:GPrototype = null):GPrototype {
		p_prototype = getPrototypeDefault(p_prototype);
		p_prototype.createPrototypeProperty("font", "String", GPrototypeExtras.IGNORE_AUTO_BIND, null, renderer.textureFont != null ? renderer.textureFont.id : "");
		
		return p_prototype;
	}
	
	override public function bindPrototype(p_prototype:GPrototype):Void {
		bindPrototypeDefault(p_prototype);
		
		renderer.textureFont = cast GFontManager.getFont(p_prototype.getProperty("font").value);
	}
	/**/
}