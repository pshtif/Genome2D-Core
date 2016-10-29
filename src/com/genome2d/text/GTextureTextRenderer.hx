/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.text;
import com.genome2d.context.GBlendMode;
import com.genome2d.components.renderable.text.GText;
import com.genome2d.debug.GDebug;
import com.genome2d.input.GMouseInput;
import com.genome2d.input.GMouseInputType;
import com.genome2d.textures.GTexture;
import com.genome2d.textures.GTextureManager;
import com.genome2d.utils.GHAlignType;
import com.genome2d.utils.GVAlignType;
import com.genome2d.context.IGContext;
import com.genome2d.context.GCamera;
import flash.display.BitmapData;

class GTextureTextRenderer extends GTextRenderer {
	
	static public var warnMissingCharTextures:Bool = false;
	
	public var red:Float = 1;
	public var green:Float = 1;
	public var blue:Float = 1;
	public var alpha:Float = 1;

    private var g2d_textureFont:GTextureFont;
    #if swc @:extern #end
    public var textureFont(get, set):GTextureFont;
    #if swc @:getter(textureFont) #end
    inline private function get_textureFont():GTextureFont{
        return g2d_textureFont;
    }
    #if swc @:setter(textureFont) #end
    inline private function set_textureFont(p_value:GTextureFont):GTextureFont {
        g2d_textureFont = p_value;
        g2d_dirty = true;
        return g2d_textureFont;
    }

    private var g2d_chars:Array<GTextureCharRenderable>;
	
	private var g2d_cursorBlinkCount:Int = 0;
	
	public var cursorStartIndex:Int = 0;
	public var cursorEndIndex:Int = 0;
	public var enableCursor:Bool = false;
	public var scrollLine:Int = 0;
	public var autoScroll:Bool = false;

	private var g2d_lineCount:Int = 0;
	private var g2d_cursorCurrentIndex:Int = 0;
	private var g2d_maxVisibleLine:Int = 0;
	
	public var format:GTextFormat;
	
	static private var g2d_helperTexture:GTexture;
	
	public function new():Void {
		super();
		
		g2d_chars = new Array<GTextureCharRenderable>();
		
		#if flash
		if (g2d_helperTexture == null) {
			g2d_helperTexture = GTextureManager.createTexture("g2d_GTextureTextRenderer_helper", new BitmapData(4, 4, false, 0xFFFFFF));
			g2d_helperTexture.pivotX = g2d_helperTexture.pivotY = -2;
		}
		#end
	}

