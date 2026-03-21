class SunTimes {
    var HEIGHT = 240;
    var WIDTH  = 320;

    var SUNRISE_HOUR  = 6;
    var SUNSET_HOUR   = 18;

    var ARC_CX = 160;
    var ARC_CY = 240;
    var ARC_R  = 160;

    var DOT_R  = 8;

    static var _uid : Number = 0;
    static var app  : SunTimes;

    static function getCurrentHour()   : Number { return 11; }
    static function getCurrentMinute() : Number { return 45; }

    static function nextName() : String {
        _uid++;
        return "mc_" + _uid;
    }

    function arcX(a) : Number { return ARC_CX + ARC_R * Math.cos(a); }
    function arcY(a) : Number { return ARC_CY - ARC_R * Math.sin(a); }

    // ---------------------------------------------------------------
    function SunTimes() {
        drawBackground();
        drawArc();
        drawBody();
        drawLabel();
    }

    function drawBackground() {
        var g = _root.createEmptyMovieClip(nextName(), _root.getNextHighestDepth());
        g.beginFill(0x0a0a2e, 100);
        g.moveTo(0, 0);
        g.lineTo(WIDTH, 0);
        g.lineTo(WIDTH, HEIGHT);
        g.lineTo(0, HEIGHT);
        g.lineTo(0, 0);
        g.endFill();
    }

    function drawArc() {
        var g = _root.createEmptyMovieClip(nextName(), _root.getNextHighestDepth());
        g.lineStyle(2, 0xffcc33, 80);

        var segments   = 8;
        var startAngle = Math.PI;
        var endAngle   = 0;
        var segAngle   = (endAngle - startAngle) / segments;

        g.moveTo(arcX(startAngle), arcY(startAngle));

        for (var i = 0; i < segments; i++) {
            var a0      = startAngle + i * segAngle;
            var a1      = a0 + segAngle;
            var aMid    = (a0 + a1) / 2;
            var halfSeg = (a1 - a0) / 2;
            var cpDist  = ARC_R / Math.cos(halfSeg);

            g.curveTo(
                ARC_CX + cpDist * Math.cos(aMid),
                ARC_CY - cpDist * Math.sin(aMid),
                arcX(a1),
                arcY(a1)
            );
        }
    }

    // ---------------------------------------------------------------
    // Compute angle along the arc and whether we are in daytime.
    //
    // Daytime  [sunrise .. sunset]:
    //   frac 0->1 maps to angle π->0  (left to right)
    //
    // Nighttime [sunset .. midnight .. sunrise]:
    //   The night window is 24 - (SUNSET - SUNRISE) hours long.
    //   We express the current time as hours since sunset,
    //   frac 0->1 maps to angle 0->π  (right back to left)
    // ---------------------------------------------------------------
    function drawBody() {
        var hour       = getCurrentHour();
        var minute     = getCurrentMinute();
        var nowDecimal = hour + minute / 60;

        var rise       = SUNRISE_HOUR;
        var set        = SUNSET_HOUR;
        var isDay      = (nowDecimal >= rise && nowDecimal <= set);
        var angle      : Number;

        if (isDay) {
            var frac = (nowDecimal - rise) / (set - rise);
            angle = Math.PI * (1 - frac);   // π at sunrise, 0 at sunset
        } else {
            // Hours since sunset, wrapping midnight
            var nightLength = 24 - (set - rise);   // total night hours
            var hoursSinceSunset : Number;
            if (nowDecimal > set) {
                hoursSinceSunset = nowDecimal - set;
            } else {
                // Before sunrise: we are in the second half of the night
                hoursSinceSunset = (24 - set) + nowDecimal;
            }
            var frac = hoursSinceSunset / nightLength;
            angle = Math.PI * frac;             // 0 at sunset, π at next sunrise
        }

        var dotX = arcX(angle);
        var dotY = arcY(angle);

        if (isDay) {
            // Filled sun with glow
            var glow = _root.createEmptyMovieClip(nextName(), _root.getNextHighestDepth());
            glow.lineStyle(2, 0xffee88, 50);
            glow.beginFill(0xffdd44, 30);
            drawCircleOnClip(glow, dotX, dotY, DOT_R + 4);
            glow.endFill();

            var sun = _root.createEmptyMovieClip(nextName(), _root.getNextHighestDepth());
            sun.lineStyle(1, 0xffaa00, 100);
            sun.beginFill(0xffdd00, 100);
            drawCircleOnClip(sun, dotX, dotY, DOT_R);
            sun.endFill();
        } else {
            // Outline-only dark sun
            var dark = _root.createEmptyMovieClip(nextName(), _root.getNextHighestDepth());
            dark.lineStyle(2, 0x8888cc, 100);
            drawCircleOnClip(dark, dotX, dotY, DOT_R);
        }
    }

    function drawCircleOnClip(mc, cx, cy, r) {
        var segments  = 8;
        var angleStep = (2 * Math.PI) / segments;
        mc.moveTo(cx + r, cy);
        for (var i = 0; i < segments; i++) {
            var a0     = i * angleStep;
            var a1     = a0 + angleStep;
            var aMid   = (a0 + a1) / 2;
            var cpDist = r / Math.cos(angleStep / 2);
            mc.curveTo(
                cx + cpDist * Math.cos(aMid),
                cy + cpDist * Math.sin(aMid),
                cx + r * Math.cos(a1),
                cy + r * Math.sin(a1)
            );
        }
    }

    function drawLabel() {
        var hour   = getCurrentHour();
        var minute = getCurrentMinute();
        var minStr = (minute < 10) ? ("0" + minute) : ("" + minute);

        _root.createTextField("tf_rise", _root.getNextHighestDepth(), 2, HEIGHT - 18, 60, 16);
        _root.tf_rise.text      = "06:00";
        _root.tf_rise.textColor = 0xffcc33;

        _root.createTextField("tf_set", _root.getNextHighestDepth(), WIDTH - 62, HEIGHT - 18, 60, 16);
        _root.tf_set.text      = "18:00";
        _root.tf_set.textColor = 0xffcc33;

        _root.createTextField("tf_now", _root.getNextHighestDepth(), (WIDTH / 2) - 30, 8, 60, 20);
        _root.tf_now.text      = hour + ":" + minStr;
        _root.tf_now.textColor = 0xffffff;
    }

    static function main(mc) {
        app = new SunTimes();
    }
}
