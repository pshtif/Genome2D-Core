package com.genome2d.ui.controls;
import com.genome2d.ui.utils.GUIPositionType;
import com.genome2d.ui.utils.GUILayoutType;
import com.genome2d.textures.GContextTexture;
import com.genome2d.signals.GMouseSignal;
import com.genome2d.signals.GMouseSignalType;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GCamera;
import com.genome2d.context.IContext;
import com.genome2d.ui.skin.GUISkin;
import com.genome2d.geom.GPoint;
import flash.Vector;

@prototypeName("container")
class GUIContainer extends GUIControl {
    private var g2d_children:Array<GUIControl>;
    private var g2d_childCount:Int = 0;

    public var useMasking:Bool = false;

    public function new(p_style:GUIStyle = null) {
        super(p_style);
        g2d_children = new Array<GUIControl>();
        g2d_afterPositions = new Array<GUIControl>();
    }

    private var g2d_afterPositions:Array<GUIControl>;
    @:access(com.genome2d.ui.GUIStyle)
    override public function invalidate():Void {
        if (g2d_dirty || g2d_style.g2d_usePercentageHeight || g2d_style.g2d_usePercentageWidth) {
            trace(name, "invalidate");
            var contentFlowX:Float = 0;
            var contentFlowY:Float = 0;
            var maxSize:Float = 0;

            if (g2d_parent != null && g2d_style.g2d_usePercentageWidth || g2d_style.g2d_usePercentageHeight) {
                g2d_width = g2d_style.g2d_usePercentageWidth ? g2d_style.g2d_maxWidth * (g2d_parent.width-g2d_style.marginLeft-g2d_style.marginRight) / 100 : g2d_style.g2d_maxWidth;
                g2d_height = g2d_style.g2d_usePercentageHeight ? g2d_style.g2d_maxHeight * (g2d_parent.height-g2d_style.marginTop-g2d_style.marginBottom) / 100 : g2d_style.g2d_maxHeight;
            } else {
                g2d_width = (g2d_style.g2d_maxWidth>0) ? g2d_style.g2d_maxWidth : 0;
                g2d_height = (g2d_style.g2d_maxHeight>0) ? g2d_style.g2d_maxHeight : 0;
            }

            var childCount:Int = g2d_children.length;
            for (i in 0...childCount) {
                var child:GUIControl = g2d_children[i];
                child.invalidate();

                if (child.position == GUIPositionType.RELATIVE) {
                    if (g2d_style.g2d_layout == GUILayoutType.HORIZONTAL) {
                        if (g2d_width != 0 && (
                            (contentFlowX != 0 && child.g2d_style.g2d_autoMargin) ||
                            (contentFlowX + child.flowWidth > g2d_width)
                        )) {
                            contentFlowX = 0;
                            contentFlowY += maxSize;
                            maxSize = 0;
                        }
                    } else {
                        if (g2d_height != 0 && (
                                                (contentFlowY != 0 && child.g2d_style.g2d_autoMargin) ||
                                                (contentFlowY + child.flowHeight > g2d_height)
                        )) {
                            contentFlowX += maxSize;
                            contentFlowY = 0;
                            maxSize = 0;
                        }
                    }

                    child.g2d_flowX = (child.g2d_style.g2d_useLeft) ? contentFlowX + child.g2d_style.left : contentFlowX - child.g2d_style.right;
                    child.g2d_flowY = (child.g2d_style.g2d_useTop) ? contentFlowY + child.g2d_style.top : contentFlowY - child.g2d_style.bottom;
                    if (g2d_style.g2d_layout == GUILayoutType.HORIZONTAL) {
                        contentFlowX += child.flowWidth;
                        trace(child.name,child.g2d_width);
                        if (maxSize < child.flowHeight) maxSize = child.flowHeight;
                    } else {
                        contentFlowY += child.flowHeight;
                        if (maxSize < child.flowWidth) maxSize = child.flowWidth;
                    }
                } else {
                    if (child.g2d_style.g2d_useTop && child.g2d_style.g2d_useLeft && !child.g2d_style.g2d_usePercentageHorizontal && !child.g2d_style.g2d_usePercentageVertical) {
                        child.g2d_flowX = child.g2d_style.left;
                        child.g2d_flowY = child.g2d_style.top;
                    } else {
                        g2d_afterPositions.push(child);
                    }
                }
            }

            if (g2d_style.g2d_minWidth == 0) {
                if (g2d_width == 0) width = (g2d_style.g2d_layout == GUILayoutType.HORIZONTAL) ? contentFlowX : contentFlowX + maxSize;
            } else {
                g2d_width = g2d_style.g2d_minWidth;
            }
            if (g2d_style.g2d_minHeight == 0) {
                if (g2d_height == 0) height = (g2d_style.g2d_layout == GUILayoutType.HORIZONTAL) ? contentFlowY+maxSize : contentFlowY;
            } else {
                g2d_height = g2d_style.g2d_minHeight;
            }

            if (g2d_activeSkin != null) {
                g2d_width = (g2d_width<g2d_activeSkin.getMinWidth()) ? g2d_activeSkin.getMinWidth() : g2d_width;
                g2d_height = (g2d_height<g2d_activeSkin.getMinHeight()) ? g2d_activeSkin.getMinHeight() : g2d_height;
            }

            var child:GUIControl = null;
            while (g2d_afterPositions.length>0) {
                child = g2d_afterPositions.shift();
                if (child.g2d_style.g2d_usePercentageHorizontal) {
                    child.g2d_flowX = (child.g2d_style.g2d_useLeft) ? child.g2d_style.left*g2d_width/100 : g2d_width - child.flowWidth - (child.g2d_style.right*g2d_width/100);
                } else {
                    child.g2d_flowX = (child.g2d_style.g2d_useLeft) ? child.g2d_style.left : g2d_width - child.flowWidth - child.g2d_style.right;
                }
                if (child.g2d_style.g2d_usePercentageVertical) {
                    child.g2d_flowY = (child.g2d_style.g2d_useTop) ? child.g2d_style.top*g2d_height/100 : g2d_height - child.flowHeight - (child.g2d_style.bottom*g2d_height/100);
                } else {
                    child.g2d_flowY = (child.g2d_style.g2d_useTop) ? child.g2d_style.top : g2d_height - child.flowHeight - child.g2d_style.bottom;
                }
            }

            if (child != null && child.g2d_style.g2d_autoMargin) {
                if (g2d_style.g2d_layout == GUILayoutType.HORIZONTAL  && g2d_width != 0) {
                    child.g2d_style.marginRight = child.g2d_style.marginLeft = (g2d_width - child.g2d_width) / 2;
                } else if (g2d_style.g2d_layout == GUILayoutType.VERTICAL && g2d_height != 0) {
                    child.g2d_style.marginTop = child.g2d_style.marginBottom = (g2d_height - child.g2d_height) / 2;
                }
            }

            g2d_dirty = false;

            trace(name, "invalidateEnd", g2d_width);
        }
    }