    override public function render(p_x:Float, p_y:Float, p_scaleX:Float, p_scaleY:Float, p_rotation:Float, p_red:Float, p_green:Float, p_blue:Float, p_alpha:Float):Void {
        if (g2d_textureFont == null) return;

        if (g2d_dirty) invalidate();
		
		if (enableCursor) renderSelection(p_x, p_y, p_scaleX, p_scaleY, 0);

        var charCount:Int = g2d_chars.length;
        var cos:Float = 1;
        var sin:Float = 0;
        if (p_rotation != 0) {
            cos = Math.cos(p_rotation);
            sin = Math.sin(p_rotation);
        }

		var tx:Float;
        var ty:Float;
		
		var renderColor:Int = 0xFFFFFF;
		var lastRenderColor:Int = 0xFFFFFF;
		var charRed:Float = 1;
		var charGreen:Float = 1;
		var charBlue:Float = 1;
		var charAlpha:Float = 1;
		if (autoScroll && g2d_lineCount>g2d_maxVisibleLine) scrollLine = g2d_lineCount - g2d_maxVisibleLine - 1;
		var scrollOffset:Float = scrollLine * (g2d_textureFont.lineHeight + g2d_lineSpace) * g2d_fontScale;

        for (i in 0...charCount) {
            var renderable:GTextureCharRenderable = g2d_chars[i];
			
			if (format != null) {
				var indexColor:Int = format.getIndexColor(i);
				if (indexColor != -1 && lastRenderColor != indexColor) {
					charAlpha = (indexColor >> 24 & 0xFF) / 0xFF;
					charRed = (indexColor >> 16 & 0xFF) / 0xFF;
					charGreen = (indexColor >> 8 & 0xFF) / 0xFF;
					charBlue = (indexColor & 0xFF) / 0xFF;
					lastRenderColor = indexColor;
				}
			}

            if (!renderable.visible || renderable.line > g2d_maxVisibleLine+scrollLine) {
				break;
			}
			if (renderable.whiteSpace || renderable.line<scrollLine) continue;
			
			var cx:Float = renderable.x + renderable.xoffset*fontScale;
			var cy:Float = renderable.y + renderable.yoffset*fontScale - scrollOffset;

            if (p_rotation != 0) {
                tx = (cx * cos - cy * sin) * p_scaleX + p_x;
                ty = (cy * cos + cx * sin) * p_scaleY + p_y;
            } else {
				tx = cx * p_scaleX + p_x;
				ty = cy * p_scaleY + p_y;
			}
			
			if (charRed == 1 && charBlue == 1 && charGreen == 1 && charAlpha == 1) {
				g2d_context.draw(renderable.texture, GBlendMode.NORMAL, tx, ty, p_scaleX * g2d_fontScale, p_scaleY * g2d_fontScale, p_rotation, red * p_red, green * p_green, blue * p_blue, alpha * p_alpha, null);
			} else {
				g2d_context.draw(renderable.texture, GBlendMode.NORMAL, tx, ty, p_scaleX * g2d_fontScale, p_scaleY * g2d_fontScale, p_rotation, charRed * p_red, charGreen * p_green, charBlue * p_blue, charAlpha * p_alpha, null);
			}
        }
	}
	
	private function renderSelection(p_x:Float, p_y:Float, p_scaleX:Float, p_scaleY:Float, p_rotation:Float):Void {
		g2d_cursorBlinkCount++;
		if (cursorStartIndex == cursorEndIndex && Std.int(g2d_cursorBlinkCount / 10) % 2 == 0) {
			var tx:Float = p_x;
			var ty:Float = p_y;
			if (g2d_textLength > 0) { 
				var char:GTextureCharRenderable = (cursorEndIndex >= g2d_textLength) ? g2d_chars[g2d_textLength - 1] : g2d_chars[cursorEndIndex];
				tx = char.x * p_scaleX * g2d_fontScale + p_x + (cursorStartIndex>=g2d_textLength?char.xadvance + g2d_tracking:0);
				ty = char.y * p_scaleY * g2d_fontScale + p_y;
			}
			var char:GTextureChar = g2d_textureFont.getChar(Std.string(124));
			g2d_context.draw(char.texture, GBlendMode.NORMAL, tx, ty, p_scaleX * g2d_fontScale, p_scaleY * g2d_fontScale, p_rotation, red, green, blue, alpha, null);
		} else if (cursorStartIndex != cursorEndIndex) {
			var startChar:GTextureCharRenderable = (cursorStartIndex >= g2d_textLength) ? g2d_chars[g2d_textLength - 1] : g2d_chars[cursorStartIndex];
			var sx:Float = startChar.x * p_scaleX * g2d_fontScale + p_x + (cursorStartIndex >= g2d_textLength?startChar.xadvance + g2d_tracking:0);
			var sy:Float = startChar.y * p_scaleY * g2d_fontScale + p_y;
			
			var endChar:GTextureCharRenderable = (cursorEndIndex >= g2d_textLength) ? g2d_chars[g2d_textLength - 1] : g2d_chars[cursorEndIndex];
			var ex:Float = endChar.x * p_scaleX * g2d_fontScale + p_x + (cursorEndIndex >= g2d_textLength? endChar.xadvance + g2d_tracking:0);
			var ey:Float = endChar.y * p_scaleY * g2d_fontScale + p_y;
			
			if (sy == ey) {
				g2d_context.draw(g2d_helperTexture, GBlendMode.NORMAL, sx, sy, (ex-sx)/4*p_scaleX * g2d_fontScale, g2d_textureFont.lineHeight/4*p_scaleY * g2d_fontScale, p_rotation, 1, 1, 1, 1, null);
			} else {
				g2d_context.draw(g2d_helperTexture, GBlendMode.NORMAL, sx, sy, (g2d_width + p_x - sx) / 4 * p_scaleX * g2d_fontScale, g2d_textureFont.lineHeight / 4 * p_scaleY * g2d_fontScale, p_rotation, 1, 1, 1, 1, null);
				for (i in 1...Std.int((ey - sy) / g2d_textureFont.lineHeight)) {
					g2d_context.draw(g2d_helperTexture, GBlendMode.NORMAL, p_x, sy+i*g2d_textureFont.lineHeight, g2d_width / 4 * p_scaleX * g2d_fontScale, g2d_textureFont.lineHeight / 4 * p_scaleY * g2d_fontScale, p_rotation, 1, 1, 1, 1, null);
				}
				g2d_context.draw(g2d_helperTexture, GBlendMode.NORMAL, p_x, ey, (ex - p_x) / 4 * p_scaleX * g2d_fontScale, g2d_textureFont.lineHeight / 4 * p_scaleY * g2d_fontScale, p_rotation, 1, 1, 1, 1, null);
			}
		}
	}

