package com.genome2d.project;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GContextConfig;
import com.genome2d.debug.GDebug;
class GProjectConfig {
    public var initGenome:Bool = true;

    public var contextConfig:GContextConfig;

    public function new(p_contextConfig:GContextConfig) {
        #if (!swc && !js && !cs)
        contextConfig = p_contextConfig == null ? new GContextConfig() : p_contextConfig;
        #end

        #if js
        contextConfig = p_contextConfig == null ? new GContextConfig(null) : p_contextConfig;
        #end

        #if cs
        if (p_contextConfig == null) {
            GDebug.error("Need valid context config for cs target.");
        }

        contextConfig = p_contextConfig;
        #end
    }
}
