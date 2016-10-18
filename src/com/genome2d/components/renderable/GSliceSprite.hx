package com.genome2d.components.renderable;

import com.genome2d.context.GBlendMode;
import com.genome2d.context.IGContext;
import com.genome2d.input.GMouseInput;
import com.genome2d.geom.GRectangle;
import com.genome2d.geom.GMatrix;
import com.genome2d.context.GCamera;
import com.genome2d.context.filters.GFilter;
import com.genome2d.textures.GTexture;

class GSliceSprite extends GComponent implements IGRenderable {
    
	@prototype 
	public var sliceLeft:Int = 0;
	
    @prototype 
	public var sliceTop:Int = 0;
	
    @prototype 
	public var sliceRight:Int = 0;
	
    @prototype 
	public var sliceBottom:Int = 0;
	
	@prototype
	public var tiled:Bool = false;
	
	/**
        Blend mode used for rendering
    **/
    public var blendMode:Int = 1;

    /**
        Specify alpha treshold for pixel perfect mouse detection, works with mousePixelEnabled true
    **/
    public var mousePixelTreshold:Int = 0;

    /**
        Texture used for rendering
    **/
    public var texture:GTexture;

    /**
        Filter used for rendering
    **/
    public var filter:GFilter;

    public var ignoreMatrix:Bool = true;

    private var g2d_width:Float = 110;
    @prototype 
	public var width(get, set):Float;
    #if swc @:getter(width) #end
    inline private function get_width():Float {
        return g2d_width;
    }
    #if swc @:setter(width) #end
    inline private function set_width(p_value:Float):Float {
        return g2d_width = p_value;
    }

    private var g2d_height:Float = 110;
    @prototype public var height(get, set):Float;
    #if swc @:getter(height) #end
    inline private function get_height():Float {
        return g2d_height;
    }
    #if swc @:setter(height) #end
    inline private function set_height(p_value:Float):Float {
        return g2d_height = p_value;
    }

	/*
    @:dox(hide)
    override public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
        // Calculate rotation
        var sin:Float = 0;
        var cos:Float = 1;
        if (node.g2d_worldRotation != 0) {
            sin = Math.sin(node.g2d_worldRotation);
            cos = Math.cos(node.g2d_worldRotation);
        }

        var ix:Int = Math.ceil(g2d_width/texture1.width);
        var iy:Int = Math.ceil(g2d_height/texture1.height);

        var w:Float = texture1.region.width;
        var h:Float = texture1.region.height;
        var cw:Float = w;
        var ch:Float = h;
        var cx:Float = 0;
        var cy:Float = 0;
        for (j in 0...iy) {
            for (i in 0...ix) {
                if (j==0) {
                    if (i==0) texture = texture1; else if (i==ix-1) texture = texture3; else texture = texture2;
                } else if (j==iy-1) {
                    if (i==0) texture = texture7; else if (i==ix-1) texture = texture9; else texture = texture8;
                } else {
                    if (i==0) texture = texture4; else if (i==ix-1) texture = texture6; else texture = texture5;
                }
                cw = (i==ix-2 && i!=0 && g2d_width%texture.width!=0) ? w*(g2d_width%texture.width)/texture.width : w;
                ch = (j==iy-2 && j!=0 && g2d_height%texture.height!=0) ? h*(g2d_height%texture.height)/texture.height : h;
                node.core.getContext().drawSource(texture,
                                                  texture.region.x, texture.region.y, cw, ch, -cw*.5, -ch*.5,
                                                  //texture.uvX*texture.gpuWidth, texture.uvY*texture.gpuHeight, cw, ch, -cw*.5, -ch*.5,
                                                  node.g2d_worldX+cx*cos-cy*sin, node.g2d_worldY+cy*cos+cx*sin, node.g2d_worldScaleX, node.g2d_worldScaleY, node.g2d_worldRotation,
                                                  node.g2d_worldRed, node.g2d_worldGreen, node.g2d_worldBlue, node.g2d_worldAlpha,
                                                  blendMode, filter);
                cx += cw*node.g2d_worldScaleX;
            }
            cx = 0;
            cy += ch*node.g2d_worldScaleY;
        }
    }
	/**/
	public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
        var rendered:Bool = false;

