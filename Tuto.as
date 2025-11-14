class Tuto {
    static var app : Tuto;
    function Tuto() {

        // creates a 'tf' TextField size 320x240 at pos 0,0
        _root.createTextField("tf",0,0,0,320,240);
        // write some text into it
        _root.tf.text = "Hello world !";
        drawRectangle(50,50,200,200);
    }
    static function drawRectangle(x1,y1,x2,y2){
        // Draw a rectangle on the root
        _root.lineStyle(2, 0x000000, 100); // black border
        _root.beginFill(0xFF0000, 100);    // red fill
        _root.moveTo(x1, y1);
        _root.lineTo(x2, y1);
        _root.lineTo(x2, y2);
        _root.lineTo(x1, y2);
        _root.lineTo(x1, y1);
        _root.endFill();
    }
    // entry point
    static function main(mc) {
        app = new Tuto();
    }
}