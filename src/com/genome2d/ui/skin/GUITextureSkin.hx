package com.genome2d.ui.skin;

import com.genome2d.context.GBlendMode;
import com.genome2d.context.filters.GFilter;
import com.genome2d.proto.GPrototype;
import com.genome2d.textures.GTextureManager;
import com.genome2d.textures.GTexture;
import com.genome2d.context.IGContext;
import com.genome2d.ui.element.GUIElement;

@prototypeName("textureSkin")
class GUITextureSkin extends GUISkin {
	private var g2d_textureOverride:Bool = false;
	private var g2d_texture:GTexture;
    #if swc @:extern #end
    @prototype("getReference")
	public var texture(get, set):GTexture;
    #if swc @:getter(texture) #end
    inline private function get_texture():GTexture {
        return g2d_texture;
    }
    #if swc @:setter(texture) #end
    inline private function set_texture(p_value:GTexture):GTexture {
		g2d_texture = p_value;
		if (g2d_origin == null) {
			invalidateClones();
		} else {
			g2d_textureOverride = g2d_texture != cast (g2d_origin, GUITextureSkin).g2d_texture;
		}
        return g2d_texture;
    }

    @prototype 
	public var sliceLeft:Int = 0;
	
    @prototype 
	public var sliceTop:Int = 0;
	
    @prototype 
	public var sliceRight:Int = 0;
	
    @prototype 
	public var sliceBottom:Int = 0;
	
	@prototype
	public var autoSize:Bool = true;
	
	@prototype
	public var scaleX:Float = 1;
	
	@prototype
	public var scaleY:Float = 1;
	
	@prototype
	public var rotation:Float = 0;
	
	@prototype
	public var tiled:Bool = false;
	
	@prototype
	public var usePivot:Bool = false;
	
	@prototype
	public var bindTextureToModel:Bool = false;
	
	public var filter:GFilter;

    override public function getMinWidth():Float {
        return (texture != null && autoSize) ? texture.width * scaleX : 0;
    }

    override public function getMinHeight():Float {
        return (texture != null && autoSize) ? texture.height * scaleY : 0;
    }

    public function new(p_id:String = "", p_texture:GTexture = null, p_autoSize:Bool = true, p_origin:GUITextureSkin = null) {
        super(p_id, p_origin);

        g2d_texture = p_texture;
		autoSize = p_autoSize;
    }

