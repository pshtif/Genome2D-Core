/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2015 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.ui.element;

import com.genome2d.callbacks.GCallback;
import com.genome2d.context.GCamera;
import com.genome2d.context.IGContext;
import com.genome2d.input.GFocusManager;
import com.genome2d.Genome2D;
import com.genome2d.geom.GRectangle;
import com.genome2d.input.GKeyboardInput;
import com.genome2d.input.IGInteractive;
import com.genome2d.node.GNode;
import com.genome2d.proto.GPrototype;
import com.genome2d.proto.GPrototypeExtras;
import com.genome2d.textures.GTextureManager;
import com.genome2d.ui.layout.GUIHorizontalLayout;
import com.genome2d.ui.layout.GUILayoutType;
import com.genome2d.ui.layout.GUIVerticalLayout;
import com.genome2d.ui.skin.GUISkinManager;
import com.genome2d.ui.layout.GUILayout;
import Xml.XmlType;
import com.genome2d.input.GMouseInputType;
import com.genome2d.input.GMouseInput;
import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.ui.skin.GUISkin;

@:access(com.genome2d.ui.layout.GUILayout)
@:access(com.genome2d.ui.skin.GUISkin)
@prototypeName("element")
@prototypeDefaultChildGroup("element")
class GUIElement implements IGPrototypable implements IGInteractive {
	public var red:Float = 1;
	public var green:Float = 1;
	public var blue:Float = 1;
	@prototype
	public var alpha:Float = 1;
	
	static public var setModelHook:Dynamic->Dynamic;
	
	#if swc @:extern #end
    @prototype
	public var color(get, set):Int;
	#if swc @:getter(color) #end
    inline private function get_color():Int {
        var color:Int = 0;
		color += Std.int(red * 0xFF) << 16;
		color += Std.int(green * 0xFF) << 8;
		color += Std.int(blue * 0xFF);
		return color;
    }
	#if swc @:setter(color) #end
	inline public function set_color(p_value:Int):Int {
		red = Std.int(p_value >> 16 & 0xFF) / 0xFF;
        green = Std.int(p_value >> 8 & 0xFF) / 0xFF;
        blue = Std.int(p_value & 0xFF) / 0xFF;
		return p_value;
	}
	
    @prototype 
	public var mouseEnabled:Bool = true;
    @prototype 
	public var mouseChildren:Bool = true;

	@prototype
    public var visible:Bool = true;

    @prototype 
	public var flushBatch:Bool = false;

    @prototype 
	public var name:String = "";
	
	static public var dragSensitivity:Float = 0;
	
	public var userData:Dynamic;
	
	private var g2d_scrollable:Bool = false;
	#if swc @:extern #end
    @prototype 
	public var scrollable(get,set):Bool;
    #if swc @:getter(scrollable) #end
    inline private function get_scrollable():Bool {
        return g2d_scrollable;
    }
    #if swc @:setter(scrollable) #end
    inline private function set_scrollable(p_value:Bool):Bool {
		if (!g2d_scrollable && p_value) {
			onMouseDown.add(mouseDown_handler);
		} else if (g2d_scrollable && !p_value) {
			onMouseDown.remove(mouseDown_handler);
		}
		g2d_scrollable = p_value;
        return g2d_scrollable;
    }
	
	private var g2d_dragging:Bool = false;
	private var g2d_previousMouseX:Float;
	private var g2d_previousMouseY:Float;
	private var g2d_movedMouseX:Float;
	private var g2d_movedMouseY:Float;

    private var g2d_currentController:Dynamic;
    private var g2d_controller:Dynamic;
    public function getController():Dynamic {
        return (g2d_controller != null) ? g2d_controller : (parent != null) ? parent.getController() : null;
    }
    public function setController(p_value:Dynamic):Void {
        g2d_controller = p_value;

        invalidateController();
    }

