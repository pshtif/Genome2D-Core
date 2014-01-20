package com.genome2d.components.renderables;

import com.genome2d.geom.GFloatRectangle;
import com.genome2d.context.GContextCamera;

interface IRenderable {
    var blendMode:Int;

    function render(p_camera:GContextCamera, p_useMatrix:Bool):Void;

    function getBounds(p_target:GFloatRectangle = null):GFloatRectangle;
}
