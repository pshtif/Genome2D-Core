/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.text;
import com.genome2d.debug.GDebug;
import com.genome2d.textures.GTexture;

class GFontManager
{
    static private function g2d_addFont(p_font:GFont):Void {
        if (p_font.id == null || p_font.id.length == 0) GDebug.error("Invalid font id");
        if (g2d_fonts.exists(p_font.id)) GDebug.error("Duplicate font id: "+p_font.id);
        g2d_fonts.set(p_font.id, p_font);
    }

    static private function g2d_removeFont(p_font:GFont):Void {
        g2d_fonts.remove(p_font.id);
    }

	static private var g2d_fonts:Map<String,GFont>;
	static public function getAllFonts():Map<String,GFont> {
		return g2d_fonts;
	}
	
	static public function init():Void {
        g2d_fonts = new Map<String,GFont>();
    }
	
	static public function getFont(p_id:String):GFont {
		return g2d_fonts.get(p_id);
	}
	
	static public function createTextureFont(p_id:String, p_texture:GTexture, p_fontXml:Xml, p_regionOffsetX:Int = 0, p_regionOffsetY:Int = 0):GTextureFont {
        var textureFont:GTextureFont = new GTextureFont();
        textureFont.id = p_id;
        textureFont.texture = p_texture;
        textureFont.regionOffsetX = p_regionOffsetX;
        textureFont.regionOffsetY = p_regionOffsetY;

        textureFont.addCharsFromXml(p_fontXml);
		
        return textureFont;
    }
	
	/*
    static public function createFromFont(p_id:String, p_textFormat:TextFormat, p_chars:String, p_embedded:Bool = true, p_horizontalPadding:Int = 0, p_verticalPadding:Int = 0, p_filters:Array<BitmapFilter> = null, p_forceMod2:Bool = false, p_format:String = "bgra"):GTextureAtlas {
        var text:TextField = GParameters TextField();
        text.embedFonts = p_embedded;
        text.defaultTextFormat = p_textFormat;
        text.multiline = false;
        text.autoSize = TextFieldAutoSize.LEFT;

        if (p_filters != null) {
            text.filters = p_filters;
        }

        var bitmaps:Array<BitmapData> = GParameters Array<BitmapData>();
        var ids:Array<String> = GParameters Array<String>();
        var matrix:Matrix = GParameters Matrix();
        matrix.translate(p_horizontalPadding, p_verticalPadding);

        for (i in 0...p_chars.length) {
            text.text = p_chars.charAt(i);
            var width:Float = (text.width%2 != 0 && p_forceMod2) ? text.width+1 : text.width;
            var height:Float = (text.height%2 != 0 && p_forceMod2) ? text.height+1 : text.height;
            var bitmapData:BitmapData = GParameters BitmapData(untyped __int__(width+p_horizontalPadding*2), untyped __int__(height+p_verticalPadding*2), true, 0x0);
            bitmapData.draw(text, matrix);
            bitmaps.push(bitmapData);

            untyped ids.push(String(p_chars.charCodeAt(i)));
        }

        return createFromBitmapDatas(p_id, bitmaps, ids, p_format);
    }
	/**/	
}