    private function invalidateController():Void {
        var newController:Dynamic = getController();
        if (newController != g2d_currentController) {
            if (g2d_mouseDown != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseDown);
                if (mdf != null) onMouseDown.remove(mdf);
            }
			if (g2d_mouseUp != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseUp);
                if (mdf != null) onMouseUp.remove(mdf);
            }
			if (g2d_mouseOver != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseOver);
                if (mdf != null) onMouseOver.remove(mdf);
            }
			if (g2d_mouseOut != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseOut);
                if (mdf != null) onMouseOut.remove(mdf);
            }
			if (g2d_mouseClick != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseClick);
                if (mdf != null) onMouseClick.remove(mdf);
            }
			if (g2d_mouseMove != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseMove);
                if (mdf != null) onMouseMove.remove(mdf);
            }
            g2d_currentController = newController;
            if (g2d_mouseDown != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseDown);
                if (mdf != null) onMouseDown.add(mdf);
            }
			if (g2d_mouseUp != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseUp);
                if (mdf != null) onMouseUp.add(mdf);
            }
			if (g2d_mouseOver != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseOver);
                if (mdf != null) onMouseOver.add(mdf);
            }
			if (g2d_mouseOut != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseOut);
                if (mdf != null) onMouseOut.add(mdf);
            }
			if (g2d_mouseClick != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseClick);
                if (mdf != null) onMouseClick.add(mdf);
            }
			if (g2d_mouseMove != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseMove);
                if (mdf != null) onMouseMove.add(mdf);
            }

            for (i in 0...g2d_numChildren) {
                g2d_children[i].invalidateController();
            }
        }
    }

	@prototype
    public function setAlign(p_align:Int):Void {
		g2d_anchorLeft = g2d_anchorRight = ((p_align - 1) % 3) * 0.5;
		g2d_anchorTop = g2d_anchorBottom = Std.int((p_align - 1) / 3) * 0.5;
		g2d_pivotX = ((p_align - 1) % 3) * 0.5;		
		g2d_pivotY = Std.int((p_align - 1) / 3) * 0.5;		
        setDirty();
    }
	
	@prototype
    public function setAnchorAlign(p_align:Int):Void {
		g2d_anchorLeft = g2d_anchorRight = ((p_align - 1) % 3) * 0.5;
		g2d_anchorTop = g2d_anchorBottom = Std.int((p_align - 1) / 3) * 0.5;
        setDirty();
    }
	
	@prototype
    public function setPivotAlign(p_align:Int):Void {
		g2d_pivotX = ((p_align - 1) % 3) * 0.5;		
		g2d_pivotY = Std.int((p_align - 1) / 3) * 0.5;
        setDirty();
    }


    private var g2d_mouseDown:String = "";
    #if swc @:extern #end
    @prototype public var mouseDown(get,set):String;
    #if swc @:getter(mouseDown) #end
    inline private function get_mouseDown():String {
        return g2d_mouseDown;
    }
    #if swc @:setter(mouseDown) #end
    inline private function set_mouseDown(p_value:String):String {
		if (g2d_mouseDown != p_value) {
			if (g2d_mouseDown != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController,g2d_mouseDown);
				if (mdf != null) onMouseDown.remove(mdf);
			}
			g2d_mouseDown = p_value;
			if (g2d_mouseDown != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController,g2d_mouseDown);
				if (mdf != null) onMouseDown.add(mdf);
			}
		}
        return g2d_mouseDown;
    }

    private var g2d_mouseUp:String = "";
    #if swc @:extern #end
    @prototype public var mouseUp(get,set):String;
    #if swc @:getter(mouseUp) #end
    inline private function get_mouseUp():String {
        return g2d_mouseUp;
    }
    #if swc @:setter(mouseUp) #end
    inline private function set_mouseUp(p_value:String):String {
		if (g2d_mouseUp != p_value) {
			if (g2d_mouseUp != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseUp);
				if (mdf != null) onMouseUp.remove(mdf);
			}
			g2d_mouseUp = p_value;
			if (g2d_mouseUp != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseUp);
				if (mdf != null) onMouseUp.add(mdf);
			}
		}
        return g2d_mouseUp;
    }

    private var g2d_mouseClick:String = "";
    #if swc @:extern #end
    @prototype public var mouseClick(get,set):String;
    #if swc @:getter(mouseClick) #end
    inline private function get_mouseClick():String {
        return g2d_mouseClick;
    }
    #if swc @:setter(mouseClick) #end
    inline private function set_mouseClick(p_value:String):String {
		if (g2d_mouseClick != p_value) {
			if (g2d_mouseClick != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseClick);
				if (mdf != null) onMouseClick.remove(mdf);
			}
			g2d_mouseClick = p_value;
			if (g2d_mouseClick != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseClick);
				if (mdf != null) onMouseClick.add(mdf);
			}
		}
        return g2d_mouseClick;
    }

    private var g2d_mouseOver:String = "";
    #if swc @:extern #end
    @prototype public var mouseOver(get,set):String;
    #if swc @:getter(mouseOver) #end
    inline private function get_mouseOver():String {
        return g2d_mouseOver;
    }
    #if swc @:setter(mouseOver) #end
    inline private function set_mouseOver(p_value:String):String {
		if (g2d_mouseOver != p_value) {
			if (g2d_mouseOver != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseOver);
				if (mdf != null) onMouseOver.remove(mdf);
			}
			g2d_mouseOver = p_value;
			if (g2d_mouseOver != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseOver);
				if (mdf != null) onMouseOver.add(mdf);
			}
		}
        return g2d_mouseOver;
    }

    private var g2d_mouseOut:String = "";
    #if swc @:extern #end
    @prototype public var mouseOut(get,set):String;
    #if swc @:getter(mouseOut) #end
    inline private function get_mouseOut():String {
        return g2d_mouseOut;
    }
    #if swc @:setter(mouseOut) #end
    inline private function set_mouseOut(p_value:String):String {
		if (g2d_mouseOut != p_value) {
			if (g2d_mouseOut != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseOut);
				if (mdf != null) onMouseOut.remove(mdf);
			}
			g2d_mouseOut = p_value;
			if (g2d_mouseOut != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseOut);
				if (mdf != null) onMouseOut.add(mdf);
			}
		}
        return g2d_mouseOut;
    }

    private var g2d_mouseMove:String = "";
    #if swc @:extern #end
    @prototype public var mouseMove(get,set):String;
    #if swc @:getter(mouseMove) #end
    inline private function get_mouseMove():String {
        return g2d_mouseMove;
    }
    #if swc @:setter(mouseMove) #end
    inline private function set_mouseMove(p_value:String):String {
		if (g2d_mouseMove != p_value) {
			if (g2d_mouseMove != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseMove);
				if (mdf != null) onMouseMove.remove(mdf);
			}
			g2d_mouseMove = p_value;
			if (g2d_mouseMove != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseMove);
				if (mdf != null) onMouseMove.add(mdf);
			}
		}
        return g2d_mouseMove;
    }

    private var g2d_model:String = "";
    public function getModel():String {
        return g2d_model;
    }
	@prototype
    public function setModel(p_value:Dynamic):Void {
		if (setModelHook != null) p_value = setModelHook(p_value);
		
		// Xml assignment
        if (Std.is(p_value, Xml)) {
            var xml:Xml = cast (p_value, Xml);
            var it:Iterator<Xml> = xml.elements();
            if (!it.hasNext()) {
                if (xml.firstChild() != null && xml.firstChild().nodeType == Xml.PCData) {
                    g2d_model = xml.firstChild().nodeValue;
                } else {
                    g2d_model = "";
                }
            } else {
                while (it.hasNext()) {
                    var childXml:Xml = it.next();
                    var child:GUIElement = getChildByName(childXml.nodeName,true);
                    if (child != null) {
                        child.setModel(childXml);
                    }
                }
            }
		// Just direct string assignment
        } else if (Std.is(p_value,String)) {
            g2d_model = p_value;
		// Dynamic object lookup for public fields
        } else {
            for (it in Reflect.fields(p_value)) {
                var child:GUIElement = getChildByName(it);
                if (child != null) child.setModel(Reflect.field(p_value, it));
            }
        }
        onModelChanged.dispatch(this);
    }

    private var g2d_onModelChanged:GCallback1<GUIElement>;
    #if swc @:extern #end
    public var onModelChanged(get, never):GCallback1<GUIElement>;
    #if swc @:getter(onModelChanged) #end
    inline private function get_onModelChanged():GCallback1<GUIElement> {
        return g2d_onModelChanged;
    }

    private var g2d_layout:GUILayout;
    #if swc @:extern #end
    @prototype public var layout(get, set):GUILayout;
    #if swc @:getter(layout) #end
    inline private function get_layout():GUILayout {
        return g2d_layout;
    }
    #if swc @:setter(layout) #end
    inline private function set_layout(p_value:GUILayout):GUILayout {
        g2d_layout = p_value;
        setDirty();
        return g2d_layout;
    }

    private var g2d_activeSkin:GUISkin;

    private var g2d_skin:GUISkin;
    #if swc @:extern #end
    @prototype("getReference") public var skin(get, set):GUISkin;
    #if swc @:getter(skin) #end
    inline private function get_skin():GUISkin {
        return g2d_skin;
    }
    #if swc @:setter(skin) #end
    inline private function set_skin(p_value:GUISkin):GUISkin {
		if (p_value == null || g2d_skin == null || p_value.id != g2d_skin.id) {
			if (g2d_skin != null) g2d_skin.remove();
			g2d_skin = (p_value != null) ? p_value.attach(this) : p_value;
			g2d_activeSkin = g2d_skin;

			setDirty();
		}
        return g2d_skin;
    }

    private var g2d_dirty:Bool = true;
    private function setDirty():Void {
        g2d_dirty = true;
        if (g2d_parent != null) g2d_parent.setDirty();
    }

    private var g2d_anchorX:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorX(get, set):Float;
    #if swc @:getter(anchorX) #end
    inline private function get_anchorX():Float {
        return g2d_anchorX;
    }
    #if swc @:setter(anchorX) #end
    inline private function set_anchorX(p_value:Float):Float {
        g2d_anchorX = p_value;
        setDirty();
        return g2d_anchorX;
    }

    private var g2d_anchorY:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorY(get, set):Float;
    #if swc @:getter(anchorY) #end
    inline private function get_anchorY():Float {
        return g2d_anchorY;
    }
    #if swc @:setter(anchorY) #end
    inline private function set_anchorY(p_value:Float):Float {
        g2d_anchorY = p_value;
        setDirty();
        return g2d_anchorY;
    }

    private var g2d_anchorLeft:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorLeft(get, set):Float;
    #if swc @:getter(anchorLeft) #end
    inline private function get_anchorLeft():Float {
        return g2d_anchorLeft;
    }
    #if swc @:setter(anchorLeft) #end
    inline private function set_anchorLeft(p_value:Float):Float {
        g2d_anchorLeft = p_value;
        setDirty();
        return g2d_anchorLeft;
    }

    private var g2d_anchorTop:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorTop(get, set):Float;
    #if swc @:getter(anchorTop) #end
    inline private function get_anchorTop():Float {
        return g2d_anchorTop;
    }
    #if swc @:setter(anchorTop) #end
    inline private function set_anchorTop(p_value:Float):Float {
        g2d_anchorTop = p_value;
        setDirty();
        return g2d_anchorTop;
    }

    private var g2d_anchorRight:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorRight(get, set):Float;
    #if swc @:getter(anchorRight) #end
    inline private function get_anchorRight():Float {
        return g2d_anchorRight;
    }
    #if swc @:setter(anchorRight) #end
    inline private function set_anchorRight(p_value:Float):Float {
        g2d_anchorRight = p_value;
        setDirty();
        return g2d_anchorRight;
    }

    private var g2d_anchorBottom:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorBottom(get, set):Float;
    #if swc @:getter(anchorBottom) #end
    inline private function get_anchorBottom():Float {
        return g2d_anchorBottom;
    }
    #if swc @:setter(anchorBottom) #end
    inline private function set_anchorBottom(p_value:Float):Float {
        g2d_anchorBottom = p_value;
        setDirty();
        return g2d_anchorBottom;
    }

    private var g2d_left:Float = 0;
    #if swc @:extern #end
    @prototype public var left(get, set):Float;
    #if swc @:getter(left) #end
    inline private function get_left():Float {
        return g2d_left;
    }
    #if swc @:setter(left) #end
    inline private function set_left(p_value:Float):Float {
        g2d_left = p_value;
        setDirty();
        return g2d_left;
    }

    private var g2d_top:Float = 0;
    #if swc @:extern #end
    @prototype public var top(get, set):Float;
    #if swc @:getter(top) #end
    inline private function get_top():Float {
        return g2d_top;
    }
    #if swc @:setter(top) #end
    inline private function set_top(p_value:Float):Float {
        g2d_top = p_value;
        setDirty();
        return g2d_top;
    }

    private var g2d_right:Float = 0;
    #if swc @:extern #end
    @prototype public var right(get, set):Float;
    #if swc @:getter(right) #end
    inline private function get_right():Float {
        return g2d_right;
    }
    #if swc @:setter(right) #end
    inline private function set_right(p_value:Float):Float {
        g2d_right = p_value;
        setDirty();
        return g2d_right;
    }

    public var g2d_bottom:Float = 0;
    #if swc @:extern #end
    @prototype public var bottom(get, set):Float;
    #if swc @:getter(bottom) #end
    inline private function get_bottom():Float {
        return g2d_bottom;
    }
    #if swc @:setter(bottom) #end
    inline private function set_bottom(p_value:Float):Float {
        g2d_bottom = p_value;
        setDirty();
        return g2d_bottom;
    }

    public var g2d_pivotX:Float = 0;
    #if swc @:extern #end
    @prototype public var pivotX(get, set):Float;
    #if swc @:getter(pivotX) #end
    inline private function get_pivotX():Float {
        return g2d_pivotX;
    }
    #if swc @:setter(pivotX) #end
    inline private function set_pivotX(p_value:Float):Float {
        g2d_pivotX = p_value;
        setDirty();
        return g2d_pivotX;
    }

    public var g2d_pivotY:Float = 0;
    #if swc @:extern #end
    @prototype public var pivotY(get, set):Float;
    #if swc @:getter(pivotY) #end
    inline private function get_pivotY():Float {
        return g2d_pivotY;
    }
    #if swc @:setter(pivotY) #end
    inline private function set_pivotY(p_value:Float):Float {
        g2d_pivotY = p_value;
        setDirty();
        return g2d_pivotY;
    }

    public var g2d_worldLeft:Float;
    public var g2d_worldTop:Float;
    public var g2d_worldRight:Float;
    public var g2d_worldBottom:Float;
	
	@prototype
	public var expand:Bool = true;

    private var g2d_minWidth:Float = 0;
    public var g2d_finalWidth:Float = 0;

    private var g2d_preferredWidth:Float = 0;
    #if swc @:extern #end
    @prototype 
	public var preferredWidth(get, set):Float;
    #if swc @:getter(preferredWidth) #end
    inline private function get_preferredWidth():Float {
        return g2d_preferredWidth;
    }
    #if swc @:setter(preferredWidth) #end
    inline private function set_preferredWidth(p_value:Float):Float {
        g2d_preferredWidth = p_value;
        setDirty();
        return g2d_preferredWidth;
    }

    private var g2d_minHeight:Float = 0;
    public var g2d_finalHeight:Float = 0;

    private var g2d_preferredHeight:Float = 0;
    #if swc @:extern #end
    @prototype public var preferredHeight(get, set):Float;
    #if swc @:getter(preferredHeight) #end
    inline private function get_preferredHeight():Float {
        return g2d_preferredHeight;
    }
    #if swc @:setter(preferredHeight) #end
    inline private function set_preferredHeight(p_value:Float):Float {
        g2d_preferredHeight = p_value;
        setDirty();
        return g2d_preferredHeight;
    }

    private var g2d_parent:GUIElement;
    #if swc @:extern #end
    public var parent(get, never):GUIElement;
    #if swc @:getter(parent) #end
    inline private function get_parent():GUIElement {
        return g2d_parent;
    }

    private var g2d_numChildren:Int = 0;
    #if swc @:extern #end
    public var numChildren(get, never):Int;
    #if swc @:getter(numChildren) #end
    inline private function get_numChildren():Int {
        return g2d_numChildren;
    }

    private var g2d_children:Array<GUIElement>;
    #if swc @:extern #end
    public var children(get, never):Array<GUIElement>;
    #if swc @:getter(children) #end
    inline private function get_children():Array<GUIElement> {
        return g2d_children;
    }


    public function new(p_skin:GUISkin = null) {
        g2d_onModelChanged = new GCallback1<GUIElement>();

        if (p_skin != null) skin = p_skin;
    }

    public function isParent(p_element:GUIElement):Bool {
        if (p_element == g2d_parent) return true;
        if (g2d_parent == null) return false;
        return g2d_parent.isParent(p_element);
    }

    public function setRect(p_left:Float, p_top:Float, p_right:Float, p_bottom:Float):Void {
        var w:Float = p_right-p_left;
        var h:Float = p_bottom-p_top;

        if (g2d_parent != null) {
            var worldAnchorLeft:Float = g2d_parent.g2d_worldLeft + g2d_parent.g2d_finalWidth * g2d_anchorLeft;
            var worldAnchorRight:Float = g2d_parent.g2d_worldLeft + g2d_parent.g2d_finalWidth * g2d_anchorRight;
            var worldAnchorTop:Float = g2d_parent.g2d_worldTop + g2d_parent.g2d_finalHeight * g2d_anchorTop;
            var worldAnchorBottom:Float = g2d_parent.g2d_worldTop + g2d_parent.g2d_finalHeight * g2d_anchorBottom;

            if (g2d_anchorLeft != g2d_anchorRight) {
                g2d_left = p_left - worldAnchorLeft;
                g2d_right = worldAnchorRight - p_right;
            } else {
                g2d_anchorX = p_left - worldAnchorLeft + w*g2d_pivotX;
            }

            if (g2d_anchorTop != g2d_anchorBottom) {
                g2d_top = p_top - worldAnchorTop;
                g2d_bottom = worldAnchorBottom - p_bottom;
            } else {
                g2d_anchorY = p_top - worldAnchorTop + h*g2d_pivotY;
            }
        } else {
            g2d_worldLeft = p_left;
            g2d_worldTop = p_top;
            g2d_worldRight = p_right;
            g2d_worldBottom = p_bottom;
            g2d_finalWidth = w;
            g2d_finalHeight = h;
        }

        g2d_preferredWidth = w;
        g2d_preferredHeight = h;

        setDirty();
    }

    public function addChild(p_child:GUIElement):Void {
        if (p_child.g2d_parent == this) return;
        if (g2d_children == null) g2d_children = new Array<GUIElement>();
        if (p_child.g2d_parent != null) p_child.g2d_parent.removeChild(p_child);
        g2d_children.push(p_child);
        g2d_numChildren++;
        p_child.g2d_parent = this;
        p_child.invalidateController();
        setDirty();
    }

    public function addChildAt(p_child:GUIElement, p_index:Int):Void {
        if (g2d_children == null) g2d_children = new Array<GUIElement>();
        if (p_child.g2d_parent != null) p_child.g2d_parent.removeChild(p_child);
        g2d_children.insert(p_index,p_child);
        g2d_numChildren++;
        p_child.g2d_parent = this;
        p_child.invalidateController();
        setDirty();
    }

    public function removeChild(p_child:GUIElement):Void {
        if (p_child.g2d_parent != this) return;
        g2d_children.remove(p_child);
        g2d_numChildren--;
        p_child.g2d_parent = null;
        p_child.invalidateController();
        setDirty();
    }

    public function getChildAt(p_index:Int):GUIElement {
        return (p_index>=0 && p_index<g2d_numChildren) ? g2d_children[p_index] : null;
    }

    public function getChildByName(p_name:String, p_recursive:Bool = false):GUIElement {
        for (i in 0...g2d_numChildren) {
			if (g2d_children[i].name == p_name) return g2d_children[i];
			if (p_recursive) {
				var childByName:GUIElement = g2d_children[i].getChildByName(p_name, true);
				if (childByName != null) return childByName;
			}
		}
        return null;
    }

    public function getChildIndex(p_child:GUIElement):Int {
        return g2d_children.indexOf(p_child);
    }
	
    private function calculateWidth():Void {
        if (g2d_dirty) {
            if (g2d_layout != null) {
                g2d_layout.calculateWidth(this);
            } else {
                g2d_minWidth = g2d_activeSkin != null ? g2d_activeSkin.getMinWidth() : 0;

                for (i in 0...g2d_numChildren) {
                    g2d_children[i].calculateWidth();
					//if (g2d_minWidth < g2d_children[i].g2d_minWidth) g2d_minWidth = g2d_children[i].g2d_minWidth;
                }
            }
        }
    }
	
	private function invalidateWidth():Void {
        if (g2d_dirty) {
            if (g2d_parent != null) {
                if (g2d_parent.g2d_layout == null) {
                    var worldAnchorLeft:Float = g2d_parent.g2d_worldLeft + g2d_parent.g2d_finalWidth * g2d_anchorLeft;
                    var worldAnchorRight:Float = g2d_parent.g2d_worldLeft + g2d_parent.g2d_finalWidth * g2d_anchorRight;
                    var w:Float = (g2d_preferredWidth > g2d_minWidth || !expand) ? g2d_preferredWidth : g2d_minWidth;

                    if (g2d_anchorLeft != g2d_anchorRight) {
                        g2d_worldLeft = worldAnchorLeft + g2d_left;
                        g2d_worldRight = worldAnchorRight - g2d_right;
                    } else {
                        g2d_worldLeft = worldAnchorLeft + g2d_anchorX - w * g2d_pivotX;
                        g2d_worldRight = worldAnchorLeft + g2d_anchorX + w * (1 - g2d_pivotX);
                    }
					
                    g2d_finalWidth = g2d_worldRight - g2d_worldLeft;
                }

                if (g2d_layout != null) {
                    g2d_layout.invalidateWidth(this);
                } else {
                    for (i in 0...g2d_numChildren) {
                        g2d_children[i].invalidateWidth();
                    }
                }
            } else {
                for (i in 0...g2d_numChildren) {
                    g2d_children[i].invalidateWidth();
                }
            }
        }
    }

    private function calculateHeight():Void {
        if (g2d_dirty) {
            if (g2d_layout != null) {
                g2d_layout.calculateHeight(this);
            } else {
                g2d_minHeight = g2d_activeSkin != null ? g2d_activeSkin.getMinHeight() : 0;

                for (i in 0...g2d_numChildren) {
                    g2d_children[i].calculateHeight();
                }
            }
        }
    }

    private function invalidateHeight():Void {
        if (g2d_dirty) {
            if (g2d_parent != null) {
                if (g2d_parent.g2d_layout == null || !g2d_parent.g2d_layout.isVerticalLayout()) {
                    var worldAnchorTop:Float = g2d_parent.g2d_worldTop + g2d_parent.g2d_finalHeight * g2d_anchorTop;
                    var worldAnchorBottom:Float = g2d_parent.g2d_worldTop + g2d_parent.g2d_finalHeight * g2d_anchorBottom;
                    var h:Float = (g2d_preferredHeight > g2d_minHeight || !expand) ? g2d_preferredHeight : g2d_minHeight;
                    if (g2d_anchorTop != g2d_anchorBottom) {
                        g2d_worldTop = worldAnchorTop + g2d_top;
                        g2d_worldBottom = worldAnchorBottom - g2d_bottom;
                    } else {
                        g2d_worldTop = worldAnchorTop + g2d_anchorY - h * g2d_pivotY;
                        g2d_worldBottom = worldAnchorTop + g2d_anchorY + h * (1 - g2d_pivotY);
                    }
                    g2d_finalHeight = g2d_worldBottom - g2d_worldTop;
                }

                if (g2d_layout != null) {
                    g2d_layout.invalidateHeight(this);
                } else {
                    for (i in 0...g2d_numChildren) {
                        g2d_children[i].invalidateHeight();
                    }
                }
            } else {
                for (i in 0...g2d_numChildren) {
                    g2d_children[i].invalidateHeight();
                }
            }
        }
    }

    public function render(p_red:Float = 1, p_green:Float = 1, p_blue:Float = 1, p_alpha:Float = 1):Void {
        if (visible) {
			var worldRed:Float = p_red * red;
			var worldGreen:Float = p_green * green;
			var worldBlue:Float = p_blue * blue;
			var worldAlpha:Float = p_alpha * alpha;
			
			var context:IGContext = Genome2D.getInstance().getContext();
			var previousMask:GRectangle = context.getMaskRect();
			var camera:GCamera = context.getActiveCamera();
			
            if (flushBatch || !expand) GUISkin.flushBatch();
			if (!expand) {
				context.setMaskRect(new GRectangle(g2d_worldLeft*camera.scaleX, g2d_worldTop*camera.scaleY, (g2d_worldRight - g2d_worldLeft)*camera.scaleX, (g2d_worldBottom - g2d_worldTop)*camera.scaleY));
			}
			
            if (g2d_activeSkin != null) g2d_activeSkin.render(g2d_worldLeft, g2d_worldTop, g2d_worldRight, g2d_worldBottom, worldRed, worldGreen, worldBlue, worldAlpha);

            for (i in 0...g2d_numChildren) {
                g2d_children[i].render(worldRed, worldGreen, worldBlue, worldAlpha);
            }
			
			if (!expand) context.setMaskRect(previousMask);
        }
    }

    public function getPrototype(p_prototype:GPrototype = null):GPrototype {		
		p_prototype = getPrototypeDefault(p_prototype);
		/*
        if (anchorX != 0) p_prototype.set("anchorX", Std.string(anchorX));
        if (anchorY != 0) p_prototype.set("anchorY", Std.string(anchorY));
        if (anchorLeft != 0) p_prototype.set("anchorLeft", Std.string(anchorLeft));
        if (anchorRight != 0) p_prototype.set("anchorRight", Std.string(anchorRight));
        if (anchorTop != 0) p_prototype.set("anchorTop", Std.string(anchorTop));
        if (anchorBottom != 0) p_prototype.set("anchorBottom", Std.string(anchorBottom));
        if (pivotX != 0) p_prototype.set("pivotX", Std.string(pivotX));
        if (pivotY != 0) p_prototype.set("pivotY", Std.string(pivotY));
        if (left != 0) p_prototype.set("left", Std.string(left));
        if (right != 0) p_prototype.set("right", Std.string(right));
        if (top != 0) p_prototype.set("top", Std.string(top));
        if (bottom != 0) p_prototype.set("bottom", Std.string(bottom));
        if (preferredWidth != 0) p_prototype.set("preferredWidth", Std.string(preferredWidth));
        if (preferredHeight != 0) p_prototype.set("preferredHeight", Std.string(preferredHeight));
        if (name != "") p_prototype.set("name", name);
        if (skin != null) p_prototype.set("skin", skin.id);
        if (mouseEnabled != true) p_prototype.set("mouseEnabled", Std.string(mouseEnabled));
        if (mouseChildren != true) p_prototype.set("mouseChildren", Std.string(mouseChildren));
        if (visible != true) p_prototype.set("visible", Std.string(visible));
        if (flushBatch != false) p_prototype.set("flushBatch", Std.string(flushBatch));
		if (scrollable != false) p_prototype.set("scrollable", Std.string(scrollable));

        if (mouseDown != "") p_prototype.set("mouseDown", mouseDown);
        if (mouseUp != "") p_prototype.set("mouseUp", mouseUp);
        if (mouseClick != "") p_prototype.set("mouseClick", mouseClick);
        if (mouseOver != "") p_prototype.set("mouseOver", mouseOver);
        if (mouseOut != "") p_prototype.set("mouseOut", mouseOut);
        if (mouseMove != "") p_prototype.set("mouseMove", mouseMove);
		/**/
        for (i in 0...g2d_numChildren) {
            p_prototype.addChild(g2d_children[i].getPrototype(), PROTOTYPE_DEFAULT_CHILD_GROUP);
        }

        return p_prototype;
    }
