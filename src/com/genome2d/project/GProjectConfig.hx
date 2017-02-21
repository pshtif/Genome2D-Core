package com.genome2d.project;
import com.genome2d.context.GContextConfig;
class GProjectConfig {
    public var initGenome:Bool = true;

    public var contextConfig:GContextConfig;

    public function new() {
        #if !swc
        contextConfig = new GContextConfig();
        #end
    }
}
