/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.renderables;

import com.genome2d.geom.GRectangle;
import com.genome2d.signals.GMouseSignalType;
import com.genome2d.node.GNode;
import com.genome2d.node.factory.GNodeFactory;
import com.genome2d.signals.GMouseSignal;
import com.genome2d.textures.GTexture;
import com.genome2d.textures.GTextureAtlas;
import com.genome2d.context.GContextCamera;

/**
    Component used for rendering texture based text
**/
class GTextureText extends GComponent implements IRenderable
{
    /*
     *  Blend mode used for rendering
     */
    public var blendMode:Int = 1;
		
	private var g2d_invalidate:Bool = false;
	
	private var g2d_tracking:Float = 0;
    /*
     *  Character tracking
     *  Default 0
     */
    #if swc @:extern #end
	public var tracking(get, set):Float;
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
	public var lineSpace(get, set):Float;
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
	
	private var g2d_align:Int = 0;
    /*
     *  Text alignment
     */
    #if swc @:extern #end
	public var align(get,set):Int;
    #if swc @:getter(align) #end
	inline private function get_align():Int {
		return g2d_align;
	}
    #if swc @:setter(align) #end
	inline private function set_align(p_align:Int):Int {
		g2d_align = p_align;
		g2d_invalidate = true;
		return g2d_align;
	}

    /*
     *  Maximum width of the text
     */
	public var maxWidth:Float = 0;

    private var g2d_textureAtlas:GTextureAtlas;
    /*
     *  Texture atlas id used for character textures lookup
     */
    #if swc @:extern #end
	public var textureAtlasId(get, set):String;
    #if swc @:getter(textureAtlasId) #end
	inline private function get_textureAtlasId():String {
		if (g2d_textureAtlas != null) return g2d_textureAtlas.getId();
		return "";
	}
    #if swc @:setter(textureAtlasId) #end
	inline private function set_textureAtlasId(p_value:String):String {
		setTextureAtlas(GTextureAtlas.getTextureAtlasById(p_value));
		return p_value;
	}

    /*
     *  Set texture atlas that will be used for character textures lookup
     */
	public function setTextureAtlas(p_textureAtlas:GTextureAtlas):Void {
		g2d_textureAtlas = p_textureAtlas;
		g2d_invalidate = true;
	}
	
	private var g2d_text:String = "";
    /*
     *  Text
     */
    #if swc @:extern #end
	public var text(get, set):String;
    #if swc @:getter(text) #end
	inline private function get_text():String {
		return g2d_text;
	}
    #if swc @:setter(text) #end
	inline private function set_text(p_text:String):String {
		g2d_text = p_text;
		g2d_invalidate = true;
		return g2d_text;
	}
	
	private var g2d_width:Float = 0;
    /*
     *  Width of the text
     */
    #if swc @:extern #end
	public var width(get, never):Float;
    #if swc @:getter(width) #end
	inline private function get_width():Float {
		if (g2d_invalidate) invalidateText();
		
		return g2d_width*node.transform.g2d_worldScaleX;
	}
	
	private var g2d_height:Float = 0;
    /*
     *  Height of the text
     */
    #if swc @:extern #end
	public var height(get, never):Float;
    #if swc @:getter(height) #end
	public function get_height():Float {		
		if (g2d_invalidate) invalidateText();
		
		return g2d_height * node.transform.g2d_worldScaleY;
	}

    @:dox(hide)
	public function render(p_camera:GContextCamera, p_useMatrix:Bool):Void {
		if (g2d_invalidate) invalidateText();
	}
		
	private function invalidateText():Void {
		if (g2d_textureAtlas == null) return;
		
		g2d_width = 0;
		var offsetX:Float = 0;
		var offsetY:Float =  0;
		var charSprite:GSprite;
		var texture:GTexture = null;
		
		for (i in 0...g2d_text.length) {
			if (g2d_text.charCodeAt(i) == 10) {
				g2d_width = (offsetX>g2d_width) ? offsetX : g2d_width;
				offsetX = 0;
				offsetY += (texture != null ? texture.height + g2d_lineSpace : g2d_lineSpace);
				continue;
            }
			texture = g2d_textureAtlas.getSubTexture(Std.string(g2d_text.charCodeAt(i)));
			if (texture == null) continue;//throw new GError("Texture for character "+g2d_text.charAt(i)+" with code "+g2d_text.charCodeAt(i)+" not found!");
			if (i>=node.numChildren) {
				charSprite = cast GNodeFactory.createNodeWithComponent(GSprite);
				node.addChild(charSprite.node);
			} else {
				charSprite = cast node.getChildAt(i).getComponent(GSprite);
			}

			charSprite.texture = texture;
			if (maxWidth>0 && offsetX + texture.width>maxWidth) {
				g2d_width = (offsetX>g2d_width) ? offsetX : g2d_width;
				offsetX = 0;
				offsetY+=texture.height+g2d_lineSpace;
			}
			offsetX += texture.width / 2;
			charSprite.node.transform.visible = true;
			charSprite.node.transform.x = offsetX;
			charSprite.node.transform.y = offsetY+texture.height/2;
			offsetX += texture.width/2 + g2d_tracking;
		}
		
		g2d_width = (offsetX>g2d_width) ? offsetX : g2d_width;
		g2d_height = offsetY + (texture!=null ? texture.height : 0);
		for (i in g2d_text.length...node.numChildren) {
			node.getChildAt(i).transform.visible = false;
		}

		invalidateAlign();
		
		g2d_invalidate = false;
	}

	private function invalidateAlign():Void {
		switch (g2d_align) {
			case GTextureTextAlignType.MIDDLE:
				for (i in 0...node.numChildren) {
					var child:GNode = node.getChildAt(i);
					child.transform.x -= g2d_width/2;
					child.transform.y -= g2d_height/2;
				}
			case GTextureTextAlignType.TOP_RIGHT:
				for (i in 0...node.numChildren) {
					node.getChildAt(i).transform.x -= g2d_width;
				}
		}
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

        var tw:Float = .5;
        var th:Float = .5;

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