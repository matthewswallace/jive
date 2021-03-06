package jive.themes;

import flash.system.Capabilities;

class Theme {
    public var foreground: Color = Color.BLUE;
    public var margin: Int;
    public var cornerSize: Int;
    public var dpiScale: Float;
    public var fontSize: Float = 14;
    public var controlHeaderFont: Font;

    public var defaultFont: Font;
    public var defaultTextColor: Int;

    public function new() {
    	var size = 500;

        // This 4 lines for charts. Later I'll remove it
        cornerSize = Std.int(fontSize / 3);
        margin = Std.int(size / 10);
        dpiScale = Capabilities.screenDPI / 72;
        controlHeaderFont = new Font();

        defaultFont = new Font();
        defaultTextColor = 0x000000;
    }
}
