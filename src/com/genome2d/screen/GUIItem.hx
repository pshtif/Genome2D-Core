/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.screen;

import motion.Actuate;
import msignal.Signal.Signal1;
import com.genome2d.components.GComponent;

class GUIItem extends GComponent {
    private var g2d_states:Map<String, GUIStateTransform>;

    public var g2d_onStateChanged:Signal1<GUIItem>;

    public function addState(p_stateId:String, p_stateTransform:GUIStateTransform):Void {
        if (g2d_states == null) {
            g2d_states = new Map<String, GUIStateTransform>();
        }
        g2d_states.set(p_stateId, p_stateTransform);
    }

    public function hasState(p_stateId:String):Bool {
        return g2d_states.exists(p_stateId);
    }

    public function changeState(p_stateId:String):Void {
        if (g2d_onStateChanged == null) g2d_onStateChanged = new Signal1<GUIItem>();

        var stateTransform:GUIStateTransform = g2d_states.get(p_stateId);
        Actuate.tween(node.transform, stateTransform.time, {x:stateTransform.x, y:stateTransform.y, scaleX:stateTransform.scaleX, scaleY:stateTransform.scaleY, alpha:stateTransform.alpha}).onComplete(g2d_onStateChanged.dispatch, [this]);
    }
}
