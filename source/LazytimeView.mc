import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;

class LazytimeView extends WatchUi.WatchFace {
    private const BACKGROUND as Number = 0x000000;
    private const HOUR_COLOR as Number = 0x929E9E;
    private const SECOND_COLOR as Number = 0x8C66DE;
    private const QUARTER_COLORS as Array<Number> = [0xFFFFFF, 0xFBC93D, 0x6CC0E5, 0xFB4F4F];
    private const ROMAN_HOURS as Array<String> = ["XII", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI"];
    private const HALF_GAP as Float = 2.0;
    private const BORDER_WIDTH as Float = 4.0;
    private var mSleeping as Boolean = false;
    private var mHourFont as Graphics.FontType = Graphics.FONT_NUMBER_HOT;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        mHourFont = WatchUi.loadResource(Rez.Fonts.HourFont) as Graphics.FontType;
    }

    function onShow() as Void {
        mSleeping = System has :getDisplayMode && System.getDisplayMode() == System.DISPLAY_MODE_LOW_POWER;
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        var centerX = dc.getWidth() / 2.0;
        var centerY = dc.getHeight() / 2.0;
        var radius = (dc.getWidth() < dc.getHeight() ? dc.getWidth() : dc.getHeight()) / 2.0;
        var outerRadius = radius * 0.99;
        var innerRadius = radius * 0.64;
        var clockTime = System.getClockTime();
        var currentQuarter = clockTime.min / 15;

        for (var quarter = 0; quarter < 4; quarter += 1) {
            drawQuarter(dc, centerX, centerY, innerRadius, outerRadius, quarter, quarter <= currentQuarter);
        }

        dc.setColor(BACKGROUND, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, innerRadius);
        dc.setColor(HOUR_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY, mHourFont, ROMAN_HOURS[clockTime.hour % 12], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        if (!mSleeping) {
            var angle = clockTime.sec * 2.0 * Math.PI / 60.0;
            var startRadius = innerRadius + radius * 0.06;
            var endRadius = outerRadius - radius * 0.06;
            var startX = centerX + startRadius * Math.sin(angle);
            var startY = centerY - startRadius * Math.cos(angle);
            var endX = centerX + endRadius * Math.sin(angle);
            var endY = centerY - endRadius * Math.cos(angle);
            dc.setStroke(0x248C66DE);
            dc.setPenWidth(16);
            dc.drawLine(startX, startY, endX, endY);
            dc.setStroke(0x488C66DE);
            dc.setPenWidth(10);
            dc.drawLine(startX, startY, endX, endY);
            dc.setStroke(0x808C66DE);
            dc.setPenWidth(6);
            dc.drawLine(startX, startY, endX, endY);
            dc.setStroke(0xFF000000 | SECOND_COLOR);
            dc.setPenWidth(2);
            dc.drawLine(startX, startY, endX, endY);
        }
    }

    private function drawQuarter(dc as Dc, centerX as Float, centerY as Float, innerRadius as Float, outerRadius as Float, quarter as Number, filled as Boolean) as Void {
        dc.setColor(filled ? QUARTER_COLORS[quarter] : BACKGROUND, Graphics.COLOR_TRANSPARENT);
        drawBand(dc, centerX, centerY, innerRadius - 1.0, outerRadius, quarter);
        if (!filled) {
            dc.setColor(QUARTER_COLORS[quarter], Graphics.COLOR_TRANSPARENT);
            drawBand(dc, centerX, centerY, innerRadius - 1.0, innerRadius + BORDER_WIDTH, quarter);
            drawBand(dc, centerX, centerY, outerRadius - BORDER_WIDTH, outerRadius, quarter);
            drawEdge(dc, centerX, centerY, innerRadius, outerRadius, quarter, false);
            drawEdge(dc, centerX, centerY, innerRadius, outerRadius, quarter, true);
        }
    }

    private function drawBand(dc as Dc, centerX as Float, centerY as Float, innerRadius as Float, outerRadius as Float, quarter as Number) as Void {
        var startAngle = quarter * Math.PI / 2.0;
        var quarterAngle = Math.PI / 2.0;
        var points = [pointOnCircle(centerX, centerY, innerRadius, startAngle + HALF_GAP / innerRadius)];
        for (var segment = 1; segment <= 30; segment += 1) {
            var fraction = segment / 30.0;
            var angle = startAngle + HALF_GAP / innerRadius + fraction * (quarterAngle - 2.0 * HALF_GAP / innerRadius);
            points.add(pointOnCircle(centerX, centerY, innerRadius, angle));
        }
        for (var segment = 30; segment >= 0; segment -= 1) {
            var fraction = segment / 30.0;
            var angle = startAngle + HALF_GAP / outerRadius + fraction * (quarterAngle - 2.0 * HALF_GAP / outerRadius);
            points.add(pointOnCircle(centerX, centerY, outerRadius, angle));
        }
        dc.fillPolygon(points);
    }

    private function drawEdge(dc as Dc, centerX as Float, centerY as Float, innerRadius as Float, outerRadius as Float, quarter as Number, atEnd as Boolean) as Void {
        var boundary = (quarter + (atEnd ? 1 : 0)) * Math.PI / 2.0;
        var direction = atEnd ? -1.0 : 1.0;
        dc.fillPolygon([
            pointOnCircle(centerX, centerY, innerRadius, boundary + direction * HALF_GAP / innerRadius),
            pointOnCircle(centerX, centerY, outerRadius, boundary + direction * HALF_GAP / outerRadius),
            pointOnCircle(centerX, centerY, outerRadius, boundary + direction * (HALF_GAP + BORDER_WIDTH) / outerRadius),
            pointOnCircle(centerX, centerY, innerRadius, boundary + direction * (HALF_GAP + BORDER_WIDTH) / innerRadius)
        ]);
    }

    private function pointOnCircle(centerX as Float, centerY as Float, radius as Float, angle as Float) as [Numeric, Numeric] {
        return [centerX + radius * Math.sin(angle), centerY - radius * Math.cos(angle)];
    }

    function onExitSleep() as Void {
        mSleeping = false;
    }

    function onEnterSleep() as Void {
        mSleeping = true;
    }
}