    override public function render(p_left:Float, p_top:Float, p_right:Float, p_bottom:Float, p_red:Float, p_green:Float, p_blue:Float, p_alpha:Float):Bool {
        var rendered:Bool = false;

        if (forcePixelAccuracy) {
            p_left = Math.round(p_left);
            p_top = Math.round(p_top);
            p_right = Math.round(p_right);
            p_bottom = Math.round(p_bottom);
        }
		
        if (texture != null && super.render(p_left, p_top, p_right, p_bottom, p_red, p_green, p_blue, p_alpha)) {
            var context:IGContext = Genome2D.getInstance().getContext();

            var width:Float = p_right - p_left;
            var height:Float = p_bottom - p_top;
            var finalScaleX:Float = width / texture.width;
            var finalScaleY:Float = height / texture.height;

            var sl:Float = sliceLeft > texture.nativeWidth ? texture.nativeWidth : sliceLeft < 0 ? 0 : sliceLeft;
            var st:Float = sliceTop > texture.nativeHeight ? texture.nativeHeight : sliceTop < 0 ? 0 : sliceTop;
            var sr:Float = sliceRight > texture.nativeWidth ? texture.nativeWidth : sliceRight < sliceLeft ? sliceRight>=0 ? sliceLeft : texture.nativeWidth + sliceRight : sliceRight;
            var sb:Float = sliceBottom > texture.nativeHeight ? texture.nativeHeight : sliceBottom < sliceTop ? sliceBottom>=0 ? sliceTop : texture.nativeHeight + sliceBottom : sliceBottom;
            var sw:Float = sr - sl;
            var sh:Float = sb - st;
			if (sw == 0 && sh != 0) sr = sw = texture.nativeWidth;
			if (sh == 0 && sw != 0) sb = sh = texture.nativeHeight;

            if (sw == 0 || sh == 0) {
				if (tiled) {
					if (texture.repeatable) {
						texture.uScale = finalScaleX;
						texture.vScale = finalScaleY;
						var x:Float = p_left + (.5 * texture.width + (usePivot?0:texture.pivotX)) * finalScaleX;
						var y:Float = p_top + (.5 * texture.height + (usePivot?0:texture.pivotY)) * finalScaleY;
						context.draw(texture, GBlendMode.NORMAL, x, y, finalScaleX, finalScaleY, rotation, red * p_red, green * p_green, blue * p_blue, alpha * p_alpha, filter);
					} else {
						var rx:Float = texture.u * texture.gpuWidth;// (texture.region != null) ? texture.region.x : 0;
						var ry:Float = texture.v * texture.gpuHeight;// (texture.region != null) ? texture.region.y : 0;
						var x:Float = p_left + (.5 * texture.width + texture.pivotX);
						var y:Float = p_top + (.5 * texture.height + texture.pivotY);
						finalScaleX /= scaleX;
						finalScaleY /= scaleY;
						for (i in 0...Math.ceil(finalScaleX)) {
							for (j in 0...Math.ceil(finalScaleY)) {
								var sx:Float = (finalScaleX - i > 1) ? 1 : (finalScaleX - i);
								var sy:Float = (finalScaleY - j > 1) ? 1 : (finalScaleY - j);
								var px:Float = (texture.nativeWidth / 2 + texture.pivotX) - sx * scaleX * texture.nativeWidth / 2;
								var py:Float = (texture.nativeHeight / 2 + texture.pivotY) - sy * scaleY * texture.nativeHeight / 2;
								context.drawSource(texture, GBlendMode.NORMAL, rx, ry, sx*texture.nativeWidth, sy*texture.nativeHeight, 0, 0, x+i*texture.width*scaleX-px, y+j*texture.height*scaleY-py, scaleX, scaleY, rotation, red * p_red, green * p_green, blue * p_blue, alpha * p_alpha, filter);
							}
						}
					}
				} else {
					var x:Float = p_left + (.5 * texture.width + (usePivot?0:texture.pivotX)) * finalScaleX;
					var y:Float = p_top + (.5 * texture.height + (usePivot?0:texture.pivotY)) * finalScaleY;
					context.draw(texture, GBlendMode.NORMAL, x, y, finalScaleX, finalScaleY, rotation, red * p_red, green * p_green, blue * p_blue, alpha * p_alpha, filter);
				}
            } else {
				var rx:Float = texture.u * texture.gpuWidth;// (texture.region != null) ? texture.region.x : 0;
				var ry:Float = texture.v * texture.gpuHeight;// (texture.region != null) ? texture.region.y : 0;
				
                var finalScaleX:Float = (width - texture.width * scaleX) / (sw * texture.scaleFactor) + scaleX;
                var finalScaleY:Float = (height - texture.height * scaleY) / (sh * texture.scaleFactor) + scaleY;
											
                var tx:Float = 0;
                var ty:Float = 0;
                var tw:Float = sl;
                var th:Float = st;
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left, p_top, scaleX, scaleY, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       filter);
                }
				/**/
                tx = sl;
                tw = sw;
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+sl*texture.scaleFactor*scaleX, p_top, finalScaleX, scaleY, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       filter);
                }
                /**/
                tx = sr;
                tw = texture.width / texture.scaleFactor - sr;
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+(sl*scaleX+sw*finalScaleX)*texture.scaleFactor, p_top, scaleX, scaleY, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       filter);
                }
				/**/
                tx = 0;
                ty = st;
                tw = sl;
                th = sh;
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left, p_top+st*texture.scaleFactor*scaleY, scaleX, finalScaleY, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       filter);
                }
                /**/
                tx = sl;
                tw = sw;
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+sl*texture.scaleFactor*scaleX, p_top+st*texture.scaleFactor*scaleY, finalScaleX, finalScaleY, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       filter);
                }
                /**/
                tx = sr;
                tw = texture.width/texture.scaleFactor-sr;

                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+(sl*scaleX+sw*finalScaleX)*texture.scaleFactor, p_top+st*texture.scaleFactor*scaleY, scaleX, finalScaleY, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       filter);
                }
                /**/
                tx = 0;
                ty = sb;
                tw = sl;
                th = texture.nativeHeight-sb;
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left, p_top+(st*scaleY+sh*finalScaleY)*texture.scaleFactor, scaleX, scaleY, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       filter);
                }
                /**/
                tx = sl;
                tw = sw;
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+sl*texture.scaleFactor*scaleX, p_top+(st*scaleY+sh*finalScaleY)*texture.scaleFactor, finalScaleX, scaleY, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       filter);
                }
                /**/
                tx = sr;
                tw = texture.width/texture.scaleFactor-sr;
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+(sl*scaleX+sw*finalScaleX)*texture.scaleFactor, p_top+(st*scaleY+sh*finalScaleY)*texture.scaleFactor, scaleX, scaleY, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       filter);
                }
                /**/
            }
            rendered = true;
        }
        return rendered;
    }

    override private function getTexture():GTexture {
        return texture;
    }
	
	override private function getFilter():GFilter {
		return filter;
	}
	
	override private function invalidateClones():Void {
		for (clone in g2d_clones) {
			var textureSkinClone:GUITextureSkin = cast clone;
			if (!textureSkinClone.g2d_textureOverride) textureSkinClone.g2d_texture = g2d_texture;
		}
	}

    override public function clone():GUISkin {
        var clone:GUITextureSkin = new GUITextureSkin("", texture, autoSize, (g2d_origin == null)?this:cast g2d_origin);
		clone.sliceLeft = sliceLeft;
		clone.sliceTop = sliceTop;
		clone.sliceRight = sliceRight;
		clone.sliceBottom = sliceBottom;
		clone.bindTextureToModel = bindTextureToModel;
		clone.red = red;
		clone.green = green;
		clone.blue = blue;
		clone.alpha = alpha;
		clone.scaleX = scaleX;
		clone.scaleY = scaleY;
		clone.rotation = rotation;
		clone.tiled = tiled;
		clone.usePivot = usePivot;
		clone.filter = filter;
        return clone;
    }
	
	override private function elementModelChanged_handler(p_element:GUIElement):Void {
		if (bindTextureToModel) {
			texture =  (p_element.model != null) ? GTextureManager.getTexture(p_element.model) : null;
		}
    }
	
	override public function bindPrototype(p_prototype:GPrototype):Void {
		bindPrototypeDefault(p_prototype);
		
		if (g2d_origin == null) {
			if (p_prototype.getProperty("id").value != "") {
				g2d_id = p_prototype.getProperty("id").value;
				GUISkinManager.g2d_addSkin(g2d_id, this);
			}
		}
	}
}
