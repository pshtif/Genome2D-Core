package com.genome2d.project;

import com.genome2d.callbacks.GCallback.GCallback0;
import com.genome2d.debug.GDebug;
import com.genome2d.macros.MGDebug;
import com.genome2d.assets.GAssetManager;
import com.genome2d.context.GContextConfig;
import com.genome2d.assets.GAsset;
import com.genome2d.assets.GStaticAssetManager;
import com.genome2d.geom.GRectangle;
#if cs
import unityengine.*;
#end

#if !cs
class GProject {
#else
@:nativeGen
class GProject extends MonoBehaviour {
#end
    public var onFrame(default,null):GCallback0;

    private var g2d_genome:Genome2D;
    public function getGenome():Genome2D {
        return g2d_genome;
    }

    private var g2d_config:GProjectConfig;

    private var g2d_assetManager:GAssetManager;

    #if !cs
    public function new(p_config:GProjectConfig) {
        g2d_config = p_config;

        g2d_genome = Genome2D.getInstance();
        if (g2d_config.initGenome) {
            initGenome();
        } else {
            init();
        }
    }
    #else
    public function Start() {
        GDebug.info("Starting project.");
        onFrame = new GCallback0();

        var contextConfig:GContextConfig = new GContextConfig(this, new GRectangle(0,0,800,600));
        g2d_config = new GProjectConfig(contextConfig);

        g2d_genome = Genome2D.getInstance();
        if (g2d_config.initGenome) {
            initGenome();
        } else {
            init();
        }
    }

    public function Update() {
        onFrame.dispatch();
    }
    #end
    /**
     *  Initialize Genome2D
     **/
    private function initGenome():Void {
        GDebug.info("initGenome");
        g2d_genome.onFailed.addOnce(genomeFailed_handler);
        g2d_genome.onInitialized.addOnce(genomeInitialized_handler);
        g2d_genome.init(g2d_config.contextConfig);
    }

    private function init():Void {
    }

    /**
     *  Handlers
     **/
    private function genomeInitialized_handler():Void {
        GDebug.info("genomeInitialized");
        g2d_assetManager = new GAssetManager();
        init();
    }

    private function genomeFailed_handler(p_msg:String):Void {
        GDebug.error("genomeFailed", p_msg);
    }
}
