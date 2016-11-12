package com.genome2d.components;
import com.genome2d.globals.GParameters;
class GLevel extends GComponent {
    private var g2d_parameters:GParameters;

    override public function init():Void {
        g2d_parameters = new GParameters();
    }
}
