/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components;

import com.genome2d.geom.GPoint;
import com.genome2d.geom.GMatrix;
import com.genome2d.node.GNode;

/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
class GTransform extends GComponent
{
    static private var g2d_cachedMatrix:GMatrix;

	@prototype public var useWorldSpace:Bool = false;
	@prototype public var useWorldColor:Bool = false;

    private var g2d_matrixDirty:Bool = true;
	private var g2d_transformDirty:Bool = false;
	private var g2d_colorDirty:Bool = false;
	
	public var visible:Bool = true;

    @:dox(hide)
	public var g2d_worldX:Float = 0;
	private var g2d_localX:Float = 0;
	#if swc @:extern #end
	@prototype public var x(get, set):Float;
	#if swc @:getter(x) #end
	inline private function get_x():Float {
		return g2d_localX;
	}
	#if swc @:setter(x) #end
	inline private function set_x(p_value:Float):Float {
		g2d_transformDirty = g2d_matrixDirty = true;
		return g2d_localX = g2d_worldX = p_value;
	}

    @:dox(hide)
	public var g2d_worldY:Float = 0;
	private var g2d_localY:Float = 0;
	#if swc @:extern #end
	@prototype public var y(get, set):Float;
	#if swc @:getter(y) #end
	inline private function get_y():Float {
		return g2d_localY;
	}
	#if swc @:setter(y) #end
	inline private function set_y(p_value:Float):Float {
		g2d_transformDirty = g2d_matrixDirty = true;
		return g2d_localY = g2d_worldY = p_value;
	}

    inline public function hasUniformRotation():Bool {
        return (g2d_localScaleX != g2d_localScaleY && g2d_localRotation != 0);
    }
    private var g2d_localUseMatrix:Int = 0;

    private var g2d_useMatrix(get, set):Int;
    inline private function get_g2d_useMatrix():Int {
        return g2d_localUseMatrix;
    }
    inline private function set_g2d_useMatrix(p_value:Int):Int {
        if (node.parent != null) node.parent.transform.g2d_useMatrix += p_value-g2d_useMatrix;
        g2d_localUseMatrix = p_value;
        return g2d_useMatrix;
    }

    @:dox(hide)
	public var g2d_worldScaleX:Float = 1;
	private var g2d_localScaleX:Float = 1;
	#if swc @:extern #end
	@prototype public var scaleX(get, set):Float;
	#if swc @:getter(scaleX) #end
	inline private function get_scaleX():Float {
		return g2d_localScaleX;
	}
	#if swc @:setter(scaleX) #end
	inline private function set_scaleX(p_value:Float):Float {
        if (g2d_localScaleX == g2d_localScaleY && p_value != g2d_localScaleY && g2d_localRotation != 0 && node.numChildren>0) g2d_useMatrix++;
        if (g2d_localScaleX == g2d_localScaleY && p_value == g2d_localScaleY && g2d_localRotation != 0 && node.numChildren>0) g2d_useMatrix--;

		g2d_transformDirty = g2d_matrixDirty = true;
		return g2d_localScaleX = g2d_worldScaleX = p_value;
	}

    @:dox(hide)
	public var g2d_worldScaleY:Float = 1;
	private var g2d_localScaleY:Float = 1;
	#if swc @:extern #end
	@prototype public var scaleY(get, set):Float;
	#if swc @:getter(scaleY) #end
	inline private function get_scaleY():Float {
		return g2d_localScaleY;
	}
	#if swc @:setter(scaleY) #end
	inline private function set_scaleY(p_value:Float):Float {
        if (g2d_localScaleX == g2d_localScaleY && p_value != g2d_localScaleX && g2d_localRotation != 0 && node.numChildren>0) g2d_useMatrix++;
        if (g2d_localScaleX == g2d_localScaleY && p_value == g2d_localScaleX && g2d_localRotation != 0 && node.numChildren>0) g2d_useMatrix--;

		g2d_transformDirty = g2d_matrixDirty = true;
		return g2d_localScaleY = g2d_worldScaleY = p_value;
	}

