package com.genome2d.components.renderables;
import com.genome2d.error.GError;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GBlendMode;
import com.genome2d.context.GContextCamera;
import com.genome2d.node.GNode;
import com.genome2d.textures.GTexture;

/**
 * ...
 * @author 
 */
class GShape extends GComponent implements IRenderable
{
    public var texture:GTexture;
    public var blendMode:Int = GBlendMode.NORMAL;

    private var g2d_vertices:Array<Float>;
    private var g2d_uvs:Array<Float>;

    //private var g2d_contextPoly:GContextPolygon;

    public function new(p_node:GNode) {
        super(p_node);
    }

    public function render(p_camera:GContextCamera, p_useMatrix:Bool):Void {
        if (texture == null || g2d_vertices == null || g2d_uvs == null) return;
        var transform:GTransform = node.transform;
        node.core.getContext().drawPoly(texture, g2d_vertices, g2d_uvs, transform.g2d_worldX, transform.g2d_worldY, transform.g2d_worldScaleX, transform.g2d_worldScaleY, transform.g2d_worldRotation, transform.g2d_worldRed, transform.g2d_worldGreen, transform.g2d_worldBlue, transform.g2d_worldAlpha, blendMode);
    }

    public function init(p_vertices:Array<Float>, p_uvs:Array<Float>):Void {
        if (p_vertices == null || p_uvs == null) new GError("Vertices and UVs can't be null.");
        if (p_vertices.length == 0) new GError("Shape can't have 0 vertices.");
        if (p_vertices.length != p_uvs.length) new GError("Vertices and UVs need to have same amount of values.");
        g2d_vertices = p_vertices;
        g2d_uvs = p_uvs;
    }

    public function getBounds(p_target:GRectangle = null):GRectangle {
        return null;
    }
}