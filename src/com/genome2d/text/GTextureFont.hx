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
import com.genome2d.textures.GTextureManager;

class GTextureFont extends GFont {
	@prototype("getReference")
	public var texture:GTexture;
	
	@prototype
    public var lineHeight:Int = 0;

	@prototype
	public var base:Int = 0;

	@prototype
	public var face:String;

	@prototype
	public var italic:Bool = false;

	@prototype
	public var bold:Bool = false;

	@prototype
	public var regionOffsetX:Int = 0;

	@prototype
	public var regionOffsetY:Int = 0;

	public var kerning:Map<Int,Map<Int,Int>>;

	private var g2d_chars:Map<String,GTextureChar>;
	
	public function new():Void {
		g2d_chars = new Map<String,GTextureChar>();
	}

    public function getChar(p_subId:String):GTextureChar {
        return cast g2d_chars.get(p_subId);
    }

	public function addCharsFromXml(p_xml:Xml):Void {
		var root:Xml = p_xml.firstElement();

		var info:Xml = root.elementsNamed("info").next();
		face = info.get("face");
		italic = (info.get("italic") == "1")?true:false;
		bold = (info.get("bold") == "1")?true:false;

		var common:Xml = root.elementsNamed("common").next();
		lineHeight = Std.parseInt(common.get("lineHeight"));
		base = Std.parseInt(common.get("base"));

		var it:Iterator<Xml> = root.elementsNamed("chars");
		it = it.next().elements();

		while(it.hasNext()) {
			var node:Xml = it.next();
			var w:Int = Std.parseInt(node.get("width"));
			var h:Int = Std.parseInt(node.get("height"));
			var region:GRectangle = new GRectangle(Std.parseInt(node.get("x")) + regionOffsetX, Std.parseInt(node.get("y")) + regionOffsetY, w, h);

			addChar(node.get("id"), region, Std.parseFloat(node.get("xoffset")), Std.parseFloat(node.get("yoffset")), Std.parseFloat(node.get("xadvance")));
		}

		var kernings:Xml = root.elementsNamed("kernings").next();
		if (kernings != null) {
			it = kernings.elements();
			kerning = new Map<Int,Map<Int,Int>>();

			while(it.hasNext()) {
				var node:Xml = it.next();
				var first:Int = Std.parseInt(node.get("first"));
				var map:Map<Int,Int> = kerning.get(first);
				if (map == null) {
					map = new Map<Int,Int>();
					kerning.set(first, map);
				}
				var second:Int = Std.parseInt(node.get("second"));
				map.set(second, Std.parseInt(node.get("amount")));
			}
		}
	}

    public function addChar(p_charId:String, p_region:GRectangle, p_xoffset:Float, p_yoffset:Float, p_xadvance:Float):GTextureChar {
        var charTexture:GTexture = GTextureManager.createSubTexture(id+"_"+p_charId, texture, p_region);
		charTexture.pivotX = -p_region.width/2;
        charTexture.pivotY = -p_region.height/2;
		
		var char:GTextureChar = new GTextureChar(charTexture);
		char.xoffset = p_xoffset;
		char.yoffset = p_yoffset;
		char.xadvance = p_xadvance;
        g2d_chars.set(p_charId, char);

        return char;
    }

    public function getKerning(p_first:Int, p_second:Int):Float {
        if (kerning != null && kerning.exists(p_first)) {
            var map:Map<Int,Int> = kerning.get(p_first);
			if (!map.exists(p_second)) {
				return 0;
			} else {
				return map.get(p_second)*texture.scaleFactor;
			}
        }

        return 0;
    }

	override public function dispose():Void {
		super.dispose();

		for (char in g2d_chars) char.dispose();
		g2d_chars = null;
		texture = null;
	}

	static public function fromReference(p_reference:String):GTextureFont {
		return cast GFontManager.getFont(p_reference.substr(1));
	}
}