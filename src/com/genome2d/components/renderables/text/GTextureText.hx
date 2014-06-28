/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components.renderables.text;

import com.genome2d.error.GError;
import com.genome2d.textures.GCharTexture;
import com.genome2d.textures.GFontTextureAtlas;
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
	
	private var g2d_vAlign:Int = 0;
    #if swc @:extern #end
	public var vAlign(get,set):Int;
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
    public var hAlign(get,set):Int;
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

    private var g2d_textureAtlas:GFontTextureAtlas;
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
		setTextureAtlas(GTextureAtlas.getFontTextureAtlasById(p_value));
		return p_value;
	}

    /*
     *  Set texture atlas that will be used for character textures lookup
     */
	public function setTextureAtlas(p_textureAtlas:GFontTextureAtlas):Void {
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

    private var g2d_autoSize:Bool = false;
    /*
        Text should automatically resize width/height
     */
    #if swc @:extern #end
    public var autoSize(get, set):Bool;
    #if swc @:getter(autoSize) #end
    inline private function get_autoSize():Bool {
        return g2d_autoSize;
    }
    #if swc @:setter(width) #end
    inline private function set_autoSize(p_value:Bool):Bool {
        g2d_autoSize = p_value;
        g2d_invalidate = true;
        return g2d_autoSize;
    }
	
	private var g2d_width:Float = 100;
    /*
        Width of the text
     */
    #if swc @:extern #end
	public var width(get, set):Float;
    #if swc @:getter(width) #end
	inline private function get_width():Float {
		if (g2d_autoSize && g2d_invalidate) invalidateText();
		
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
	public var height(get, set):Float;
    #if swc @:getter(height) #end
	public function get_height():Float {		
		if (g2d_autoSize && g2d_invalidate) invalidateText();
		
		return g2d_height;
	}
    #if swc @:setter(height) #end
    public function set_height(p_value:Float):Float {
        g2d_height = p_value;
        g2d_invalidate = true;
        return g2d_height;
    }

    private var g2d_chars:Array<GChar>;

    @:dox(hide)
	public function render(p_camera:GContextCamera, p_useMatrix:Bool):Void {
		if (g2d_invalidate) invalidateText();

        var charCount:Int = g2d_chars.length;
        var cos:Float = 1;
        var sin:Float = 0;
        if (g2d_node.transform.g2d_worldRotation != 0) {
            cos = Math.cos(node.transform.g2d_worldRotation);
            sin = Math.sin(node.transform.g2d_worldRotation);
        }

        for (i in 0...charCount) {
            var char:GChar = g2d_chars[i];
            if (!char.g2d_visible) break;

            var tx:Float = char.g2d_x * node.transform.g2d_worldScaleX + g2d_node.transform.g2d_worldX;
            var ty:Float = char.g2d_y * node.transform.g2d_worldScaleY + g2d_node.transform.g2d_worldY;
            if (g2d_node.transform.g2d_worldRotation != 0) {
                tx = (char.g2d_x * cos - char.g2d_y * sin) * node.transform.g2d_worldScaleX + g2d_node.transform.g2d_worldX;
                ty = (char.g2d_y * cos + char.g2d_x * sin) * node.transform.g2d_worldScaleY + g2d_node.transform.g2d_worldY;
            }

            node.core.getContext().draw(char.g2d_texture, tx, ty, node.transform.g2d_worldScaleX, node.transform.g2d_worldScaleY, node.transform.g2d_worldRotation, node.transform.g2d_worldRed, node.transform.g2d_worldGreen, node.transform.g2d_worldBlue, node.transform.g2d_worldAlpha, 1, null);
        }
	}
		
	private function invalidateText():Void {
		if (g2d_textureAtlas == null) return;
        if (g2d_chars == null) g2d_chars = new Array<GChar>();

		if (g2d_autoSize) {
            g2d_width = 0;
        }
		var offsetX:Float = 0;
		var offsetY:Float =  0;
		var char:GChar;
		var texture:GCharTexture = null;
        var currentCharCode:Int = -1;
        var previousCharCode:Int = -1;
        var lastChar:Int = 0;

        var lines:Array<Array<GChar>> = new Array<Array<GChar>>();
        var currentLine:Array<GChar> = new Array<GChar>();
        var charIndex:Int = 0;
        var whiteSpaceIndex:Int = -1;
		var i:Int = 0;

		while (i<g2d_text.length) {
            // New line character
			if (g2d_text.charCodeAt(i) == 10) {
                if (g2d_autoSize) {
				    g2d_width = (offsetX>g2d_width) ? offsetX : g2d_width;
                }
                previousCharCode = -1;
                lines.push(currentLine);
                currentLine = new Array<GChar>();
                if (!g2d_autoSize && offsetY + 2*(g2d_textureAtlas.lineHeight + g2d_lineSpace) > g2d_height) break;
                offsetX = 0;
                offsetY += g2d_textureAtlas.lineHeight + g2d_lineSpace;
            } else {
                currentCharCode = g2d_text.charCodeAt(i);
                texture = g2d_textureAtlas.getSubTexture(Std.string(currentCharCode));
                if (texture == null) continue;// throw new GError("Texture for character "+g2d_text.charAt(i)+" with code "+g2d_text.charCodeAt(i)+" not found!");

                if (previousCharCode != -1) {
                    offsetX += g2d_textureAtlas.getKerning(previousCharCode,currentCharCode);
                }

                if (currentCharCode != 32) {
                    if (charIndex>=g2d_chars.length) {
                        char = new GChar();
                        g2d_chars.push(char);
                    } else {
                        char = g2d_chars[charIndex];
                    }

                    char.g2d_code = currentCharCode;
                    char.g2d_texture = texture;
                    if (!g2d_autoSize && offsetX + texture.width>g2d_width) {
                        lines.push(currentLine);
                        var backtrack:Int = i-whiteSpaceIndex-1;
                        var currentCount:Int = currentLine.length;
                        currentLine.splice(currentLine.length-backtrack, backtrack);
                        currentLine = new Array<GChar>();
                        charIndex -= backtrack;
                        if (backtrack>=currentCount) break;
                        if (!g2d_autoSize && offsetY + 2*(g2d_textureAtlas.lineHeight + g2d_lineSpace) > g2d_height) break;
                        i = whiteSpaceIndex+1;
                        offsetX = 0;
                        offsetY += g2d_textureAtlas.lineHeight + g2d_lineSpace;
                        continue;
                    }

                    currentLine.push(char);
                    char.g2d_visible = true;
                    char.g2d_x = offsetX + texture.xoffset;
                    char.g2d_y = offsetY + texture.yoffset;
                    charIndex++;
                } else {
                    whiteSpaceIndex = i;
                }

                offsetX += texture.xadvance + g2d_tracking;

                previousCharCode = currentCharCode;
            }
            ++i;
		}
        lines.push(currentLine);

        var charCount:Int = g2d_chars.length;
        for (i in charIndex...charCount) {
            g2d_chars[i].g2d_visible = false;
        }

        if (g2d_autoSize) {
		    g2d_width = offsetX;
		    g2d_height = offsetY + g2d_textureAtlas.lineHeight;
        }

        var bottom:Float = offsetY + g2d_textureAtlas.lineHeight;
        var offsetY:Float = 0;
        if (g2d_vAlign == GTextureTextVAlignType.MIDDLE) {
            offsetY = (g2d_height - bottom) * .5;
        } else if (g2d_vAlign == GTextureTextVAlignType.BOTTOM) {
            offsetY = g2d_height - bottom;
        }

        for (i in 0...lines.length) {
            var currentLine:Array<GChar> = lines[i];

            charCount = currentLine.length;
            if (charCount == 0) continue;
            var offsetX:Float = 0;
            var last:GChar = currentLine[charCount-1];
            var right:Float = last.g2d_x - last.g2d_texture.xoffset + last.g2d_texture.xadvance;

            if (g2d_hAlign == GTextureTextHAlignType.CENTER) {
                offsetX = (g2d_width - right) * .5;
            } else if (g2d_hAlign == GTextureTextHAlignType.RIGHT) {
                offsetX = g2d_width - right;
            }

            for (j in 0...charCount) {
                var char:GChar = currentLine[j];
                char.g2d_x = char.g2d_x + offsetX;
                char.g2d_y = char.g2d_y + offsetY;
            }
        }
		
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