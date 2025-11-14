class Tuto {
    var HEIGHT = 240;
    var WIDTH = 320;
    var PADDING = 20;
    static var app : Tuto;
    function Tuto() {

        // creates a 'tf' TextField size 320x240 at pos 0,0
        _root.createTextField("tf",0,0,0,320,240);
        // write some text into it
        _root.tf.text = "Hello world !";
        drawRoundedRect(PADDING,PADDING,75,200,10);
        drawRoundedRect((WIDTH/3),PADDING,200,200,10);
    }
    static function drawRoundedRect(x, y, w, h, r)
    {
        var g = _root.createEmptyMovieClip("gfx", _root.getNextHighestDepth());
        // r = corner radius

        g.lineStyle(2, 0x000000, 100); // border
        g.beginFill(0x000000, 100);    // fill

        // Start at top-left corner + radius
        g.moveTo(x + r, y);

        // Top edge
        g.lineTo(x + w - r, y);
        g.curveTo(x + w, y, x + w, y + r);

        // Right edge
        g.lineTo(x + w, y + h - r);
        g.curveTo(x + w, y + h, x + w - r, y + h);

        // Bottom edge
        g.lineTo(x + r, y + h);
        g.curveTo(x, y + h, x, y + h - r);

        // Left edge
        g.lineTo(x, y + r);
        g.curveTo(x, y, x + r, y);

        g.endFill();
    }

    static function drawRectangle(x1,y1,x2,y2){
        var g = _root.createEmptyMovieClip("gfx", _root.getNextHighestDepth());
        // Draw a rectangle on the root
        g.lineStyle(2, 0x000000, 100); // black border
        g.beginFill(0x000000, 100);    // red fill
        g.moveTo(x1, y1);
        g.lineTo(x2, y1);
        g.lineTo(x2, y2);
        g.lineTo(x1, y2);
        g.lineTo(x1, y1);
        g.endFill();
    }
    // entry point
    static function main(mc) {
        app = new Tuto();
    }
}