// Simple RSS viewer for Chumby / Flash Lite 3
// Compatible with MTASC or Haxe (AS2)
// Designed for 320x240 or 480x272 displays

// chumby_rss.as
class ChumbyRss extends MovieClip {

    // constructor
    function ChumbyRss() {
        Stage.scaleMode = "noScale";
        Stage.align = "TL";

        FEED_URL = "http://example.com/feed.rss";
        AUTO_CYCLE_INTERVAL = 10000;

        items = [];
        currentIndex = 0;
        autoMode = true;
        leftPanel = _root.createEmptyMovieClip("leftPanel", 1);
        rightPanel = _root.createEmptyMovieClip("rightPanel", 2);

        loadRSS();
    }

    // class-level variables
    var FEED_URL:String;
    var AUTO_CYCLE_INTERVAL:Number;
    var items:Array;
    var currentIndex:Number;
    var autoMode:Boolean;
    var leftWidth:Number = 150;
    var padding:Number = 10;
    var titleBoxHeight:Number = 30;
    var leftPanel:MovieClip;
    var rightPanel:MovieClip;

    
    // draw background rectangles
    function drawRoundedRect(mc, x, y, w, h, r, color) {
        mc.lineStyle(1, 0x333333, 100);
        mc.beginFill(color, 100);
        mc.moveTo(x + r, y);
        mc.lineTo(x + w - r, y);
        mc.curveTo(x + w, y, x + w, y + r);
        mc.lineTo(x + w, y + h - r);
        mc.curveTo(x + w, y + h, x + w - r, y + h);
        mc.lineTo(x + r, y + h);
        mc.curveTo(x, y + h, x, y + h - r);
        mc.lineTo(x, y + r);
        mc.curveTo(x, y, x + r, y);
        mc.endFill();
    }

    // simple textfield helper
    function makeText(mc, name, x, y, w, h, size, color, multiline) {
        var t = mc.createTextField(name, mc.getNextHighestDepth(), x, y, w, h);
        t.multiline = multiline;
        t.wordWrap = multiline;
        t.selectable = false;
        t.textColor = color;
        t.background = false;
        t.border = false;
        var fmt = new TextFormat();
        fmt.font = "_sans";
        fmt.size = size;
        t.setNewTextFormat(fmt);
        return t;
    }

    // load RSS feed
    function loadRSS() {
        var lv = new LoadVars();
        var self = this;
        lv.onData = function(raw) {
            if (raw == undefined) return;
            var xml = new XML(raw);
            xml.ignoreWhite = true;
            self.parseRSS(xml);
        };
        lv.load(FEED_URL);
    }

    // parse items
    function parseRSS(xml) {
        var channel = xml.firstChild;
        if (!channel) return;
        var nodes = channel.childNodes;
        for (var i=0; i<nodes.length; i++) {
            if (nodes[i].nodeName == "item") {
                var title = nodes[i].firstChild.nodeValue;
                var desc = "";
                var kids = nodes[i].childNodes;
                for (var j=0; j<kids.length; j++) {
                    if (kids[j].nodeName == "title") title = kids[j].firstChild.nodeValue;
                    if (kids[j].nodeName == "description") desc = kids[j].firstChild.nodeValue;
                }
                items.push({title:title, desc:desc});
                if (items.length >= 10) break;
            }
        }
        buildUI();
    }

    // build layout
    function buildUI() {
        drawRoundedRect(leftPanel, 0, 0, leftWidth, Stage.height, 10, 0x222222);
        drawRoundedRect(rightPanel, leftWidth + padding, 0, Stage.width - leftWidth - 2*padding, Stage.height, 10, 0x000000);

        for (var i=0; i<items.length; i++) {
            var y = padding + i*(titleBoxHeight+5);
            var box = leftPanel.createEmptyMovieClip("box"+i, leftPanel.getNextHighestDepth());
            drawRoundedRect(box, padding/2, y, leftWidth - padding, titleBoxHeight, 6, 0x444444);
            var txt = makeText(box, "txt", padding, y+5, leftWidth - 2*padding, titleBoxHeight-10, 10, 0xFFFFFF, false);
            txt.text = truncate(items[i].title, 25);
            box.index = i;
            var self = this;
            box.onRelease = function() {
                self.autoMode = false;
                self.currentIndex = this.index;
                self.showItem(self.currentIndex);
            };
            this = self;
        }

        rightPanel.title = makeText(rightPanel, "title", leftWidth + 2*padding, padding, Stage.width - leftWidth - 3*padding, 40, 14, 0xFFFFFF, true);
        rightPanel.desc  = makeText(rightPanel, "desc",  leftWidth + 2*padding, 50, Stage.width - leftWidth - 3*padding, Stage.height - 60, 12, 0xDDDDDD, true);

        showItem(0);
        setInterval(autoCycle, AUTO_CYCLE_INTERVAL);
    }

    // show current item
    function showItem(i) {
        if (items.length == 0) return;
        var item = items[i];
        rightPanel.title.text = item.title;
        rightPanel.desc.text = item.desc;
        highlightItem(i);
    }

    function highlightItem(i) {
        for (var j=0; j<items.length; j++) {
            var box = leftPanel["box"+j];
            if (box) drawRoundedRect(box, padding/2, padding + j*(titleBoxHeight+5), leftWidth - padding, titleBoxHeight, 6, (j==i)?0x6666FF:0x444444);
        }
    }

    function autoCycle() {
        if (!autoMode) return;
        currentIndex = (currentIndex + 1) % items.length;
        showItem(currentIndex);
    }

    function truncate(str, len) {
        if (str.length > len) return str.substr(0, len-3) + "...";
        else return str;
    }
}