package com.genome2d.ui.skin;
import com.genome2d.geom.GRectangle;
import com.genome2d.textures.GTextureManager;
import com.genome2d.textures.GTexture;
import com.genome2d.context.IGContext;
import com.genome2d.textures.GTexture;
import com.genome2d.ui.element.GUIElement;

@prototypeName("textureSkin")
class GUITextureSkin extends GUISkin {
	@reference
    public var texture:GTexture = null;

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
	public var bindTextureToModel:Bool = false;

    override public function getMinWidth():Float {
        return (texture != null && autoSize) ? texture.width : 0;
    }

    override public function getMinHeight():Float {
        return (texture != null && autoSize) ? texture.height : 0;
    }

    public function new(p_id:String = "", p_texture:GTexture = null, p_autoSize:Bool = true, p_origin:GUITextureSkin = null) {
        super(p_id, p_origin);

        texture = p_texture;
		autoSize = p_autoSize;
    }

    override public function render(p_left:Float, p_top:Float, p_right:Float, p_bottom:Float):Bool {
        var rendered:Bool = false;
		
        if (texture != null && super.render(p_left, p_top, p_right, p_bottom)) {
            var context:IGContext = Genome2D.getInstance().getContext();

            var width:Float = p_right - p_left;
            var height:Float = p_bottom - p_top;
            var scaleX:Float = width / texture.width;
            var scaleY:Float = height / texture.height;
            var x:Float = p_left + (.5 * texture.width + texture.pivotX) * scaleX;
            var y:Float = p_top + (.5 * texture.height + texture.pivotY) * scaleY;
            var sl:Float = sliceLeft>texture.nativeWidth ? texture.nativeWidth : sliceLeft<0 ? 0 :sliceLeft;
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
                context.draw(texture, x, y, scaleX, scaleY, 0, red, green, blue, alpha, 1, null);
            } else {
                var scaleX:Float = (width - texture.width) / (sw * texture.scaleFactor) + 1;
                var scaleY:Float = (height - texture.height) / (sh * texture.scaleFactor) +1;
                var tx:Float = 0;
                var ty:Float = 0;
                var tw:Float = sl;
                var th:Float = st;
				//trace("SLICE1", tx, ty, tw, th);
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left, p_top, 1, 1, 0,
                                       red, green, blue, alpha,
                                       1, null);
                }

                tx = sl;
                tw = sw;
                //trace("SLICE2", tx, ty, tw, th);
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+sl*texture.scaleFactor, p_top, scaleX, 1, 0,
                                       red, green, blue, alpha,
                                       1, null);
                }
                /**/
                tx = sr;
                tw = texture.width/texture.scaleFactor-sr;
                //trace("SLICE3", tx, ty, tw, th);
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+(sl+sw*scaleX)*texture.scaleFactor, p_top, 1, 1, 0,
                                       red, green, blue, alpha,
                                       1, null);
                }

                var tx:Float = 0;
                var ty:Float = st;
                var tw:Float = sl;
                var th:Float = sh;
                //trace("SLICE4", tx, ty, tw, th);
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left, p_top+st*texture.scaleFactor, 1, scaleY, 0,
                                       red, green, blue, alpha,
                                       1, null);
                }
                /**/
                tx = sl;
                tw = sw;
                //trace("SLICE5", tx, ty, tw, th);
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+sl*texture.scaleFactor, p_top+st*texture.scaleFactor, scaleX, scaleY, 0,
                                       red, green, blue, alpha,
                                       1, null);
                }
                /**/
                tx = sr;
                tw = texture.width/texture.scaleFactor-sr;
                //trace("SLICE6", tx, ty, tw, th);
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+(sl+sw*scaleX)*texture.scaleFactor, p_top+st*texture.scaleFactor, 1, scaleY, 0,
                                       red, green, blue, alpha,
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
                                       p_left, p_top+(st+sh*scaleY)*texture.scaleFactor, 1, 1, 0,
                                       red, green, blue, alpha,
                                       1, null);
                }
                /**/
                tx = sl;
                tw = sw;
                //trace("SLICE8", tx, ty, tw, th);
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+sl*texture.scaleFactor, p_top+(st+sh*scaleY)*texture.scaleFactor, scaleX, 1, 0,
                                       red, green, blue, alpha,
                                       1, null);
                }
                /**/
                tx = sr;
                tw = texture.width/texture.scaleFactor-sr;
                //trace("SLICE9", tx, ty, tw, th);
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       p_left+(sl+sw*scaleX)*texture.scaleFactor, p_top+(st+sh*scaleY)*texture.scaleFactor, 1, 1, 0,
                                       red, green, blue, alpha,
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
        return clone;
    }
	
	override private function elementModelChanged_handler(p_element:GUIElement):Void {
		if (bindTextureToModel) {
			texture =  (p_element.getModel() != null) ? GTextureManager.getTexture(p_element.getModel().toString()) : null;
		}
    }
}
