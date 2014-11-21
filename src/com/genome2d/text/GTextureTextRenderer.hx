package com.genome2d.text;
import com.genome2d.utils.GHAlignType;
import com.genome2d.utils.GVAlignType;
import com.genome2d.context.IContext;
import com.genome2d.textures.GCharTexture;
import com.genome2d.context.GCamera;
import com.genome2d.textures.GTextureFontAtlas;
class GTextureTextRenderer extends GTextRenderer {

    private var g2d_textureAtlas:GTextureFontAtlas;
    /*
     *  Texture atlas id used for character textures lookup
     */
    #if swc @:extern #end
    @prototype public var textureAtlasId(get, set):String;
    #if swc @:getter(textureAtlasId) #end
    inline private function get_textureAtlasId():String {
        if (g2d_textureAtlas != null) return g2d_textureAtlas.getId();
        return "";
    }
    #if swc @:setter(textureAtlasId) #end
    inline private function set_textureAtlasId(p_value:String):String {
        setTextureAtlas(GTextureFontAtlas.getTextureFontAtlasById(p_value));
        return p_value;
    }

    /*
     *  Set textures atlas that will be used for character textures lookup
     */
    public function setTextureAtlas(p_textureAtlas:GTextureFontAtlas):Void {
        g2d_textureAtlas = p_textureAtlas;
        g2d_dirty = true;
    }

    private var g2d_chars:Array<GTextureChar>;

    override public function render(p_x:Float, p_y:Float, p_scaleX:Float, p_scaleY:Float, p_rotation:Float):Void {
        if (g2d_dirty) invalidate();

        var charCount:Int = g2d_chars.length;
        var cos:Float = 1;
        var sin:Float = 0;
        if (p_rotation != 0) {
            cos = Math.cos(p_rotation);
            sin = Math.sin(p_rotation);
        }

        for (i in 0...charCount) {
            var char:GTextureChar = g2d_chars[i];
            if (!char.g2d_visible) break;

            var tx:Float = char.g2d_x * p_scaleX + p_x;
            var ty:Float = char.g2d_y * p_scaleY + p_y;
            if (p_rotation != 0) {
                tx = (char.g2d_x * cos - char.g2d_y * sin) * p_scaleX + p_x;
                ty = (char.g2d_y * cos + char.g2d_x * sin) * p_scaleY + p_y;
            }

            g2d_context.draw(char.g2d_texture, tx, ty, p_scaleX, p_scaleY, p_rotation, 1, 1, 1, 1, 1, null);
        }
    }

    override public function invalidate():Void {
        if (g2d_textureAtlas == null) return;
        if (g2d_chars == null) g2d_chars = new Array<GTextureChar>();

        if (g2d_autoSize) {
            g2d_width = 0;
        }
        var offsetX:Float = 0;
        var offsetY:Float =  0;
        var char:GTextureChar;
        var texture:GCharTexture = null;
        var currentCharCode:Int = -1;
        var previousCharCode:Int = -1;
        var lastChar:Int = 0;

        var lines:Array<Array<GTextureChar>> = new Array<Array<GTextureChar>>();
        var currentLine:Array<GTextureChar> = new Array<GTextureChar>();
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
                currentLine = new Array<GTextureChar>();
                if (!g2d_autoSize && offsetY + 2*(g2d_textureAtlas.lineHeight + g2d_lineSpace) > g2d_height) break;
                offsetX = 0;
                offsetY += g2d_textureAtlas.lineHeight + g2d_lineSpace;
            } else {
                currentCharCode = g2d_text.charCodeAt(i);
                texture = g2d_textureAtlas.getSubTexture(Std.string(currentCharCode));
                if (texture == null) {
                    //++i;
                    continue;// throw new GError("Texture for character "+g2d_text.charAt(i)+" with code "+g2d_text.charCodeAt(i)+" not found!");
                }

                if (previousCharCode != -1) {
                    offsetX += g2d_textureAtlas.getKerning(previousCharCode,currentCharCode);
                }

                if (currentCharCode != 32) {
                    if (charIndex>=g2d_chars.length) {
                        char = new GTextureChar();
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
                        currentLine = new Array<GTextureChar>();
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
            g2d_width = (offsetX>g2d_width) ? offsetX : g2d_width;
            g2d_height = offsetY + g2d_textureAtlas.lineHeight;
        }

        var bottom:Float = offsetY + g2d_textureAtlas.lineHeight;
        var offsetY:Float = 0;
        if (g2d_vAlign == GVAlignType.MIDDLE) {
            offsetY = (g2d_height - bottom) * .5;
        } else if (g2d_vAlign == GVAlignType.BOTTOM) {
            offsetY = g2d_height - bottom;
        }

        for (i in 0...lines.length) {
            var currentLine:Array<GTextureChar> = lines[i];

            charCount = currentLine.length;
            if (charCount == 0) continue;
            var offsetX:Float = 0;
            var last:GTextureChar = currentLine[charCount-1];
            var right:Float = last.g2d_x - last.g2d_texture.xoffset + last.g2d_texture.xadvance;

            if (g2d_hAlign == GHAlignType.CENTER) {
                offsetX = (g2d_width - right) * .5;
           } else if (g2d_hAlign == GHAlignType.RIGHT) {
                offsetX = g2d_width - right;
            }

            for (j in 0...charCount) {
                var char:GTextureChar = currentLine[j];
                char.g2d_x = char.g2d_x + offsetX;
                char.g2d_y = char.g2d_y + offsetY;
            }
        }

        g2d_dirty = false;
    }
}

@:allow(com.genome2d.text.GTextureTextRenderer)
class GTextureChar
{
    private var g2d_code:Int;
    private var g2d_texture:GCharTexture;

    private var g2d_x:Float;
    private var g2d_y:Float;

    private var g2d_visible:Bool = false;

    public function new() {
    }
}
