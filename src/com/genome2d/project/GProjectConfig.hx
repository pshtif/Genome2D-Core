package com.genome2d.project;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GContextConfig;
class GProjectConfig {
    public var initGenome:Bool = true;

    public var contextConfig:GContextConfig;

    public function new(p_contextConfig:GContextConfig) {
        #if (!swc && !js)
        contextConfig = p_contextConfig == null ? new GContextConfig() : p_contextConfig;
        #end

        #if jsa
        contextConfig = p_contextConfig == null ? new GContextConfig(null) : p_contextConfig;
        #end
    }
}