    override public function invalidate():Void {
        if (g2d_textureFont == null) return;
		
        if (g2d_autoSize) {
            g2d_width = 0;
        }

        var offsetX:Float = 0;
        var offsetY:Float = 0;//(g2d_textureFont.lineHeight - g2d_textureFont.base)*g2d_fontScale;
        var renderable:GTextureCharRenderable;
        var char:GTextureChar = null;
        var currentCharCode:Int = -1;
        var previousCharCode:Int = -1;
        var lastChar:Int = 0;

        var lines:Array<Array<GTextureCharRenderable>> = new Array<Array<GTextureCharRenderable>>();
        var currentLine:Array<GTextureCharRenderable> = new Array<GTextureCharRenderable>();
        var charIndex:Int = 0;
        var whiteSpaceIndex:Int = -1;
        var i:Int = 0;
		var isAllVisible:Bool = true;
		var maxLineWidth:Float = 0;

        while (i < g2d_textLength) {
			if (charIndex>=g2d_chars.length) {
				renderable = new GTextureCharRenderable(this);
				g2d_chars.push(renderable);
			} else {
				renderable = g2d_chars[charIndex];
			}
			
            // New line character
            if (g2d_text.charCodeAt(i) == 10 || g2d_text.charCodeAt(i) == 13) {
                if (g2d_autoSize) {
                    g2d_width = (offsetX>g2d_width) ? offsetX : g2d_width;
                }
                previousCharCode = -1;
                lines.push(currentLine);
                currentLine = new Array<GTextureCharRenderable>();
				// TODO: Vertical autosize
                if (!g2d_autoSize && offsetY + 2 * (g2d_textureFont.lineHeight + g2d_lineSpace)*g2d_fontScale > g2d_height && isAllVisible) {
					isAllVisible = false;
					g2d_maxVisibleLine = lines.length - 1;
				}
				if (offsetX>maxLineWidth) maxLineWidth = offsetX;
                offsetX = 0;
                offsetY += (g2d_textureFont.lineHeight + g2d_lineSpace)*g2d_fontScale;
				
				renderable.line = lines.length - 1;
				renderable.x = offsetX;
				renderable.y = offsetY;
				renderable.whiteSpace = true;
				charIndex++;
            } else {
				// TODO: Vertical autosize
                if (!g2d_autoSize && offsetY + (g2d_textureFont.lineHeight + g2d_lineSpace) * g2d_fontScale > g2d_height && isAllVisible) {
					isAllVisible = false;
					g2d_maxVisibleLine = lines.length - 1;
				}

                currentCharCode = g2d_text.charCodeAt(i);
                char = g2d_textureFont.getChar(Std.string(currentCharCode));

                if (char == null) {
                    if (warnMissingCharTextures) GDebug.warning("Texture for character " + g2d_text.charAt(i) + " with code " + g2d_text.charCodeAt(i) + " not found!");
					i++;
                    continue;
                }

                if (previousCharCode != -1) {
                    offsetX += g2d_textureFont.getKerning(previousCharCode, currentCharCode) * g2d_fontScale;
                }

				renderable.setCharCode(currentCharCode);

				if (!g2d_autoSize && offsetX + char.texture.width*g2d_fontScale > g2d_width) {
					lines.push(currentLine);
					var backtrack:Int = i - whiteSpaceIndex - 1;
					var currentCount:Int = currentLine.length;
					currentLine.splice(currentLine.length - backtrack, backtrack);
					currentLine = new Array<GTextureCharRenderable>();
					charIndex -= backtrack;

					if (backtrack >= currentCount) break;
					if (!g2d_autoSize && offsetY + 2 * (g2d_textureFont.lineHeight + g2d_lineSpace) * g2d_fontScale > g2d_height && isAllVisible) {
						isAllVisible = false;
						g2d_maxVisibleLine = lines.length - 1;
					}

					i = whiteSpaceIndex+1;
					if (offsetX>maxLineWidth) maxLineWidth = offsetX;
					offsetX = 0;
					offsetY += (g2d_textureFont.lineHeight + g2d_lineSpace) * g2d_fontScale;
					continue;
				}

				currentLine.push(renderable);
				renderable.line = lines.length;
				renderable.x = offsetX;
				renderable.y = offsetY;
				charIndex++;

				if (currentCharCode == 32 || currentCharCode == 46) whiteSpaceIndex = i;
				
				if (currentCharCode == 32) {
					renderable.whiteSpace = true;
				} else {
					renderable.whiteSpace = false;
				}

                offsetX += (char.xadvance + g2d_tracking) * g2d_fontScale;

                previousCharCode = currentCharCode;
            }
			
			renderable.visible = true;
            ++i;
        }
		if (offsetX>maxLineWidth) maxLineWidth = offsetX;
        lines.push(currentLine);
		g2d_lineCount = lines.length;

		if (isAllVisible) g2d_maxVisibleLine = lines.length - 1;

        var charCount:Int = g2d_chars.length;
        for (i in charIndex...charCount) {
            g2d_chars[i].visible = false;
        }

        if (g2d_autoSize) {
			g2d_textWidth = g2d_width = (maxLineWidth > g2d_width) ? maxLineWidth : g2d_width;
            g2d_height = offsetY + g2d_textureFont.lineHeight * g2d_fontScale;
        } else {
			g2d_textWidth = maxLineWidth;
		}
		g2d_textHeight = offsetY + g2d_textureFont.lineHeight * g2d_fontScale;

        var bottom:Float = g2d_maxVisibleLine * (g2d_textureFont.lineHeight + g2d_lineSpace) * g2d_fontScale + g2d_textureFont.lineHeight * g2d_fontScale;
        var offsetY:Float = 0;
        if (g2d_vAlign == GVAlignType.MIDDLE) {
            offsetY = (g2d_height - bottom) * .5;
        } else if (g2d_vAlign == GVAlignType.BOTTOM) {
            offsetY = g2d_height - bottom;
        }

        for (i in 0...lines.length) {
            var currentLine:Array<GTextureCharRenderable> = lines[i];
			
            charCount = currentLine.length;
            if (charCount == 0) continue;
            var offsetX:Float = 0;
            var last:GTextureCharRenderable = currentLine[charCount-1];
            var right:Float = last.x - last.xoffset * g2d_fontScale + last.xadvance * fontScale;

            if (g2d_hAlign == GHAlignType.CENTER) {
                offsetX = (g2d_width - right) * .5;
            } else if (g2d_hAlign == GHAlignType.RIGHT) {
                offsetX = g2d_width - right;
            }

            for (j in 0...charCount) {
                var renderable:GTextureCharRenderable = currentLine[j];
                renderable.x = renderable.x + offsetX;
                renderable.y = renderable.y + offsetY;
            }
        }

        g2d_dirty = false;
    }
	
