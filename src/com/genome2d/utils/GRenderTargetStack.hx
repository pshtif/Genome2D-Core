package com.genome2d.utils;
import com.genome2d.context.IGContext;
import com.genome2d.geom.GMatrix3D;
import com.genome2d.textures.GTexture;
class GRenderTargetStack {
    static private var g2d_stack:Array<GTexture>;
    static private var g2d_transforms:Array<GMatrix3D>;

    static public function pushRenderTarget(p_target:GTexture, p_transform:GMatrix3D):Void {
        if (g2d_stack == null) {
            g2d_stack = new Array<GTexture>();
            g2d_transforms = new Array<GMatrix3D>();
        }
        g2d_stack.push(p_target);
        g2d_transforms.push(p_transform);
    }

    static public function popRenderTarget(p_context:IGContext):Void {
        if (g2d_stack == null) return null;
        p_context.setRenderTarget(g2d_stack.pop(), g2d_transforms.pop(), false);
    }
}