    @:dox(hide)
	public var g2d_worldRotation:Float = 0;
	private var g2d_localRotation:Float = 0;
	#if swc @:extern #end
	@prototype public var rotation(get, set):Float;
	#if swc @:getter(rotation) #end
	inline private function get_rotation():Float {
		return g2d_localRotation;
	}
	#if swc @:setter(rotation) #end
	inline private function set_rotation(p_value:Float):Float {
        if (g2d_localRotation == 0 && p_value != 0 && g2d_localScaleX != g2d_localScaleY && node.numChildren>0) g2d_useMatrix++;
        if (g2d_localRotation != 0 && p_value == 0 && g2d_localScaleX != g2d_localScaleY && node.numChildren>0) g2d_useMatrix--;

		g2d_transformDirty = g2d_matrixDirty = true;
		return g2d_localRotation = g2d_worldRotation = p_value;
	}

    @:dox(hide)
	public var g2d_worldRed:Float = 1;
	private var g2d_localRed:Float = 1;
	#if swc @:extern #end
	public var red(get, set):Float;
	#if swc @:getter(red) #end
	inline private function get_red():Float {
		return g2d_localRed;
	}
	#if swc @:setter(red) #end
	inline private function set_red(p_value:Float):Float {
		g2d_colorDirty = true;
		return g2d_localRed = g2d_worldRed = p_value;
	}

    @:dox(hide)
	public var g2d_worldGreen:Float = 1;
	private var g2d_localGreen:Float = 1;
	#if swc @:extern #end
	public var green(get, set):Float;
	#if swc @:getter(green) #end
	inline private function get_green():Float {
		return g2d_localGreen;
	}
	#if swc @:setter(green) #end
	inline private function set_green(p_value:Float):Float {
		g2d_colorDirty = true;
		return g2d_localGreen = g2d_worldGreen = p_value;
	}

    @:dox(hide)
	public var g2d_worldBlue:Float = 1;
	private var g2d_localBlue:Float = 1;
	#if swc @:extern #end
	public var blue(get, set):Float;
	#if swc @:getter(blue) #end
	inline private function get_blue():Float {
		return g2d_localBlue;
	}
	#if swc @:setter(blue) #end
	inline private function set_blue(p_value:Float):Float {
		g2d_colorDirty = true;
		return g2d_localBlue = g2d_worldBlue = p_value;
	}

    @:dox(hide)
	public var g2d_worldAlpha:Float = 1;
	private var g2d_localAlpha:Float = 1;
	#if swc @:extern #end
	@prototype public var alpha(get, set):Float;
	#if swc @:getter(alpha) #end
	inline private function get_alpha():Float {
		return g2d_localAlpha;
	}
	#if swc @:setter(alpha) #end
	inline private function set_alpha(p_value:Float):Float {
		g2d_colorDirty = true;
		return g2d_localAlpha = g2d_worldAlpha = p_value;
	}

    #if swc @:extern #end
	public var color(never, set):Int;
    #if swc @:setter(color) #end
	inline private function set_color(p_value:Int):Int {
		red = (p_value >> 16 & 0xFF) / 0xFF;
		green = (p_value >> 8 & 0xFF) / 0xFF;
		blue = (p_value & 0xFF) / 0xFF;
		return p_value;
	}

    private var g2d_matrix:GMatrix;
    #if swc @:extern #end
    public var matrix(get, never):GMatrix;
    #if swc @:getter(matrix) #end
    inline private function get_matrix():GMatrix {
        if (g2d_matrixDirty) {
            if (g2d_matrix == null) g2d_matrix = new GMatrix();
            if (g2d_localRotation == 0.0) {
                g2d_matrix.setTo(g2d_localScaleX, 0.0, 0.0, g2d_localScaleY, g2d_localX, g2d_localY);
            } else {
                var cos:Float = Math.cos(g2d_localRotation);
                var sin:Float = Math.sin(g2d_localRotation);
                var a:Float = g2d_localScaleX * cos;
                var b:Float = g2d_localScaleX * sin;
                var c:Float = g2d_localScaleY * -sin;
                var d:Float = g2d_localScaleY * cos;
                var tx:Float = g2d_localX;
                var ty:Float = g2d_localY;

                g2d_matrix.setTo(a, b, c, d, tx, ty);
            }

            g2d_matrixDirty = false;
        }

        return g2d_matrix;
    }