	private function getCharAt(p_x:Float, p_y:Float):Int {
		var minX:Float = Math.POSITIVE_INFINITY;
		var minY:Float = Math.POSITIVE_INFINITY;
		var charCount:Int = g2d_chars.length;
		var minIndex:Int = charCount;
		for (i in 0...charCount) {
			var char:GTextureCharRenderable = g2d_chars[i];
			if (!char.visible) break;

			var tx:Float = char.x * g2d_fontScale;
			var ty:Float = char.y * g2d_fontScale;
			
			var difX:Float = p_x - tx;
			if (difX < 0) continue;
			var difY:Float = p_y - ty;
			if (difY < -char.yoffset * g2d_fontScale) continue;
			if (difX < minX && difY < g2d_textureFont.lineHeight * g2d_fontScale) {
				minX = difX;
				minY = difY;
				minIndex = i;
			}
		}
		
		if (minIndex<charCount && minX > g2d_fontScale*g2d_chars[minIndex].width / 2) minIndex++;
		
		return minIndex;
	}
	
	public function captureMouseInput(p_input:GMouseInput):Void {
		if (enableCursor) {
			var index:Int = getCharAt(p_input.localX, p_input.localY);
			if (p_input.type == GMouseInputType.MOUSE_DOWN) {
				g2d_cursorCurrentIndex = cursorEndIndex = cursorStartIndex = index;
			} else if (p_input.type == GMouseInputType.MOUSE_MOVE && p_input.buttonDown) {
				if (index < g2d_cursorCurrentIndex) {
					cursorStartIndex = index;
					cursorEndIndex = g2d_cursorCurrentIndex;
				} else {
					cursorStartIndex = g2d_cursorCurrentIndex;
					cursorEndIndex = index;
				}
			}
		}
	}
}

