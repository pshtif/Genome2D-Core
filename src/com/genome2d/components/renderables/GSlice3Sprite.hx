package com.genome2d.components.renderables;
import com.genome2d.signals.GMouseSignal;
import com.genome2d.geom.GRectangle;
import com.genome2d.geom.GMatrix;
import com.genome2d.context.GContextCamera;
import com.genome2d.context.filters.GFilter;
import com.genome2d.textures.GTexture;
class GSlice3Sprite extends GTiledSprite {
    public var texture1:GTexture;
    public var texture2:GTexture;
    public var texture3:GTexture;

    @:dox(hide)
    override public function render(p_camera:GContextCamera, p_useMatrix:Bool):Void {
        // Calculate rotation
        var sin:Float = 0;
        var cos:Float = 1;
        if (node.transform.g2d_worldRotation != 0) {
            sin = Math.sin(node.transform.g2d_worldRotation);
            cos = Math.cos(node.transform.g2d_worldRotation);
        }

        var ix:Int = Math.ceil(g2d_width/texture1.width);
        var iy:Int = Math.ceil(g2d_height/texture1.height);

        var w:Float = texture1.uvScaleX*texture1.gpuWidth;
        var h:Float = texture1.uvScaleY*texture1.gpuHeight;
        var cw:Float = w;
        var ch:Float = h;
        var cx:Float = 0;
        var cy:Float = 0;

        for (j in 0...iy) {
            for (i in 0...ix) {
                if (i==0) texture = texture1; else if (i==ix-1) texture = texture3; else texture = texture2;

                cw = (i==ix-2 && i!=0 && g2d_width%texture.width!=0) ? w*(g2d_width%texture.width)/texture.width : w;
                ch = (j==iy-1 && g2d_height%texture.height!=0) ? h*(g2d_height%texture.height)/texture.height : h;
                node.core.getContext().drawSource(texture,
                                                  texture.uvX*texture.gpuWidth, texture.uvY*texture.gpuHeight, cw, ch, -cw*.5, -ch*.5,
                                                  node.transform.g2d_worldX+cx*cos-cy*sin, node.transform.g2d_worldY+cy*cos+cx*sin, node.transform.g2d_worldScaleX, node.transform.g2d_worldScaleY, node.transform.g2d_worldRotation,
                                                  node.transform.g2d_worldRed, node.transform.g2d_worldGreen, node.transform.g2d_worldBlue, node.transform.g2d_worldAlpha,
                                                  blendMode, filter);
                cx += cw*node.transform.g2d_worldScaleX;
            }
            cx = 0;
            cy += ch*node.transform.g2d_worldScaleY;
        }
    }
}
