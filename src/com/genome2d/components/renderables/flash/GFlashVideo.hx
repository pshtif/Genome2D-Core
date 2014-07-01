#if flash
package com.genome2d.components.renderables.flash;

import flash.events.NetStatusEvent;
import flash.events.IOErrorEvent;
import flash.utils.Object;
import com.genome2d.node.GNode;
import flash.media.Video;
import flash.net.NetStream;
import flash.net.NetConnection;

class GFlashVideo extends GFlashObject {
    private var g2d_connection:NetConnection;

    private var g2d_stream:NetStream;
    public function getNetStream():NetStream {
        return g2d_stream;
    }

    private var g2d_nativeVideo:Video;
    public function getNativeVideo():Video {
        return g2d_nativeVideo;
    }

    private var g2d_playing:Bool = false;
    private var g2d_textureId:String;

    static private var g2d_count:Int = 0;

    override public function init():Void {
        g2d_textureId = "G2DVideo#"+g2d_count++;

        g2d_connection = new NetConnection();
        g2d_connection.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
        g2d_connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
        g2d_connection.connect(null);

        g2d_stream = new NetStream(g2d_connection);
        g2d_stream.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
        g2d_stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
        g2d_stream.client = this;

        g2d_nativeVideo = new Video();
        g2d_nativeVideo.attachNetStream(g2d_stream);
        nativeObject = g2d_nativeVideo;
    }

    public function onMetaData(p_data:Object):Void {
        g2d_nativeVideo.width = (p_data.width!=undefined) ? p_data.width : 320;
        g2d_nativeVideo.height = (p_data.height!=undefined) ? p_data.height : 240;

        if (updateFrameRate != 0 && p_data.framerate != undefined) updateFrameRate = p_data.framerate;
    }

    public function onPlayStatus(p_data:Object):Void {
        if (p_data.code == "Netstream.Play.Complete") g2d_playing = false;
    }

    public function playVideo(p_url:String):Void {
        g2d_stream.play(p_url);
    }

    private function onIOError(event:IOErrorEvent):Void {
    }

    private function onNetStatus(event:NetStatusEvent):Void {
        switch (event.info.code) {
            case "NetStream.Play.Stop":
                g2d_stream.seek(0);
                break;
        }
    }

    override public function dispose():Void {
        g2d_nativeVideo = null;

        g2d_stream.close();
        g2d_stream = null;

        g2d_connection.close();
        g2d_connection = null;
    }
}
#end