package com.genome2d.fbx;
import com.genome2d.context.stage3d.GStage3DContext;
import com.genome2d.context.GBlendMode;
import com.genome2d.Genome2D;
import com.genome2d.geom.GMatrix3D;
import com.genome2d.textures.GTextureManager;
import com.genome2d.textures.GTexture;
import com.genome2d.context.stage3d.renderers.GCustomRenderer;
class GFbxRenderer {
    public var renderer:GCustomRenderer;
    public var texture:GTexture;

    private var g2d_scene:GFbxScene;

    public function new(p_scene:GFbxScene, p_model:GFbxModel):Void {
        g2d_scene = p_scene;

        var fbxGeometry:GFbxGeometry = p_model.getGeometry();
        if (fbxGeometry == null) throw "Invalid model.";

        renderer = new GCustomRenderer(fbxGeometry.vertices, fbxGeometry.uvs, fbxGeometry.indices, fbxGeometry.vertexNormals, false);

        var fbxTexture:GFbxTexture = p_model.getMaterial().getTexture();
        if (fbxTexture == null) throw "Invalid texture.";

        texture = GTextureManager.getTextureById(fbxTexture.relativePath);
    }

    public function render(p_cameraMatrix:GMatrix3D, p_modelMatrix:GMatrix3D, p_cull:Int, p_renderType:Int):Void {
        var context:GStage3DContext = cast Genome2D.getInstance().getContext();
        context.setBlendMode(GBlendMode.NORMAL, true);
        context.bindRenderer(renderer);

        renderer.lightPos = g2d_scene.lightDirection;
        renderer.ambientColor = g2d_scene.ambientColor;
        renderer.tintColor = g2d_scene.tintColor;
        renderer.modelMatrix = p_modelMatrix;
        renderer.cameraMatrix = p_cameraMatrix;

        renderer.draw(texture, p_cull, p_renderType);
    }
}
