/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.text;
import com.genome2d.geom.GRectangle;
import com.genome2d.textures.GTexture;

class GFontManager
{
	static private var g2d_fonts:Map<String,GTextureFont>;
	
	static public function init():Void {
        g2d_fonts = new Map<String,GTextureFont>();
    }
	
	static public function getFont(p_id:String):GTextureFont {
		return g2d_fonts.get(p_id);
	}
	
	static public function createTextureFont(p_id:String, p_texture:GTexture, p_fontXml:Xml):GTextureFont {
        var textureFont:GTextureFont = new GTextureFont(p_id, p_texture);

        var root:Xml = p_fontXml.firstElement();

        var common:Xml = root.elementsNamed("common").next();
        textureFont.lineHeight = Std.parseInt(common.get("lineHeight"));

        var it:Iterator<Xml> = root.elementsNamed("chars");
        it = it.next().elements();

        while(it.hasNext()) {
            var node:Xml = it.next();
            var w:Int = Std.parseInt(node.get("width"));
            var h:Int = Std.parseInt(node.get("height"));
            var region:GRectangle = new GRectangle(Std.parseInt(node.get("x")), Std.parseInt(node.get("y")), w, h);

            var char:GTextureChar = textureFont.addChar(node.get("id"), region, Std.parseFloat(node.get("xoffset")), Std.parseFloat(node.get("yoffset")), Std.parseFloat(node.get("xadvance")));
        }

        var kernings:Xml = root.elementsNamed("kernings").next();
        if (kernings != null) {
            it = kernings.elements();
            textureFont.kerning = new Map<Int,Map<Int,Int>>();

            while(it.hasNext()) {
                var node:Xml = it.next();
                var first:Int = Std.parseInt(node.get("first"));
                var map:Map<Int,Int> = textureFont.kerning.get(first);
                if (map == null) {
                    map = new Map<Int,Int>();
                    textureFont.kerning.set(first, map);
                }
                var second:Int = Std.parseInt(node.get("second"));
                map.set(second, Std.parseInt("amount"));
            }
        }
		
		g2d_fonts.set(p_id, textureFont);
		
        return textureFont;
    }
	
	/*
    static public function createFromFont(p_id:String, p_textFormat:TextFormat, p_chars:String, p_embedded:Bool = true, p_horizontalPadding:Int = 0, p_verticalPadding:Int = 0, p_filters:Array<BitmapFilter> = null, p_forceMod2:Bool = false, p_format:String = "bgra"):GTextureAtlas {
        var text:TextField = new TextField();
        text.embedFonts = p_embedded;
        text.defaultTextFormat = p_textFormat;
        text.multiline = false;
        text.autoSize = TextFieldAutoSize.LEFT;

        if (p_filters != null) {
            text.filters = p_filters;
        }

        var bitmaps:Array<BitmapData> = new Array<BitmapData>();
        var ids:Array<String> = new Array<String>();
        var matrix:Matrix = new Matrix();
        matrix.translate(p_horizontalPadding, p_verticalPadding);

        for (i in 0...p_chars.length) {
            text.text = p_chars.charAt(i);
            var width:Float = (text.width%2 != 0 && p_forceMod2) ? text.width+1 : text.width;
            var height:Float = (text.height%2 != 0 && p_forceMod2) ? text.height+1 : text.height;
            var bitmapData:BitmapData = new BitmapData(untyped __int__(width+p_horizontalPadding*2), untyped __int__(height+p_verticalPadding*2), true, 0x0);
            bitmapData.draw(text, matrix);
            bitmaps.push(bitmapData);

            untyped ids.push(String(p_chars.charCodeAt(i)));
        }

        return createFromBitmapDatas(p_id, bitmaps, ids, p_format);
    }
	/**/	
}