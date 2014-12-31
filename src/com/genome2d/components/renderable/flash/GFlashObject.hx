#if flash
package com.genome2d.components.renderable.flash;

import com.genome2d.geom.GRectangle;
import com.genome2d.utils.GHAlignType;
import com.genome2d.utils.GVAlignType;
import flash.display.DisplayObject;
import com.genome2d.context.GBlendMode;
import com.genome2d.node.GNode;
import com.genome2d.textures.GTextureUtils;
import flash.display.BitmapData;
import com.genome2d.geom.GMatrix;
import com.genome2d.components.renderable.GTexturedQuad;
import com.genome2d.textures.GTextureManager;

class GFlashObject extends GTexturedQuad {
    static public var defaultUpdateFrameRate:Int = 20;

    public var nativeObject:DisplayObject;

    private var g2d_forceMod2:Bool = true;
    #if swc @:extern #end
    public var forceMod2(get,set):Bool;
    #if swc @:getter(forceMod2) #end
    inline private function get_forceMod2():Bool {
        return g2d_forceMod2;
    }
    #if swc @:setter(forceMod2) #end
    inline private function set_forceMod2(p_value:Bool):Bool {
        g2d_forceMod2 = p_value;
        g2d_invalidate = true;
        return g2d_forceMod2;
    }

    private var g2d_vAlign:Int = GVAlignType.MIDDLE;
    #if swc @:extern #end
    public var vAlign(get,set):Int;
    #if swc @:getter(vAlign) #end
    inline private function get_vAlign():Int {
        return g2d_vAlign;
    }
    #if swc @:setter(vAlign) #end
    inline private function set_vAlign(p_value:Int):Int {
        g2d_vAlign = p_value;
        g2d_invalidateAlign();
        return g2d_vAlign;
    }

    private var g2d_hAlign:Int = GHAlignType.CENTER;
    #if swc @:extern #end
    public var hAlign(get,set):Int;
    #if swc @:getter(hAlign) #end
    inline private function get_hAlign():Int {
        return g2d_hAlign;
    }
    #if swc @:setter(hAlign) #end
    inline private function set_hAlign(p_value:Int):Int {
        g2d_hAlign = p_value;
        g2d_invalidateAlign();
        return g2d_hAlign;
    }

    private var g2d_nativeMatrix:GMatrix;

    private var g2d_textureId:String;

    private var g2d_invalidate:Bool = false;
    public function invalidate(p_force:Bool = false):Void {
        if (p_force) invalidateTexture(true);
        else g2d_invalidate = true;
    }

    private var g2d_lastNativeWidth:Int = 0;
    private var g2d_lastNativeHeight:Int = 0;
    private var g2d_accumulatedTime:Float = 0;

    public var updateFrameRate:Int = defaultUpdateFrameRate;

    private var g2d_transparent:Bool = false;
    #if swc @:extern #end
    public var transparent(get,set):Bool;
    #if swc @:getter(transparent) #end
    public function get_transparent():Bool {
        return g2d_transparent;
    }
    #if swc @:setter(transparent) #end
    public function set_transparent(p_transparent:Bool):Bool {
        g2d_transparent = p_transparent;
        if (nativeObject != null) invalidateTexture(true);
        return g2d_transparent;
    }

    static private var g2d_count:Int = 0;

    override public function init():Void {
        blendMode = GBlendMode.NONE;
        g2d_textureId = "GFlashObject#"+g2d_count++;
        g2d_nativeMatrix = new GMatrix();

        node.core.onUpdate.add(g2d_updateHandler);
    }

    private function g2d_updateHandler(p_deltaTime:Float):Void {
        if (nativeObject != null && (updateFrameRate != 0 || g2d_invalidate)) {
            invalidateTexture(false);

            g2d_accumulatedTime += p_deltaTime;
            var updateTime:Float = 1000/updateFrameRate;
            if (g2d_invalidate || g2d_accumulatedTime > updateTime) {
                //texture.g2d_bitmapData.fillRect(texture.g2d_bitmapData.rect, 0x0);
                var bounds:GRectangle = nativeObject.getBounds(nativeObject);
                g2d_nativeMatrix.tx = -bounds.x;
                g2d_nativeMatrix.ty = -bounds.y;
                //texture.g2d_bitmapData.draw(nativeObject, g2d_nativeMatrix);
                texture.invalidateNativeTexture(false);

                g2d_accumulatedTime %= updateTime;
            }

            g2d_invalidate = false;
        }
    }

    public function invalidateTexture(p_force:Bool):Void {
        if (nativeObject == null) return;
        if (!p_force && g2d_lastNativeWidth == nativeObject.width && g2d_lastNativeHeight == nativeObject.height) return;

        g2d_lastNativeWidth = Std.int(nativeObject.width);
        g2d_lastNativeHeight = Std.int(nativeObject.height);

        var bitmapData:BitmapData;
        if (forceMod2) {
            bitmapData = new BitmapData((g2d_lastNativeWidth%2==0) ? g2d_lastNativeWidth : g2d_lastNativeWidth+1, (g2d_lastNativeHeight%2==0) ? g2d_lastNativeHeight : g2d_lastNativeHeight+1, g2d_transparent, 0x0);
        } else {
            bitmapData = new BitmapData(g2d_lastNativeWidth, g2d_lastNativeHeight, g2d_transparent, 0x0);
        }

        if (texture == null || texture.gpuWidth != GTextureUtils.getNextValidTextureSize(g2d_lastNativeWidth) || texture.gpuHeight != GTextureUtils.getNearestValidTextureSize(g2d_lastNativeHeight)) {
            if(texture != null) texture.dispose();
            texture = GTextureManager.createTextureFromBitmapData(g2d_textureId, bitmapData);
        } else {
            //texture.g2d_bitmapData = bitmapData;
            //texture.setRegion(bitmapData.rect);
        }

        g2d_invalidateAlign();

        g2d_invalidate = true;
    }

    private function g2d_invalidateAlign():Void {
        switch (vAlign) {
            case GVAlignType.TOP:
                texture.pivotY = -texture.height*.5;
            case GVAlignType.MIDDLE:
                texture.pivotY = 0;
            case GVAlignType.BOTTOM:
                texture.pivotY = texture.height*.5;
        }
        switch (hAlign) {
            case GHAlignType.LEFT:
                texture.pivotX = -texture.width*.5;
            case GHAlignType.CENTER:
                texture.pivotX = 0;
            case GHAlignType.RIGHT:
                texture.pivotX = texture.width*.5;
        }
    }

    override public function dispose():Void {
        node.core.onUpdate.remove(g2d_updateHandler);
        texture.dispose();

        super.dispose();
    }
}
#end