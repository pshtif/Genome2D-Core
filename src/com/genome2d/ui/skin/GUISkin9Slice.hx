package com.genome2d.ui.skin;
import com.genome2d.textures.GTextureManager;
import com.genome2d.textures.GTexture;
class GUISkin9Slice extends GUISkin {
    public var texture1:GTexture;
    public var texture2:GTexture;
    public var texture3:GTexture;
    public var texture4:GTexture;
    public var texture5:GTexture;
    public var texture6:GTexture;
    public var texture7:GTexture;
    public var texture8:GTexture;
    public var texture9:GTexture;

    override public function getMinWidth():Float {
        return texture1.width+texture2.width+texture3.width;
    }

    override public function getMinHeight():Float {
        return texture1.height+texture4.height+texture7.height;
    }

    public function new(p_id:String, p_skinTextureIds:Array<String>) {
        super(p_id);
        type = GUISkinType.SLICE9;

        texture1 = GTextureManager.getTextureById(p_skinTextureIds[0]);
        texture2 = GTextureManager.getTextureById(p_skinTextureIds[1]);
        texture3 = GTextureManager.getTextureById(p_skinTextureIds[2]);
        texture4 = GTextureManager.getTextureById(p_skinTextureIds[3]);
        texture5 = GTextureManager.getTextureById(p_skinTextureIds[4]);
        texture6 = GTextureManager.getTextureById(p_skinTextureIds[5]);
        texture7 = GTextureManager.getTextureById(p_skinTextureIds[6]);
        texture8 = GTextureManager.getTextureById(p_skinTextureIds[7]);
        texture9 = GTextureManager.getTextureById(p_skinTextureIds[8]);
    }
}
