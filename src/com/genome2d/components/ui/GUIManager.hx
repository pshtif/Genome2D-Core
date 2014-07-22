/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components.ui;

import com.genome2d.node.GNode;
import com.genome2d.components.GComponent;
class GUIManager extends GComponent {
    private var g2d_uiItems:Array<GUIItem>;
    private var g2d_currentStateId:String;

    public function new():Void {
        super();
        g2d_uiItems = new Array<GUIItem>();
    }

    public function addItem(p_node:GNode):GUIItem {
        var uiItem:GUIItem = cast p_node.addComponent(GUIItem);
        g2d_uiItems.push(uiItem);

        if (!uiItem.hasState("default")) {
            uiItem.addState("default", new GUIStateTransform(0, p_node.transform.x, p_node.transform.y, p_node.transform.scaleX, p_node.transform.scaleY, p_node.transform.alpha));
        }

        if (p_node.parent != node) {
            node.addChild(p_node);
        }

        return uiItem;
    }

    public function changeState(p_stateId:String):Void {
        if (p_stateId == g2d_currentStateId) return;

        for (item in g2d_uiItems) {
            item.changeState(p_stateId);
        }
    }
}
