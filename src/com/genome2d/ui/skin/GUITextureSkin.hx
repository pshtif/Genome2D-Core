package com.genome2d.ui.skin;
import com.genome2d.geom.GRectangle;
import com.genome2d.textures.GTextureManager;
import com.genome2d.textures.GTexture;
import com.genome2d.context.IGContext;
import com.genome2d.textures.GTexture;
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
	public var red:Float = 1;
	
	@prototype
	public var green:Float = 1;
	
	@prototype
	public var blue:Float = 1;
	
	@prototype
	public var alpha:Float = 1;
	
	@prototype
	public var scaleX:Float = 1;
	
	@prototype
	public var scaleY:Float = 1;
	
	@prototype
	public var rotation:Float = 0;
	
	@prototype
	public var bindTextureToModel:Bool = false;

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
		
        if (texture != null && super.render(p_left, p_top, p_right, p_bottom, p_red, p_green, p_blue, p_alpha)) {
            var context:IGContext = Genome2D.getInstance().getContext();

            var width:Float = p_right - p_left;
            var height:Float = p_bottom - p_top;
            var finalScaleX:Float = width / texture.width;
            var finalScaleY:Float = height / texture.height;
            var x:Float = p_left + (.5 * texture.width + texture.pivotX) * finalScaleX;
            var y:Float = p_top + (.5 * texture.height + texture.pivotY) * finalScaleY;
            var sl:Float = sliceLeft > texture.nativeWidth ? texture.nativeWidth : sliceLeft < 0 ? 0 :sliceLeft;
            var st:Float = sliceTop > texture.nativeHeight ? texture.nativeHeight : sliceTop < 0 ? 0 :sliceTop;
            var sr:Float = sliceRight > texture.nativeWidth ? texture.nativeWidth : sliceRight<sliceLeft ? sliceRight>=0 ? sliceLeft : texture.nativeWidth+sliceRight : sliceRight;
            var sb:Float = sliceBottom > texture.nativeHeight ? texture.nativeHeight : sliceBottom<sliceTop ? sliceBottom>=0 ? sliceTop : texture.nativeHeight+sliceBottom : sliceBottom;
            var sw:Float = sr - sl;
            var sh:Float = sb - st;
			if (sw == 0 && sh != 0) sr = sw = texture.nativeWidth;
			if (sh == 0 && sw != 0) sb = sh = texture.nativeHeight;

            var rx:Float = texture.u * texture.gpuWidth;// (texture.region != null) ? texture.region.x : 0;
            var ry:Float = texture.v * texture.gpuHeight;// (texture.region != null) ? texture.region.y : 0;

            if (sw == 0 || sh == 0) {
                context.draw(texture, x, y, finalScaleX, finalScaleY, rotation, red * p_red, green * p_green, blue * p_blue, alpha * p_alpha, 1, null);
            } else {
                var finalScaleX:Float = (width - texture.width) / (sw * texture.scaleFactor) + 1;
                var finalScaleY:Float = (height - texture.height) / (sh * texture.scaleFactor) +1;
                var tx:Float = 0;
                var ty:Float = 0;
                var tw:Float = sl;
                var th:Float = st;
				//trace("SLICE1", tx, ty, tw, th);
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left, p_top, 1, 1, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       1, null);
                }

                tx = sl;
                tw = sw;
                //trace("SLICE2", tx, ty, tw, th);
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+sl*texture.scaleFactor, p_top, finalScaleX, 1, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       1, null);
                }
                /**/
                tx = sr;
                tw = texture.width/texture.scaleFactor-sr;
                //trace("SLICE3", tx, ty, tw, th);
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+(sl+sw*finalScaleX)*texture.scaleFactor, p_top, 1, 1, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       1, null);
                }

                var tx:Float = 0;
                var ty:Float = st;
                var tw:Float = sl;
                var th:Float = sh;
                //trace("SLICE4", tx, ty, tw, th);
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left, p_top+st*texture.scaleFactor, 1, finalScaleY, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       1, null);
                }
                /**/
                tx = sl;
                tw = sw;
                //trace("SLICE5", tx, ty, tw, th);
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+sl*texture.scaleFactor, p_top+st*texture.scaleFactor, finalScaleX, finalScaleY, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       1, null);
                }
                /**/
                tx = sr;
                tw = texture.width/texture.scaleFactor-sr;
                //trace("SLICE6", tx, ty, tw, th);
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+(sl+sw*finalScaleX)*texture.scaleFactor, p_top+st*texture.scaleFactor, 1, finalScaleY, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       1, null);
                }
                /**/
                var tx:Float = 0;
                var ty:Float = sb;
                var tw:Float = sl;
                var th:Float = texture.nativeHeight-sb;
                //trace("SLICE7", tx, ty, tw, th);
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left, p_top+(st+sh*finalScaleY)*texture.scaleFactor, 1, 1, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       1, null);
                }
                /**/
                tx = sl;
                tw = sw;
                //trace("SLICE8", tx, ty, tw, th);
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+sl*texture.scaleFactor, p_top+(st+sh*finalScaleY)*texture.scaleFactor, finalScaleX, 1, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       1, null);
                }
                /**/
                tx = sr;
                tw = texture.width/texture.scaleFactor-sr;
                //trace("SLICE9", tx, ty, tw, th);
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+(sl+sw*finalScaleX)*texture.scaleFactor, p_top+(st+sh*finalScaleY)*texture.scaleFactor, 1, 1, 0,
                                       red*p_red, green*p_green, blue*p_blue, alpha*p_alpha,
                                       1, null);
                }
                /**/
            }
            rendered = true;
        }
        return rendered;
    }

    override public function getTexture():GTexture {
        return texture;
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
        return clone;
    }
	
	override private function elementModelChanged_handler(p_element:GUIElement):Void {
		if (bindTextureToModel) {
			texture =  (p_element.getModel() != null) ? GTextureManager.getTexture(p_element.getModel().toString()) : null;
		}
    }
}
