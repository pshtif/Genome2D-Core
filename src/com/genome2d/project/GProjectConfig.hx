package com.genome2d.project;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GContextConfig;
class GProjectConfig {
    public var initGenome:Bool = true;

    public var contextConfig:GContextConfig;

    public function new() {
        #if (!swc && !js)
        contextConfig = new GContextConfig();
        #end

        #if js
        contextConfig = new GContextConfig(null, new GRectangle(0,0,720,1200));
        #end
    }
}
