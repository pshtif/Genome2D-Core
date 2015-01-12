package com.genome2d.ui.skin;
import com.genome2d.geom.GRectangle;
import com.genome2d.textures.GTextureManager;
import com.genome2d.textures.GContextTexture;
import com.genome2d.context.IContext;
import com.genome2d.textures.GTexture;

@prototypeName("textureSkin")
class GUITextureSkin extends GUISkin {
    public var texture:GTexture;

    private var g2d_sliceRect:GRectangle;

    override private function setValue(p_value:String):Void {
        textureId = p_value;
    }

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

        if (g2d_sliceRect == null || g2d_sliceRect.width == 0 || g2d_sliceRect.height == 0) {
            context.draw(texture, x, y, scaleX, scaleY, 0, 1, 1, 1, 1, 1, null);
        } else {
            var scaleX:Float = (width-texture.width)/(g2d_sliceRect.width*texture.scaleFactor) + 1;
            var scaleY:Float = (height-texture.height)/(g2d_sliceRect.height*texture.scaleFactor) + 1;
            var tx:Float = 0;
            var ty:Float = 0;
            var tw:Float = g2d_sliceRect.x;
            var th:Float = g2d_sliceRect.y;
            if (tw != 0 && th != 0) {
                context.drawSource(texture, texture.region.x+tx, texture.region.y+ty, tw, th, -tw*.5, -th*.5,
                                   p_left, p_top, 1, 1, 0,
                                   1, 1, 1, 1,
                                   1, null);
            }
            tx = g2d_sliceRect.x;
            tw = g2d_sliceRect.width;
            if (tw != 0 && th != 0) {
                context.drawSource(texture, texture.region.x+tx, texture.region.y+ty, tw, th, -tw*.5, -th*.5,
                                   p_left+g2d_sliceRect.x*texture.scaleFactor, p_top, scaleX, 1, 0,
                                   1, 1, 1, 1,
                                   1, null);
            }
            tx = g2d_sliceRect.right;
            tw = texture.width/texture.scaleFactor-g2d_sliceRect.right;
            if (tw != 0 && th != 0) {
                context.drawSource(texture, texture.region.x+tx, texture.region.y+ty, tw, th, -tw*.5, -th*.5,
                                   p_left+(g2d_sliceRect.x+g2d_sliceRect.width*scaleX)*texture.scaleFactor, p_top, 1, 1, 0,
                                   1, 1, 1, 1,
                                   1, null);
            }

            var tx:Float = 0;
            var ty:Float = g2d_sliceRect.y;
            var tw:Float = g2d_sliceRect.x;
            var th:Float = g2d_sliceRect.height;
            if (tw != 0 && th != 0) {
                context.drawSource(texture, texture.region.x+tx, texture.region.y+ty, tw, th, -tw*.5, -th*.5,
                                   p_left, p_top+g2d_sliceRect.y*texture.scaleFactor, 1, scaleY, 0,
                                   1, 1, 1, 1,
                                   1, null);
            }
            tx = g2d_sliceRect.x;
            tw = g2d_sliceRect.width;
            if (tw != 0 && th != 0) {
                context.drawSource(texture, texture.region.x+tx, texture.region.y+ty, tw, th, -tw*.5, -th*.5,
                                   p_left+g2d_sliceRect.x*texture.scaleFactor, p_top+g2d_sliceRect.y*texture.scaleFactor, scaleX, scaleY, 0,
                                   1, 1, 0, 1,
                                   1, null);
            }
            tx = g2d_sliceRect.right;
            tw = texture.width/texture.scaleFactor-g2d_sliceRect.right;
            if (tw != 0 && th != 0) {
                context.drawSource(texture, texture.region.x+tx, texture.region.y+ty, tw, th, -tw*.5, -th*.5,
                                   p_left+(g2d_sliceRect.x+g2d_sliceRect.width*scaleX)*texture.scaleFactor, p_top+g2d_sliceRect.y*texture.scaleFactor, 1, scaleY, 0,
                                   1, 1, 1, 1,
                                   1, null);
            }

            var tx:Float = 0;
            var ty:Float = g2d_sliceRect.bottom;
            var tw:Float = g2d_sliceRect.x;
            var th:Float = texture.height/texture.scaleFactor-g2d_sliceRect.height;
            if (tw != 0 && th != 0) {
                context.drawSource(texture, texture.region.x+tx, texture.region.y+ty, tw, th, -tw*.5, -th*.5,
                                   p_left, p_top+(g2d_sliceRect.y+g2d_sliceRect.height*scaleY)*texture.scaleFactor, 1, 1, 0,
                                   1, 1, 1, 1,
                                   1, null);
            }
            tx = g2d_sliceRect.x;
            tw = g2d_sliceRect.width;
            if (tw != 0 && th != 0) {
                context.drawSource(texture, texture.region.x+tx, texture.region.y+ty, tw, th, -tw*.5, -th*.5,
                                   p_left+g2d_sliceRect.x*texture.scaleFactor, p_top+(g2d_sliceRect.y+g2d_sliceRect.height*scaleY)*texture.scaleFactor, scaleX, 1, 0,
                                   1, 1, 1, 1,
                                   1, null);
            }
            tx = g2d_sliceRect.right;
            tw = texture.width/texture.scaleFactor-g2d_sliceRect.right;
            if (tw != 0 && th != 0) {
                context.drawSource(texture, texture.region.x+tx, texture.region.y+ty, tw, th, -tw*.5, -th*.5,
                                   p_left+(g2d_sliceRect.x+g2d_sliceRect.width*scaleX)*texture.scaleFactor, p_top+(g2d_sliceRect.y+g2d_sliceRect.height*scaleY)*texture.scaleFactor, 1, scaleY, 0,
                                   1, 1, 1, 1,
                                   1, null);
            }
        }
    }

    override public function getTexture():GContextTexture {
        return texture;
    }
}