        if (texture != null) {
            var context:IGContext = node.core.getContext();

            var finalScaleX:Float = g2d_width / texture.width;
            var finalScaleY:Float = g2d_height / texture.height;
			var scaleX:Float = node.g2d_worldScaleX;
			var scaleY:Float = node.g2d_worldScaleY;
			var left:Float = node.g2d_worldX;
			var top:Float = node.g2d_worldY;
			var rotation:Float = node.g2d_worldRotation;
			var red:Float = node.g2d_worldRed;
			var green:Float = node.g2d_worldGreen;
			var blue:Float = node.g2d_worldBlue;
			var green:Float = node.g2d_worldGreen;
			var alpha:Float = node.g2d_worldAlpha;

            var sl:Float = sliceLeft > texture.nativeWidth ? texture.nativeWidth : sliceLeft < 0 ? 0 : sliceLeft;
            var st:Float = sliceTop > texture.nativeHeight ? texture.nativeHeight : sliceTop < 0 ? 0 : sliceTop;
            var sr:Float = sliceRight > texture.nativeWidth ? texture.nativeWidth : sliceRight<sliceLeft ? sliceRight>=0 ? sliceLeft : texture.nativeWidth + sliceRight : sliceRight;
            var sb:Float = sliceBottom > texture.nativeHeight ? texture.nativeHeight : sliceBottom<sliceTop ? sliceBottom>=0 ? sliceTop : texture.nativeHeight + sliceBottom : sliceBottom;
            var sw:Float = sr - sl;
            var sh:Float = sb - st;
			if (sw == 0 && sh != 0) sr = sw = texture.nativeWidth;
			if (sh == 0 && sw != 0) sb = sh = texture.nativeHeight;

            if (sw == 0 || sh == 0) {
				if (tiled) {
					var rx:Float = texture.u * texture.gpuWidth;// (texture.region != null) ? texture.region.x : 0;
					var ry:Float = texture.v * texture.gpuHeight;// (texture.region != null) ? texture.region.y : 0;
					var x:Float = left + (.5 * texture.width + texture.pivotX);
					var y:Float = top + (.5 * texture.height + texture.pivotY);
					finalScaleX /= scaleX;
					finalScaleY /= scaleY;
					for (i in 0...Math.ceil(finalScaleX)) {
						for (j in 0...Math.ceil(finalScaleY)) {
							var sx:Float = (finalScaleX - i > 1) ? 1 : (finalScaleX - i);
							var sy:Float = (finalScaleY - j > 1) ? 1 : (finalScaleY - j);
							var px:Float = (texture.nativeWidth / 2 + texture.pivotX) - sx * scaleX * texture.nativeWidth / 2;
							var py:Float = (texture.nativeHeight / 2 + texture.pivotY) - sy * scaleY * texture.nativeHeight / 2;
							context.drawSource(texture, GBlendMode.NORMAL, rx, ry, sx*texture.nativeWidth, sy*texture.nativeHeight, 0, 0, x+i*texture.width*scaleX-px, y+j*texture.height*scaleY-py, scaleX, scaleY, rotation, red, green, blue, alpha, null);
						}
					}
				} else {
					var x:Float = left + (.5 * texture.width + texture.pivotX) * finalScaleX;
					var y:Float = top + (.5 * texture.height + texture.pivotY) * finalScaleY;
					context.draw(texture, GBlendMode.NORMAL, x, y, finalScaleX, finalScaleY, rotation, red, green, blue, alpha, null);
				}
            } else {
				var rx:Float = texture.u * texture.gpuWidth;// (texture.region != null) ? texture.region.x : 0;
				var ry:Float = texture.v * texture.gpuHeight;// (texture.region != null) ? texture.region.y : 0;
				
                var finalScaleX:Float = (width - texture.width * scaleX) / (sw * texture.scaleFactor) + scaleX;
                var finalScaleY:Float = (height - texture.height * scaleY) / (sh * texture.scaleFactor) + scaleY;
											
                var tx:Float = 0;
                var ty:Float = 0;
                var tw:Float = sl;
                var th:Float = st;
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       left, top, scaleX, scaleY, 0,
                                       red, green, blue, alpha,
                                       null);
                }
				/**/
                tx = sl;
                tw = sw;
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       left+sl*texture.scaleFactor*scaleX, top, finalScaleX, scaleY, 0,
                                       red, green, blue, alpha,
                                       null);
                }
                /**/
                tx = sr;
                tw = texture.width / texture.scaleFactor - sr;
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       left+(sl*scaleX+sw*finalScaleX)*texture.scaleFactor, top, scaleX, scaleY, 0,
                                       red, green, blue, alpha,
                                       null);
                }
				/**/
                tx = 0;
                ty = st;
                tw = sl;
                th = sh;
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       left, top+st*texture.scaleFactor*scaleY, scaleX, finalScaleY, 0,
                                       red, green, blue, alpha,
                                       null);
                }
                /**/
                tx = sl;
                tw = sw;
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       left+sl*texture.scaleFactor*scaleX, top+st*texture.scaleFactor*scaleY, finalScaleX, finalScaleY, 0,
                                       red, green, blue, alpha,
                                       null);
                }
                /**/
                tx = sr;
                tw = texture.width/texture.scaleFactor-sr;

                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       left+(sl*scaleX+sw*finalScaleX)*texture.scaleFactor, top+st*texture.scaleFactor*scaleY, scaleX, finalScaleY, 0,
                                       red, green, blue, alpha,
                                       null);
                }
                /**/
                tx = 0;
                ty = sb;
                tw = sl;
                th = texture.nativeHeight-sb;
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       left, top+(st*scaleY+sh*finalScaleY)*texture.scaleFactor, scaleX, scaleY, 0,
                                       red, green, blue, alpha,
                                       null);
                }
                /**/
                tx = sl;
                tw = sw;
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       left+sl*texture.scaleFactor*scaleX, top+(st*scaleY+sh*finalScaleY)*texture.scaleFactor, finalScaleX, scaleY, 0,
                                       red, green, blue, alpha,
                                       null);
                }
                /**/
                tx = sr;
                tw = texture.width/texture.scaleFactor-sr;
                if (tw != 0 && th != 0) {
                    context.drawSource(texture, GBlendMode.NORMAL, rx+tx, ry+ty, tw, th, -tw*.5, -th*.5,
                                       left+(sl*scaleX+sw*finalScaleX)*texture.scaleFactor, top+(st*scaleY+sh*finalScaleY)*texture.scaleFactor, scaleX, scaleY, 0,
                                       red, green, blue, alpha,
                                       null);
                }
                /**/
            }
        }
    }
	
	    @:dox(hide)
    public function captureMouseInput(p_input:GMouseInput):Void {
		/*
        if (p_captured && p_input.type == GMouseInputType.MOUSE_UP) node.g2d_mouseDownNode = null;

        if (p_captured || texture == null || g2d_width == 0 || g2d_height == 0 || node.g2d_worldScaleX == 0 || node.g2d_worldScaleY == 0) {
            if (node.g2d_mouseOverNode == node) node.dispatchMouseCallback(GMouseInputType.MOUSE_OUT, node, 0, 0, p_input);
            return false;
        }

        // Invert translations
        var tx:Float = p_input.worldX - node.g2d_worldX;
        var ty:Float = p_input.worldY - node.g2d_worldY;

        if (node.g2d_worldRotation != 0) {
            var cos:Float = Math.cos(-node.g2d_worldRotation);
            var sin:Float = Math.sin(-node.g2d_worldRotation);

            var ox:Float = tx;
            tx = (tx*cos - ty*sin);
            ty = (ty*cos + ox*sin);
        }

        tx /= node.g2d_worldScaleX*g2d_width;
        ty /= node.g2d_worldScaleY*g2d_height;

        if (tx >= 0 && tx <= 1 && ty >= 0 && ty <= 1) {
            node.dispatchMouseCallback(p_input.type, node, tx*g2d_width, ty*g2d_height, p_input);
            if (node.g2d_mouseOverNode != node) {
                node.dispatchMouseCallback(GMouseInputType.MOUSE_OVER, node, tx*g2d_width, ty*g2d_height, p_input);
            }

            return true;
        } else {
            if (node.g2d_mouseOverNode == node) {
                node.dispatchMouseCallback(GMouseInputType.MOUSE_OUT, node, tx*g2d_width, ty*g2d_height, p_input);
            }
        }
		/**/
    }

    /**
        Get local bounds
    **/
    public function getBounds(p_bounds:GRectangle = null):GRectangle {
        if (texture == null) {
            if (p_bounds != null) p_bounds.setTo(0, 0, 0, 0);
            else p_bounds = new GRectangle(0, 0, 0, 0);
        } else {
            if (p_bounds != null) p_bounds.setTo(0,0,g2d_width,g2d_height);
            else p_bounds = new GRectangle(0,0,g2d_width,g2d_height);
        }

        return p_bounds;
    }
	
	public function hitTest(p_x:Float, p_y:Float):Bool {
        return false;
    }
}