    public function getTransformationMatrix(p_targetSpace:GNode, p_resultMatrix:GMatrix = null):GMatrix {
        if (p_resultMatrix == null) {
            p_resultMatrix = new GMatrix();
        } else {
            p_resultMatrix.identity();
        }

        if (p_targetSpace == node.parent) {
            p_resultMatrix.copyFrom(matrix);
        } else if (p_targetSpace != node) {
            var common:GNode = node.getCommonParent(p_targetSpace);
            if (common != null) {
                var current:GNode = node;
                while (common != current) {
                    p_resultMatrix.concat(current.transform.matrix);
                    current = current.parent;
                }
                // If its not in parent hierarchy we need to continue down the target
                if (common != p_targetSpace) {
                    g2d_cachedMatrix.identity();
                    while (p_targetSpace != common) {
                        g2d_cachedMatrix.concat(p_targetSpace.transform.matrix);
                        p_targetSpace = p_targetSpace.parent;
                    }
                    g2d_cachedMatrix.invert();
                    p_resultMatrix.concat(g2d_cachedMatrix);
                }
            }
        }

        return p_resultMatrix;
    }

    public function localToGlobal(p_local:GPoint, p_result:GPoint = null):GPoint {
        getTransformationMatrix(node.core.root, g2d_cachedMatrix);
        if (p_result == null) p_result = new GPoint();
        p_result.x = g2d_cachedMatrix.a * p_local.x + g2d_cachedMatrix.c * p_local.y + g2d_cachedMatrix.tx;
        p_result.y = g2d_cachedMatrix.d * p_local.y + g2d_cachedMatrix.b * p_local.x + g2d_cachedMatrix.ty;
        return p_result;
    }

    public function globalToLocal(p_global:GPoint, p_result:GPoint = null):GPoint {
        getTransformationMatrix(node.core.root, g2d_cachedMatrix);
        g2d_cachedMatrix.invert();
        if (p_result == null) p_result = new GPoint();
        p_result.x = g2d_cachedMatrix.a * p_global.x + g2d_cachedMatrix.c * p_global.y + g2d_cachedMatrix.tx;
        p_result.y = g2d_cachedMatrix.d * p_global.y + g2d_cachedMatrix.b * p_global.x + g2d_cachedMatrix.ty;
        return p_result;
    }

    @:dox(hide)
	override public function init():Void {
        if (g2d_cachedMatrix == null) g2d_cachedMatrix = new GMatrix();
	}
	
	public function setPosition(p_x:Float, p_y:Float):Void {
		g2d_transformDirty = g2d_matrixDirty = true;
		g2d_localX = g2d_worldX = p_x;
		g2d_localY = g2d_worldY = p_y;
	}

	public function setScale(p_scaleX:Float, p_scaleY:Float):Void {
		g2d_transformDirty = g2d_matrixDirty = true;
		g2d_localScaleX = g2d_worldScaleX = p_scaleX;
		g2d_localScaleY = g2d_worldScaleY = p_scaleY;
	}
	
	inline public function invalidate(p_invalidateTransform:Bool, p_invalidateColor:Bool):Void {
        var parentTransform:GTransform = node.parent.transform;

        if (p_invalidateTransform && !useWorldSpace) {
            if (parentTransform.g2d_worldRotation != 0) {
                var cos:Float = Math.cos(parentTransform.g2d_worldRotation);
                var sin:Float = Math.sin(parentTransform.g2d_worldRotation);

                g2d_worldX = (x * cos - y * sin) * parentTransform.g2d_worldScaleX + parentTransform.g2d_worldX;
                g2d_worldY = (y * cos + x * sin) * parentTransform.g2d_worldScaleY + parentTransform.g2d_worldY;
            } else {
                g2d_worldX = g2d_localX * parentTransform.g2d_worldScaleX + parentTransform.g2d_worldX;
                g2d_worldY = g2d_localY * parentTransform.g2d_worldScaleY + parentTransform.g2d_worldY;
            }

            g2d_worldScaleX = g2d_localScaleX * parentTransform.g2d_worldScaleX;
            g2d_worldScaleY = g2d_localScaleY * parentTransform.g2d_worldScaleY;
            g2d_worldRotation = g2d_localRotation + parentTransform.g2d_worldRotation;

            g2d_transformDirty = false;
        }

        if (p_invalidateColor && !useWorldColor) {
            g2d_worldRed = g2d_localRed * parentTransform.g2d_worldRed;
            g2d_worldGreen = g2d_localGreen * parentTransform.g2d_worldGreen;
            g2d_worldBlue = g2d_localBlue * parentTransform.g2d_worldBlue;
            g2d_worldAlpha = g2d_localAlpha * parentTransform.g2d_worldAlpha;

            g2d_colorDirty = false;
        }
	}
}