package com.genome2d.postprocesses;
#if flash
import com.genome2d.context.GContext;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GContextCamera;
import flash.geom.Matrix3D;
import com.genome2d.textures.GTextureFilteringType;
import com.genome2d.textures.factories.GTextureFactory;
import com.genome2d.node.GNode;
import flash.geom.Rectangle;
import com.genome2d.textures.GTexture;
import com.genome2d.context.filters.GFilter;
class GPostProcess {
    private var g2d_passes:Int = 1;
    public function getPassCount():Int {
        return g2d_passes;
    }

    private var g2d_passFilters:Array<GFilter>;
    private var g2d_passTextures:Array<GTexture>;
    private var g2d_definedBounds:Rectangle;
    private var g2d_activeBounds:Rectangle;

    private var g2d_leftMargin:Int = 0;
    private var g2d_rightMargin:Int = 0;
    private var g2d_topMargin:Int = 0;
    private var g2d_bottomMargin:Int = 0;

    private var g2d_matrix:Matrix3D;

    static private var g2d_count:Int = 0;
    private var g2d_id:String;
    public function new(p_passes:Int = 1, p_filters:Array<GFilter> = null) {
        g2d_id = Std.string(g2d_count++);
        if (p_passes<1) throw "There are no passes";

        g2d_passes = p_passes;
        g2d_matrix = new Matrix3D();

        g2d_passFilters = p_filters;
        g2d_passTextures = new Array<GTexture>();
        for (i in 0...g2d_passes) {
            g2d_passTextures.push(null);
        }
        createPassTextures();
    }

    public function setBounds(p_bounds:Rectangle):Void {
        g2d_definedBounds = p_bounds;
    }

    public function setMargins(p_leftMargin:Int = 0, p_rightMargin:Int = 0, p_topMargin:Int = 0, p_bottomMargin:Int = 0):Void {
        g2d_leftMargin = p_leftMargin;
        g2d_rightMargin = p_rightMargin;
        g2d_topMargin = p_topMargin;
        g2d_bottomMargin = p_bottomMargin;
    }

    public function render(p_parentTransformUpdate:Bool, p_parentColorUpdate:Bool, p_camera:GContextCamera, p_node:GNode, p_bounds:Rectangle = null, p_source:GTexture = null, p_target:GTexture = null):Void {
        var bounds:Rectangle = p_bounds;
        if (bounds == null) bounds = (g2d_definedBounds != null) ? g2d_definedBounds : p_node.getBounds(null, g2d_activeBounds);

        // Invalid bounds
        if (bounds.x >= 4096) return;

        updatePassTextures(bounds);

        var context:GContext = Genome2D.getInstance().getContext();

        if (p_source == null) {
            g2d_matrix.identity();
            g2d_matrix.prependTranslation(-bounds.x+g2d_leftMargin, -bounds.y+g2d_topMargin, 0);
            context.setRenderTarget(g2d_passTextures[0], g2d_matrix);
            p_node.render(true, true, p_camera, false, false);
        }

        var zero:GTexture = g2d_passTextures[0];
        if (p_source != null) g2d_passTextures[0] = p_source;

        for (i in 1...g2d_passes) {
            context.setRenderTarget(g2d_passTextures[i]);
            context.draw(g2d_passTextures[i-1], 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, g2d_passFilters[i-1]);
        }

        context.setRenderTarget(p_target);
        if (p_target == null) {
            context.setCamera(p_camera);
            context.draw(g2d_passTextures[g2d_passes-1], bounds.x-g2d_leftMargin, bounds.y-g2d_topMargin, 1, 1, 0, 1, 1, 1, 1, 1, g2d_passFilters[g2d_passes-1]);
        } else {
            context.draw(g2d_passTextures[g2d_passes-1], 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, g2d_passFilters[g2d_passes-1]);
        }
        g2d_passTextures[0] = zero;
    }

    public function getPassTexture(p_pass:Int):GTexture {
        return g2d_passTextures[p_pass];
    }

    public function getPassFilter(p_pass:Int):GFilter {
        return g2d_passFilters[p_pass];
    }

    private function updatePassTextures(p_bounds:GRectangle):Void {
        var w:Int = Std.int(p_bounds.width + g2d_leftMargin + g2d_rightMargin);
        var h:Int = Std.int(p_bounds.height + g2d_topMargin + g2d_bottomMargin);
        if (g2d_passTextures[0].width != w || g2d_passTextures[0].height != h) {
            var i:Int = g2d_passTextures.length-1;
            while (i>=0) {
                var texture:GTexture = g2d_passTextures[i];
                texture.setRegion(new GRectangle(0, 0, w, h));
                texture.pivotX = -texture.width/2;
                texture.pivotY = -texture.height/2;
                texture.invalidateNativeTexture(true);
                i--;
            }
        }
    }

    private function createPassTextures():Void {
        for (i in 0...g2d_passes) {
            var texture:GTexture = GTextureFactory.createRenderTexture("g2d_pp_"+g2d_id+"_"+i, 2, 2);
            texture.setFilteringType(GTextureFilteringType.NEAREST);
            texture.pivotX = -texture.width/2;
            texture.pivotY = -texture.height/2;
            g2d_passTextures[i] = texture;
        }
    }

    public function dispose():Void {
        var i:Int = g2d_passTextures.length-1;
        while (i>=0) {
            g2d_passTextures[i].dispose();
            i--;
        }
    }
}
#else
import com.genome2d.error.GError;
import com.genome2d.textures.GTexture;
import com.genome2d.geom.GRectangle;
import com.genome2d.node.GNode;
import com.genome2d.context.GContextCamera;

class GPostProcess {
    public function render(p_parentTransformUpdate:Bool, p_parentColorUpdate:Bool, p_camera:GContextCamera, p_node:GNode, p_bounds:GRectangle = null, p_source:GTexture = null, p_target:GTexture = null):Void {
        throw new GError();
    }
}
#end