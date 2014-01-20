package com.genome2d.components.renderables;

import com.genome2d.geom.GFloatRectangle;
import com.genome2d.node.GNode;
import com.genome2d.node.factory.GNodeFactory;
import com.genome2d.signals.GMouseSignal;
import com.genome2d.textures.GTexture;
import com.genome2d.textures.GTextureAtlas;
import com.genome2d.context.GContextCamera;

/**
 * ...
 * @author 
 */
class GTextureText extends GComponent implements IRenderable
{
    public var blendMode:Int = 1;
		
	private var g2d_invalidate:Bool = false;
	
	private var g2d_tracking:Float = 0;
    #if swc @:extern #end
	public var tracking(get, set):Float;
    #if swc @:getter(tracking) #end
	inline private function get_tracking():Float {
		return g2d_tracking;
	}
    #if swc @:setter(tracking) #end
	inline private function set_tracking(p_tracking:Float):Float {
		g2d_tracking = p_tracking;
		g2d_invalidate = true;
		return g2d_tracking;
	}
	
	private var g2d_lineSpace:Float = 0;
    #if swc @:extern #end
	public var lineSpace(get, set):Float;
    #if swc @:getter(lineSpace) #end
	inline private function get_lineSpace():Float {
		return g2d_lineSpace;
	}
    #if swc @:setter(lineSpace) #end
	inline private function set_lineSpace(p_value:Float):Float {
		g2d_lineSpace = p_value;
		g2d_invalidate = true;
		return g2d_lineSpace;
	}
	
	private var g2d_align:Int;
    #if swc @:extern #end
	public var align(get,set):Int;
    #if swc @:getter(align) #end
	inline private function get_align():Int {
		return g2d_align;
	}
    #if swc @:setter(align) #end
	inline private function set_align(p_align:Int):Int {
		g2d_align = p_align;
		g2d_invalidate = true;
		return g2d_align;
	}
	
	public var maxWidth:Float = 0;
	
	/**
	 * 	@private
	 */
	public function new(p_node:GNode) {
		super(p_node);

        g2d_align = GTextureTextAlignType.TOP_LEFT;
	}

    private var g2d_textureAtlas:GTextureAtlas;
    #if swc @:extern #end
	public var textureAtlasId(get, set):String;
    #if swc @:getter(textureAtlasId) #end
	inline private function get_textureAtlasId():String {
		if (g2d_textureAtlas != null) return g2d_textureAtlas.getId();
		return "";
	}
    #if swc @:setter(textureAtlasId) #end
	inline private function set_textureAtlasId(p_value:String):String {
		setTextureAtlas(GTextureAtlas.getTextureAtlasById(p_value));
		return p_value;
	}
	
	public function setTextureAtlas(p_textureAtlas:GTextureAtlas):Void {
		g2d_textureAtlas = p_textureAtlas;
		g2d_invalidate = true;
	}
	
	private var g2d_text:String = "";
    #if swc @:extern #end
	public var text(get, set):String;
    #if swc @:getter(text) #end
	inline private function get_text():String {
		return g2d_text;
	}
    #if swc @:setter(text) #end
	inline private function set_text(p_text:String):String {
		g2d_text = p_text;
		g2d_invalidate = true;
		return g2d_text;
	}
	
	private var g2d_width:Float = 0;
    #if swc @:extern #end
	public var width(get, never):Float;
    #if swc @:getter(width) #end
	inline private function get_width():Float {
		if (g2d_invalidate) invalidateText();
		
		return g2d_width*node.transform.g2d_worldScaleX;
	}
	
	private var g2d_height:Float = 0;
    #if swc @:extern #end
	public var height(get, never):Float;
    #if swc @:getter(height) #end
	public function get_height():Float {		
		if (g2d_invalidate) invalidateText();
		
		return g2d_height * node.transform.g2d_worldScaleY;
	}
		
	public function render(p_camera:GContextCamera, p_useMatrix:Bool):Void {
		if (g2d_invalidate) invalidateText();
	}
		
