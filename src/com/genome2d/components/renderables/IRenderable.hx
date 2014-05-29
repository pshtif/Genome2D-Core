package com.genome2d.components.renderables;

import com.genome2d.geom.GRectangle;
import com.genome2d.context.GContextCamera;

interface IRenderable {
    function render(p_camera:GContextCamera, p_useMatrix:Bool):Void;

    function getBounds(p_target:GRectangle = null):GRectangle;
}