/**/
    public function bindPrototype(p_prototype:GPrototype):Void {
		var group:Array<GPrototype> = p_prototype.getGroup(PROTOTYPE_DEFAULT_CHILD_GROUP);
		if (group != null) {
			for (prototype in group) {
				var prototype:IGPrototypable = GPrototypeFactory.createPrototype(prototype);
				if (Std.is(prototype,GUIElement)) addChild(cast prototype);
			}
		}
		/*
        while (it.hasNext()) {
            var xml:Xml = it.next();
			// Should not be defined within prototype as such nodes are reserved for prototype reference
			if (xml.nodeName.indexOf("p:") != 0) {// != "prototype") {
				var prototype:IGPrototypable = GPrototypeFactory.createPrototype(p_prototype);
				if (Std.is(prototype, GUIElement)) {
					addChild(cast prototype);
				} else if (Std.is(prototype, GUILayout)) {
					layout = cast prototype;
				}
			}
        }
		/*
		if (p_prototypeXml.exists("expand")) expand = (p_prototypeXml.get("expand") != "false" && p_prototypeXml.get("expand") != "0");
        if (p_prototypeXml.exists("align")) setAlign(Std.parseInt(p_prototypeXml.get("align")));
		if (p_prototypeXml.exists("color")) color = Std.parseInt(p_prototypeXml.get("color"));
        if (p_prototypeXml.exists("anchorX")) anchorX = Std.parseFloat(p_prototypeXml.get("anchorX"));
        if (p_prototypeXml.exists("anchorY")) anchorY = Std.parseFloat(p_prototypeXml.get("anchorY"));
        if (p_prototypeXml.exists("anchorLeft")) anchorLeft = Std.parseFloat(p_prototypeXml.get("anchorLeft"));
        if (p_prototypeXml.exists("anchorRight")) anchorRight = Std.parseFloat(p_prototypeXml.get("anchorRight"));
        if (p_prototypeXml.exists("anchorTop")) anchorTop = Std.parseFloat(p_prototypeXml.get("anchorTop"));
        if (p_prototypeXml.exists("anchorBottom")) anchorBottom = Std.parseFloat(p_prototypeXml.get("anchorBottom"));
        if (p_prototypeXml.exists("pivotX")) pivotX = Std.parseFloat(p_prototypeXml.get("pivotX"));
        if (p_prototypeXml.exists("pivotY")) pivotY = Std.parseFloat(p_prototypeXml.get("pivotY"));
        if (p_prototypeXml.exists("left")) left = Std.parseFloat(p_prototypeXml.get("left"));
        if (p_prototypeXml.exists("right")) right = Std.parseFloat(p_prototypeXml.get("right"));
        if (p_prototypeXml.exists("top")) top = Std.parseFloat(p_prototypeXml.get("top"));
        if (p_prototypeXml.exists("bottom")) bottom = Std.parseFloat(p_prototypeXml.get("bottom"));
        if (p_prototypeXml.exists("preferredWidth")) preferredWidth = Std.parseFloat(p_prototypeXml.get("preferredWidth"));
        if (p_prototypeXml.exists("preferredHeight")) preferredHeight = Std.parseFloat(p_prototypeXml.get("preferredHeight"));
        if (p_prototypeXml.exists("name")) name = p_prototypeXml.get("name");
        if (p_prototypeXml.exists("skin")) skin = GUISkinManager.getSkin(p_prototypeXml.get("skin"));
        if (p_prototypeXml.exists("mouseEnabled")) mouseEnabled = (p_prototypeXml.get("mouseEnabled") != "false" && p_prototypeXml.get("mouseEnabled") != "0");
        if (p_prototypeXml.exists("mouseChildren")) mouseChildren = (p_prototypeXml.get("mouseChildren") != "false" && p_prototypeXml.get("mouseChildren") != "0");
        if (p_prototypeXml.exists("visible")) visible = (p_prototypeXml.get("visible") != "false" && p_prototypeXml.get("visible") != "0");
        if (p_prototypeXml.exists("flushBatch")) flushBatch = (p_prototypeXml.get("flushBatch") != "false" && p_prototypeXml.get("flushBatch") != "0");
		if (p_prototypeXml.exists("scrollable")) scrollable = (p_prototypeXml.get("scrollable") != "false" && p_prototypeXml.get("scrollable") != "0");
		
		if (p_prototypeXml.exists("model")) setModel(p_prototypeXml.get("model"));

        if (p_prototypeXml.exists("mouseDown")) mouseDown = p_prototypeXml.get("mouseDown");
        if (p_prototypeXml.exists("mouseUp")) mouseUp = p_prototypeXml.get("mouseUp");
        if (p_prototypeXml.exists("mouseClick")) mouseClick = p_prototypeXml.get("mouseClick");
        if (p_prototypeXml.exists("mouseOver")) mouseOver = p_prototypeXml.get("mouseOver");
        if (p_prototypeXml.exists("mouseOut")) mouseOut = p_prototypeXml.get("mouseOut");
        if (p_prototypeXml.exists("mouseMove")) mouseMove = p_prototypeXml.get("mouseMove");
		/**/
		bindPrototypeDefault(p_prototype);
		/**/
    }

    public function disposeChildren():Void {
        while (g2d_numChildren>0) {
            g2d_children[g2d_numChildren-1].dispose();
        }
    }

    public function dispose():Void {
        setDirty();
        if (g2d_parent != null) g2d_parent.removeChild(this);
    }

    /*******************************************************************************************************************
    *   MOUSE CODE
    *******************************************************************************************************************/
    private var g2d_onMouseDown:GCallback1<GMouseInput>;
    #if swc @:extern #end
    public var onMouseDown(get, never):GCallback1<GMouseInput>;
    #if swc @:getter(onMouseDown) #end
    inline private function get_onMouseDown():GCallback1<GMouseInput> {
        if (g2d_onMouseDown == null) g2d_onMouseDown = new GCallback1(GMouseInput);
        return g2d_onMouseDown;
    }

    private var g2d_onMouseUp:GCallback1<GMouseInput>;
    #if swc @:extern #end
    public var onMouseUp(get, never):GCallback1<GMouseInput>;
    #if swc @:getter(onMouseUp) #end
    inline private function get_onMouseUp():GCallback1<GMouseInput> {
        if (g2d_onMouseUp == null) g2d_onMouseUp = new GCallback1(GMouseInput);
        return g2d_onMouseUp;
    }

    private var g2d_onMouseMove:GCallback1<GMouseInput>;
    #if swc @:extern #end
    public var onMouseMove(get, never):GCallback1<GMouseInput>;
    #if swc @:getter(onMouseMove) #end
    inline private function get_onMouseMove():GCallback1<GMouseInput> {
        if (g2d_onMouseMove == null) g2d_onMouseMove = new GCallback1(GMouseInput);
        return g2d_onMouseMove;
    }

    private var g2d_onMouseOver:GCallback1<GMouseInput>;
    #if swc @:extern #end
    public var onMouseOver(get, never):GCallback1<GMouseInput>;
    #if swc @:getter(onMouseOver) #end
    inline private function get_onMouseOver():GCallback1<GMouseInput> {
        if (g2d_onMouseOver == null) g2d_onMouseOver = new GCallback1(GMouseInput);
        return g2d_onMouseOver;
    }

    private var g2d_onMouseOut:GCallback1<GMouseInput>;
    #if swc @:extern #end
    public var onMouseOut(get, never):GCallback1<GMouseInput>;
    #if swc @:getter(onMouseOut) #end
    inline private function get_onMouseOut():GCallback1<GMouseInput> {
        if (g2d_onMouseOut == null) g2d_onMouseOut = new GCallback1(GMouseInput);
        return g2d_onMouseOut;
    }

    private var g2d_onMouseClick:GCallback1<GMouseInput>;
    #if swc @:extern #end
    public var onMouseClick(get, never):GCallback1<GMouseInput>;
    #if swc @:getter(onMouseClick) #end
    inline private function get_onMouseClick():GCallback1<GMouseInput> {
        if (g2d_onMouseClick == null) g2d_onMouseMove = new GCallback1(GMouseInput);
        return g2d_onMouseClick;
    }

    private var g2d_mouseDownElement:GUIElement;
    private var g2d_mouseOverElement:GUIElement;

    public function captureMouseInput(p_input:GMouseInput):Void {
		if (visible) {
			if (mouseChildren) {
				var i:Int = g2d_numChildren;
				while (i>0) {
					i--;
					g2d_children[i].captureMouseInput(p_input);
				}
			}

			if (mouseEnabled) {
				if (p_input.g2d_captured && p_input.type == GMouseInputType.MOUSE_UP) g2d_mouseDownElement = null;
				
				p_input.localX = p_input.worldX - g2d_worldLeft;
				p_input.localY = p_input.worldY - g2d_worldTop;
				
				if (!p_input.g2d_captured && p_input.worldX > g2d_worldLeft && p_input.worldX < g2d_worldRight && p_input.worldY > g2d_worldTop && p_input.worldY < g2d_worldBottom) {
					if (g2d_activeSkin != null) g2d_activeSkin.captureMouseInput(p_input);
					p_input.g2d_captured = true;
					GFocusManager.activeFocus = this;
					g2d_dispatchMouseCallback(p_input.type, this, p_input);

					if (g2d_mouseOverElement != this) {
						g2d_dispatchMouseCallback(GMouseInputType.MOUSE_OVER, this, p_input);
					}
				} else {
					if (g2d_mouseOverElement == this) {
						g2d_dispatchMouseCallback(GMouseInputType.MOUSE_OUT, this, p_input);
					}
				}
			}
		}
    }
	
	private function mouseDown_handler(p_input:GMouseInput):Void {
		g2d_movedMouseX = g2d_movedMouseY = 0;
		g2d_previousMouseX = p_input.contextX;
		g2d_previousMouseY = p_input.contextY;
		Genome2D.getInstance().getContext().onMouseInput.add(contextMouseInput_handler);
		parent.onMouseMove.add(parentMouseMove_handler);
	}
	
	private function parentMouseMove_handler(p_input:GMouseInput):Void {
		g2d_movedMouseX += p_input.contextX - g2d_previousMouseX;
		//g2d_movedMouseY += p_input.contextY - g2d_previousMouseY;
		if (g2d_dragging || Math.abs(g2d_movedMouseX)>dragSensitivity || Math.abs(g2d_movedMouseY)>dragSensitivity) {
			//_dragFrame = Genome2D.getInstance().getCurrentFrameId();
			anchorX += (p_input.contextX - g2d_previousMouseX) / p_input.camera.scaleX;
			if (anchorX > 0) anchorX = 0;
			if (anchorX < parent.g2d_finalWidth - g2d_minWidth) anchorX = parent.g2d_finalWidth - g2d_minWidth;
			g2d_dragging = true;
		}
		g2d_previousMouseX = p_input.contextX;
		g2d_previousMouseY = p_input.contextY;
	}
	
	private function contextMouseInput_handler(p_input:GMouseInput):Void {
		if (p_input.type == GMouseInputType.MOUSE_UP) {
			g2d_dragging = false;
			parent.onMouseMove.remove(parentMouseMove_handler);
			Genome2D.getInstance().getContext().onMouseInput.remove(contextMouseInput_handler);
		}
	}

    private function g2d_dispatchMouseCallback(p_type:String, p_element:GUIElement, p_input:GMouseInput):Void {
        if (mouseEnabled) {
            var mouseInput:GMouseInput = p_input.clone(this, p_element, p_type);

            switch (p_type) {
                case GMouseInputType.MOUSE_DOWN:
                    g2d_mouseDownElement = p_element;
                    if (g2d_onMouseDown != null) g2d_onMouseDown.dispatch(mouseInput);
                case GMouseInputType.MOUSE_MOVE:
                    if (g2d_onMouseMove != null) g2d_onMouseMove.dispatch(mouseInput);
                case GMouseInputType.MOUSE_UP:
                    if (g2d_mouseDownElement == p_element && g2d_onMouseClick != null) {
                        var mouseClickInput:GMouseInput = p_input.clone(this, p_element, GMouseInputType.MOUSE_UP);
                        g2d_onMouseClick.dispatch(mouseClickInput);
                    }
                    g2d_mouseDownElement = null;
                    if (g2d_onMouseUp != null) g2d_onMouseUp.dispatch(mouseInput);
                case GMouseInputType.MOUSE_OVER:
                    g2d_mouseOverElement = p_element;
                    if (g2d_onMouseOver != null) g2d_onMouseOver.dispatch(mouseInput);
                case GMouseInputType.MOUSE_OUT:
                    g2d_mouseOverElement = null;
                    if (g2d_onMouseOut != null) g2d_onMouseOut.dispatch(mouseInput);
            }
        }

        if (parent != null) parent.g2d_dispatchMouseCallback(p_type, p_element, p_input);
    }
	
	public function setState(p_stateName:String):Void {
		setPrototypeState(p_stateName);
		if (g2d_children != null) {
			for (child in g2d_children) {
				child.setState(p_stateName);
			}
		}
	}
	
	public function getState():String {
		return g2d_currentState;
	}
}
