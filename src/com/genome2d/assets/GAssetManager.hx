/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.assets;

import msignal.Signal.Signal0;
import msignal.Signal.Signal1;

class GAssetManager {
    static public var PATH_REGEX:EReg = ~/([^\?\/\\]+?)(?:\.([\w\-]+))?(?:\?.*)?$/;

    static public var ignoreFailed:Bool = false;

    static private var g2d_references:Map<String,GAsset>;
    static private var g2d_assetsQueue:Array<GAsset>;
    static private var g2d_loading:Bool;

    static private var g2d_onFailed:Signal1<GAsset>;
    #if swc @:extern #end
    static public var onFailed(get,never):Signal1<GAsset>;
    #if swc @:getter(onFailed) #end
    inline static private function get_onFailed():Signal1<GAsset> {
        return g2d_onFailed;
    }

    static private var g2d_onLoaded:Signal0;
    #if swc @:extern #end
    static public var onLoaded(get,never):Signal0;
    #if swc @:getter(onLoaded) #end
    inline static private function get_onLoaded():Signal0 {
        return g2d_onLoaded;
    }

    static public function init() {
        g2d_assetsQueue = new Array<GAsset>();
        g2d_references = new Map<String,GAsset>();

        g2d_onLoaded = new Signal0();
        g2d_onFailed = new Signal1(GAsset);
    }

    static public function getAssets():Map<String,GAsset> {
        return g2d_references;
    }

    static public function getAssetById(p_id:String):GAsset {
        return g2d_references.get(p_id);
    }

    static public function getXmlAssetById(p_id:String):GXmlAsset {
        return cast g2d_references.get(p_id);
    }

    static public function getImageAssetById(p_id:String):GImageAsset {
        return cast g2d_references.get(p_id);
    }

    static public function createAssetFromUrl(p_url:String, p_id:String = ""):GAsset {
        switch (getExtension(p_url)) {
            case "jpg" | "jpeg" | "png":
                return new GImageAsset(p_url, p_id);
            case "atf":
                return new GImageAsset(p_url, p_id);
            case "xml" | "fnt":
                return new GXmlAsset(p_url, p_id);
        }

        return null;
    }

    static public function load():Void {
        if (g2d_loading) return;
        for (asset in g2d_references) {
            if (!asset.isLoaded()) g2d_assetsQueue.push(asset);
        }
        g2d_loadNext();
    }

    static private function g2d_loadNext():Void {
        if (g2d_assetsQueue.length==0) {
            g2d_loading = false;
            g2d_onLoaded.dispatch();
        } else {
            g2d_loading = true;
            var asset:GAsset = g2d_assetsQueue.shift();
            asset.onLoaded.addOnce(g2d_assetLoadedHandler);
            asset.onFailed.addOnce(g2d_assetFailedHandler);
            asset.load();
        }
    }

    inline static private function getName(p_path:String):String {
        PATH_REGEX.match(p_path);
        return PATH_REGEX.matched(1);
    }

    inline static private function getExtension(p_path:String):String {
        PATH_REGEX.match(p_path);
        return PATH_REGEX.matched(2);
    }

    private static function g2d_assetLoadedHandler(p_asset:GAsset):Void {
        g2d_loadNext();
    }

    private static function g2d_assetFailedHandler(p_asset:GAsset):Void {
        g2d_onFailed.dispatch(p_asset);
        if (ignoreFailed) g2d_loadNext();
    }
}
