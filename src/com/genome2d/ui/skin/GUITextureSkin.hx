package com.genome2d.ui.skin;
import com.genome2d.geom.GRectangle;
import com.genome2d.textures.GTextureManager;
import com.genome2d.textures.GContextTexture;
import com.genome2d.context.IContext;
import com.genome2d.textures.GTexture;

@prototypeName("textureSkin")
class GUITextureSkin extends GUISkin {
    public var texture:GTexture;

    @prototype public var sliceLeft:Int = 0;
    @prototype public var sliceTop:Int = 0;
    @prototype public var sliceRight:Int = 0;
    @prototype public var sliceBottom:Int = 0;

    #if swc @:extern #end
    @prototype public var textureId(get, set):String;
    #if swc @:getter(textureId) #end
    inline private function get_textureId():String {
        return (texture != null) ? texture.id : "";
    }
    #if swc @:setter(textureId) #end
    inline private function set_textureId(p_value:String):String {
        texture = GTextureManager.getTextureById(p_value);

        return p_value;
    }

    override public function getMinWidth():Float {
        return (texture != null) ? texture.width : 0;
    }

    override public function getMinHeight():Float {
        return (texture != null) ? texture.height : 0;
    }

    public function new(p_id:String = "", p_textureId:String = "") {
        super(p_id);

        textureId = p_textureId;
    }

    override public function render(p_left:Float, p_top:Float, p_right:Float, p_bottom:Float):Void {
        if (texture == null) return;
        var context:IContext = Genome2D.getInstance().getContext();

        var width:Float = p_right - p_left;
        var height:Float = p_bottom - p_top;
        var scaleX:Float = width/texture.width;
        var scaleY:Float = height/texture.height;
        var x:Float = p_left + (.5*texture.width + texture.pivotX)*scaleX;
        var y:Float = p_top + (.5*texture.height + texture.pivotY)*scaleY;
        var sl:Float = sliceLeft>texture.width/texture.scaleFactor ? texture.width/texture.scaleFactor : sliceLeft<0 ? 0 :sliceLeft;
        var st:Float = sliceTop>texture.height/texture.scaleFactor ? texture.height/texture.scaleFactor : sliceTop<0 ? 0 :sliceTop;
        var sr:Float = sliceRight>texture.width/texture.scaleFactor ? texture.width/texture.scaleFactor : sliceRight<sliceLeft ? sliceLeft : sliceRight;
        var sb:Float = sliceBottom>texture.height/texture.scaleFactor ? texture.height/texture.scaleFactor : sliceBottom<sliceTop ? sliceTop : sliceBottom;
        var sw:Float = sr-sl;
        var sh:Float = sb-st;

        var rx:Float = (texture.region != null) ? texture.region.x : 0;
        var ry:Float = (texture.region != null) ? texture.region.y : 0;

        if (sw == 0 || sh == 0) {
            context.draw(texture, x, y, scaleX, scaleY, 0, 1, 1, 1, 1, 1, null);
        } else {
            var scaleX:Float = (width-texture.width)/(sw*texture.scaleFactor) + 1;
            var scaleY:Float = (height-texture.height)/(sh*texture.scaleFactor) + 1;
            var tx:Float = 0;
            var ty:Float = 0;
            var tw:Float = sl;
            var th:Float = st;
            //trace("SLICE1", tx, ty, tw, th);
            if (tw != 0 && th != 0) {
                context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                   p_left, p_top, 1, 1, 0,
                                   1, 1, 1, 1,
                                   1, null);
            }

            tx = sl;
            tw = sw;
            //trace("SLICE2", tx, ty, tw, th);
            if (tw != 0 && th != 0) {
                context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                   p_left+sl*texture.scaleFactor, p_top, scaleX, 1, 0,
                                   1, 1, 1, 1,
                                   1, null);
            }
            /**/
            tx = sr;
            tw = texture.width/texture.scaleFactor-sr;
            //trace("SLICE3", tx, ty, tw, th);
            if (tw != 0 && th != 0) {
                context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                   p_left+(sl+sw*scaleX)*texture.scaleFactor, p_top, 1, 1, 0,
                                   1, 1, 1, 1,
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
                                   1, 1, 1, 1,
                                   1, null);
            }
            /**/
            tx = sl;
            tw = sw;
            //trace("SLICE5", tx, ty, tw, th);
            if (tw != 0 && th != 0) {
                context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                   p_left+sl*texture.scaleFactor, p_top+st*texture.scaleFactor, scaleX, scaleY, 0,
                                   1, 1, 1, 1,
                                   1, null);
            }
            /**/
            tx = sr;
            tw = texture.width/texture.scaleFactor-sr;
            //trace("SLICE6", tx, ty, tw, th);
            if (tw != 0 && th != 0) {
                context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                   p_left+(sl+sw*scaleX)*texture.scaleFactor, p_top+st*texture.scaleFactor, 1, scaleY, 0,
                                   1, 1, 1, 1,
                                   1, null);
            }
            /**/
            var tx:Float = 0;
            var ty:Float = sb;
            var tw:Float = sl;
            var th:Float = texture.height/texture.scaleFactor-sb;
            //trace("SLICE7", tx, ty, tw, th);
            if (tw != 0 && th != 0) {
                context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                   p_left, p_top+(st+sh*scaleY)*texture.scaleFactor, 1, 1, 0,
                                   1, 1, 1, 1,
                                   1, null);
            }
            /**/
            tx = sl;
            tw = sw;
            //trace("SLICE8", tx, ty, tw, th);
            if (tw != 0 && th != 0) {
                context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                   p_left+sl*texture.scaleFactor, p_top+(st+sh*scaleY)*texture.scaleFactor, scaleX, 1, 0,
                                   1, 1, 1, 1,
                                   1, null);
            }
            /**/
            tx = sr;
            tw = texture.width/texture.scaleFactor-sr;
            //trace("SLICE9", tx, ty, tw, th);
            if (tw != 0 && th != 0) {
                context.drawSource(texture, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                   p_left+(sl+sw*scaleX)*texture.scaleFactor, p_top+(st+sh*scaleY)*texture.scaleFactor, 1, 1, 0,
                                   1, 1, 1, 1,
                                   1, null);
            }
            /**/
        }
    }

    override public function getTexture():GContextTexture {
        return texture;
    }

    override public function clone():GUISkin {
        var clone:GUITextureSkin = new GUITextureSkin("", textureId);
        return clone;
    }
}
