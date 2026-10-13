/*
 * Funny Moments - Chumby image widget (ActionScript 2)
 *
 * Reads settings from parameters.txt (next to the SWF), falling back to
 * variables set on _root (e.g. FlashVars / chumby widget parameters), then
 * to defaults. Builds  http://<server>/<path>?<query>&t=<time>  and shows
 * the resulting image full screen, refreshing every <refresh> seconds.
 *
 * parameters.txt format (URL-encoded, one line):
 *   server=localhost:5000&path=chumby/image/test.jpg&query=&refresh=5
 *
 * Compile with MTASC:
 *   mtasc -version 8 -header 320:240:12 -main -swf funny_moments.swf Main.as
 */
class Main {
    static var WIDTH:Number = 320;
    static var HEIGHT:Number = 240;

    var server:String = "funny-moments.xyz";
    var path:String = "chumby/image/test.jpg";
    var query:String = "";
    var refreshSecs:Number = 5;

    var holder:MovieClip;
    var loader:MovieClipLoader;
    var status:TextField;
    var intervalId:Number;

    static function main() {
        var app:Main = new Main();
    }

    function Main() {
        // black background
        var bg:MovieClip = _root.createEmptyMovieClip("bg", _root.getNextHighestDepth());
        bg.beginFill(0x000000);
        bg.moveTo(0, 0);
        bg.lineTo(WIDTH, 0);
        bg.lineTo(WIDTH, HEIGHT);
        bg.lineTo(0, HEIGHT);
        bg.lineTo(0, 0);
        bg.endFill();

        holder = _root.createEmptyMovieClip("holder", _root.getNextHighestDepth());

        status = _root.createTextField("status", _root.getNextHighestDepth(), 0, 100, WIDTH, 40);
        status.textColor = 0xFFFFFF;
        status.text = "loading settings...";

        loader = new MovieClipLoader();
        var self:Main = this;
        var listener:Object = new Object();
        listener.onLoadInit = function(target:MovieClip) {
            self.status._visible = false;
        };
        listener.onLoadError = function(target:MovieClip, errorCode:String) {
            self.status._visible = true;
            self.status.text = "image load failed: " + errorCode;
        };
        loader.addListener(listener);

        loadParams();
    }

    function loadParams():Void {
        var self:Main = this;
        var lv:LoadVars = new LoadVars();
        lv.onLoad = function(ok:Boolean) {
            if (ok) {
                if (this.server != undefined && this.server != "") self.server = this.server;
                if (this.path != undefined && this.path != "") self.path = this.path;
                if (this.query != undefined) self.query = this.query;
                if (this.refresh != undefined && Number(this.refresh) > 0) self.refreshSecs = Number(this.refresh);
            }
            self.applyRootOverrides();
            self.start();
        };
        lv.load("parameters.txt");
    }

    // Values set on _root (FlashVars / chumby widget params) win over the file.
    function applyRootOverrides():Void {
        if (_root.server != undefined && _root.server != "") server = _root.server;
        if (_root.path != undefined && _root.path != "") path = _root.path;
        if (_root.query != undefined) query = _root.query;
        if (_root.refresh != undefined && Number(_root.refresh) > 0) refreshSecs = Number(_root.refresh);
    }

    function buildUrl():String {
        var url:String = "http://" + server + "/" + path;
        var sep:String = (path.indexOf("?") >= 0) ? "&" : "?";
        if (query != "") {
            url += sep + query;
            sep = "&";
        }
        // cache buster so the device never shows a stale image
        url += sep + "t=" + new Date().getTime();
        return url;
    }

    function start():Void {
        status.text = "loading image...";
        loadImage();
        intervalId = setInterval(this, "loadImage", refreshSecs * 1000);
    }

    function loadImage():Void {
        loader.loadClip(buildUrl(), holder);
    }
}