    override public function render(p_x:Float, p_y:Float):Bool {
        var immediateRender:Bool = super.render(p_x, p_y);

        if (immediateRender) {
            if (isDirty()) invalidate();
            if (g2d_width < 0 || g2d_height < 0) return true;

            var context:IContext = Genome2D.getInstance().getContext();
            var previousMaskRect:GRectangle = null;

            if (useMasking) {
                var camera:GCamera = context.getActiveCamera();
                var view:GRectangle = context.getStageViewRect();
                var tx:Float = x * camera.scaleX - camera.x * camera.scaleX - view.width / 2;
                var ty:Float = y * camera.scaleY - camera.y * camera.scaleY - view.height / 2;
                var maskRect:GRectangle = new GRectangle(tx, ty, g2d_width * camera.scaleX, g2d_height * camera.scaleY);
                previousMaskRect = (context.getMaskRect() == null) ? null : context.getMaskRect().clone();
                if (previousMaskRect != null) {
                    var intersection:GRectangle = previousMaskRect.intersection(maskRect);
                    if (intersection.width <= 0 || intersection.height <= 0) return true;
                    context.setMaskRect(intersection);
                } else {
                    context.setMaskRect(maskRect);
                }
            }

            if (g2d_activeSkin != null) g2d_activeSkin.render(x, y, g2d_width, g2d_height);

            for (i in 0...g2d_childCount) {
                var child:GUIControl = g2d_children[i];
                if (child.visible) child.render(x, y);
            }

            if (useMasking) Genome2D.getInstance().getContext().setMaskRect(previousMaskRect);
        }
        return immediateRender;
    }

    public function addChild(p_uiControl:GUIControl):Void {
        if (p_uiControl.g2d_parent == this) return;
        p_uiControl.g2d_parent = this;
        g2d_children.push(p_uiControl);
        g2d_childCount++;
        setDirty();
    }

    override public function processMouseSignal(p_captured:Bool, p_x:Float, p_y:Float, p_contextSignal:GMouseSignal):Bool {
        if (!visible) return p_captured;
        g2d_mouseOver = p_x>=x && p_x<=x+g2d_width && p_y>=y && p_y<=y+g2d_height;

        if (!p_captured && mouseEnabled && g2d_mouseOver && p_contextSignal.type == GMouseSignalType.MOUSE_UP) onMouseUp.dispatch(this, p_contextSignal);
        if (!p_captured && mouseEnabled && g2d_mouseOver && p_contextSignal.type == GMouseSignalType.MOUSE_DOWN) onMouseDown.dispatch(this, p_contextSignal);

        var i:Int = g2d_childCount;
        while (i>=0) {
            i--;
            p_captured = g2d_children[i].processMouseSignal(p_captured, p_x, p_y, p_contextSignal) || p_captured;
        }

        return p_captured || (g2d_mouseOver && mouseEnabled);
    }
}
