/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.assets;

import flash.display.BitmapData;
import msignal.Signal.Signal0;

class GAssetManager {
    static public var PATH_REGEX:EReg = ~/([^\?\/\\]+?)(?:\.([\w\-]+))?(?:\?.*)?$/;

    private var g2d_assetsQueue:Array<GAsset>;
    private var g2d_loading:Bool;
    private var g2d_assets:Array<GAsset>;

    private var g2d_onAllLoaded:Signal0;
    #if swc @:extern #end
    public var onAllLoaded(get,never):Signal0;
    #if swc @:getter(onAllLoaded) #end
    inline private function get_onAllLoaded():Signal0 {
        return g2d_onAllLoaded;
    }

    public function new() {
        g2d_assetsQueue = new Array<GAsset>();
        g2d_assets = new Array<GAsset>();

        g2d_onAllLoaded = new Signal0();
    }

    public function getAssetById(p_id:String):GAsset {
        for (i in 0...g2d_assets.length) {
            var asset:GAsset = g2d_assets[i];
            if (asset.id == p_id) return asset;
        }
        return null;
    }

    public function getXmlAssetById(p_id:String):GXmlAsset {
        var asset:GAsset = getAssetById(p_id);
        if (Std.is(asset, GXmlAsset)) return cast asset;
        return null;
    }

    public function getImageAssetById(p_id:String):GImageAsset {
        var asset:GAsset = getAssetById(p_id);
        if (Std.is(asset, GImageAsset)) return cast asset;
        return null;
    }

    public function add(p_asset:GAsset):Void {
        if (p_asset.isLoaded()) {
            g2d_assets.push(p_asset);
        } else {
            g2d_assetsQueue.push(p_asset);
        }
    }

    public function addUrl(p_id:String, p_url:String):Void {
        var asset:GAsset = null;

        switch (getExtension(p_url)) {
            case "jpg" | "jpeg" | "png":
                asset = new GImageAsset();
            case "atf":
                asset = new GImageAsset();
            case "xml":
                asset = new GXmlAsset();
        }

        if (asset != null) asset.initUrl(p_id, p_url);
        add(asset);
    }

    public function addImage(p_id:String, p_bitmapData:BitmapData):Void {
        var asset:GImageAsset = new GImageAsset();
        asset.initBitmapData(p_id, p_bitmapData);

        add(asset);
    }

    public function load():Void {
        if (g2d_loading) return;
        g2d_loadNext();
    }

    private function g2d_loadNext():Void {
        if (g2d_assetsQueue.length==0) {
            g2d_loading = false;
            g2d_onAllLoaded.dispatch();
        } else {
            g2d_loading = true;
            var asset:GAsset = g2d_assetsQueue.shift();
            asset.onLoaded.addOnce(g2d_hasAssetLoaded);
            asset.load();
        }
    }

    inline private function getName(p_path:String):String {
        PATH_REGEX.match(p_path);
        return PATH_REGEX.matched(1);
    }

    inline private function getExtension(p_path:String):String {
        PATH_REGEX.match(p_path);
        return PATH_REGEX.matched(2);
    }

    private function g2d_hasAssetLoaded(p_asset:GAsset):Void {
        g2d_assets.push(p_asset);
        g2d_loadNext();
    }
}