@:allow(com.genome2d.text.GTextureTextRenderer)
class GTextureCharRenderable
{
	private var renderer:GTextureTextRenderer;
	
	private var fontChar:GTextureChar;
    inline private function setCharCode(p_value:Int):Void {
		fontChar = renderer.textureFont.getChar(Std.string(p_value));

        if (fontChar == null) GDebug.warning("Texture for character " + Std.string(p_value) + " with code " + p_value + " not found!");
	}
	
	public var texture(get, never):GTexture;
	inline private function get_texture():GTexture {
		return (fontChar != null) ? fontChar.texture : null;
	}
	
	public var xadvance(get, never):Float;
	inline private function get_xadvance():Float {
		return (fontChar != null) ? fontChar.xadvance : 0;
	}
	
	public var xoffset(get, never):Float;
	inline private function get_xoffset():Float {
		return (fontChar != null) ? fontChar.xoffset : 0;
	}
	
	public var yoffset(get, never):Float;
	inline private function get_yoffset():Float {
		return (fontChar != null) ? fontChar.yoffset : 0;
	}
	
	public var width(get, never):Float;
	
	inline private function get_width():Float {
		return (fontChar != null && fontChar.texture != null) ? fontChar.texture.width : 0;
	}

    private var x:Float;
	private var y:Float;
	
	private var line:Int;
	private var visible:Bool = false;
	
	/*
	public var y(get, never):Float;
	inline private function get_y():Float {
		return line * (renderer.textureFont.lineHeight + renderer.lineSpace);
	}
	/**/

	private var whiteSpace:Bool = false;

    public function new(p_renderer:GTextureTextRenderer) {
		renderer = p_renderer;
    }
}