	private function invalidateText():Void {
		if (g2d_textureAtlas == null) return;
		
		g2d_width = 0;
		var offsetX:Float = 0;
		var offsetY:Float =  0;
		var charSprite:GSprite;
		var texture:GTexture = null;
		
		for (i in 0...g2d_text.length) {
			if (g2d_text.charCodeAt(i) == 10) {
				g2d_width = (offsetX>g2d_width) ? offsetX : g2d_width;
				offsetX = 0;
				offsetY += (texture != null ? texture.height + g2d_lineSpace : g2d_lineSpace);
				continue;
            }
			texture = g2d_textureAtlas.getSubTexture(Std.string(g2d_text.charCodeAt(i)));
			if (texture == null) continue;//throw new GError("Texture for character "+g2d_text.charAt(i)+" with code "+g2d_text.charCodeAt(i)+" not found!");
			if (i>=node.numChildren) {
				charSprite = cast GNodeFactory.createNodeWithComponent(GSprite);
				node.addChild(charSprite.node);
			} else {
				charSprite = cast node.getChildAt(i).getComponent(GSprite);
			}

			charSprite.texture = texture;
			if (maxWidth>0 && offsetX + texture.width>maxWidth) {
				g2d_width = (offsetX>g2d_width) ? offsetX : g2d_width;
				offsetX = 0;
				offsetY+=texture.height+g2d_lineSpace;
			}
			offsetX += texture.width / 2;
			charSprite.node.transform.visible = true;
			charSprite.node.transform.x = offsetX;
			charSprite.node.transform.y = offsetY+texture.height/2;
			offsetX += texture.width/2 + g2d_tracking;
		}
		
		g2d_width = (offsetX>g2d_width) ? offsetX : g2d_width;
		g2d_height = offsetY + (texture!=null ? texture.height : 0);
		for (i in g2d_text.length...node.numChildren) {
			node.getChildAt(i).transform.visible = false;
		}
		/**/
		invalidateAlign();
		
		g2d_invalidate = false;
	}
	
	private function invalidateAlign():Void {
		switch (g2d_align) {
			case GTextureTextAlignType.MIDDLE:
				for (i in 0...node.numChildren) {
					var child:GNode = node.getChildAt(i);
					child.transform.x -= g2d_width/2;
					child.transform.y -= g2d_height/2;
				}
			case GTextureTextAlignType.TOP_RIGHT:
				for (i in 0...node.numChildren) {
					node.getChildAt(i).transform.x -= g2d_width;
				}
		}
	}
	
	/**
	 * 	@private
	 */
    override public function processContextMouseSignal(p_captured:Bool, p_cameraX:Float, p_cameraY:Float, p_contextSignal:GMouseSignal):Bool {
		/*
		if (g2d_width == 0 || g2d_height == 0) return false;
		if (p_captured) {
			if (node.cMouseOver == node) node.handleMouseEvent(node, MouseEvent.MOUSE_OUT, Float.NaN, Float.NaN, p_event.buttonDown, p_event.ctrlKey);
			return false;
		}
		
		var transformMatrix:Matrix3D = node.cTransform.getTransformedWorldTransformMatrix(g2d_width, g2d_height, 0, true);
		
		var localMousePosition:Vector3D = transformMatrix.transformVector(p_position);
		
		transformMatrix.prependScale(1/g2d_width, 1/g2d_height, 1);
		
		var tx:Float = 0;
		var ty:Float = 0;
		switch (g2d_align) {
			case GTextureTextAlignType.MIDDLE:
				tx = -.5;
				ty = -.5;
				break;
		}
		
		if (localMousePosition.x >= tx && localMousePosition.x <= 1+tx && localMousePosition.y >= ty && localMousePosition.y <= 1+ty) {
			node.handleMouseEvent(node, p_event.type, localMousePosition.x*g2d_width, localMousePosition.y*g2d_height, p_event.buttonDown, p_event.ctrlKey);
			if (node.cMouseOver != node) {
				node.handleMouseEvent(node, MouseEvent.MOUSE_OVER, localMousePosition.x*g2d_width, localMousePosition.y*g2d_height, p_event.buttonDown, p_event.ctrlKey);
			}
			
			return true;
		} else {
			if (node.cMouseOver == node) {
				node.handleMouseEvent(node, MouseEvent.MOUSE_OUT, localMousePosition.x*g2d_width, localMousePosition.y*g2d_height, p_event.buttonDown, p_event.ctrlKey);
			}
		}
		/**/
		return false;
	}

    public function getBounds(p_target:GFloatRectangle = null):GFloatRectangle {
        // TODO
        return null;
    }
}