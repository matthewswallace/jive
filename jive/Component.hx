package jive;

import jive.geom.IntRequest;
import jive.geom.IntRequest;
import jive.geom.DimensionRequest;
import jive.geom.IntRectangle;
import jive.state.StateManager;
import jive.state.States;
import jive.state.State;
import haxe.ds.StringMap;
import jive.state.Statefull;
import jive.geom.MetricInsets;
import openfl.geom.Matrix;
import jive.geom.IntPoint;
import openfl.geom.Rectangle;
import bindx.IBindable;
import openfl.display.Sprite;
import openfl.events.EventDispatcher;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.geom.Point;

import jive.geom.IntDimension;
import jive.geom.Metric;
import jive.geom.MetricDimension;

using jive.geom.MetricHelper;

@:bindable
class Component extends EventDispatcher implements IBindable implements Statefull {

    private var needsPaint:Bool = true;

    public var state(default, set): String;
    private function set_state(v: String): String {
        if (v == State.CHANGING || state == State.CHANGING) {
            state = v;
        } else {
            StateManager.changeTo(this, v);
        }
        return v;
    }

    public var name: String; // for debug
    public var states(default, set): States;
    private function set_states(v: States): States {
        states = v;
        return v;
    }

    @:isVar public var x(get, set): Metric;
    private function get_x() { return x; }
    private function set_x(v:Metric): Metric {
        x = v;
        reposition();
        return v;
    }

    @:isVar public var y(default, set): Metric;
    private function get_y() { return y; }
    private function set_y(v:Metric):Metric {
        y = v;
        reposition();
        return v;
    }

    @:isVar public var width(default, set): Metric;
    private function get_width() { return width; }
    private function set_width(v:Metric):Metric {
        if (width != v) {
            repaint();
            invalidatePreferredSize();
            width = v;
        }
        return v;
    }

    @:isVar public var height(default, set):Metric;
    private function get_height() { return height; }
    private function set_height(v:Metric):Metric {
        if (height != v) {
            repaint();
            invalidatePreferredSize();
            height = v;
        }
        return v;
    }

    @:isVar public var margin(get, set): MetricInsets;
    private function get_margin(): MetricInsets { return margin; }
    private function set_margin(v: MetricInsets): MetricInsets {
        margin = v;
        if (null != parent) parent.repaintChildren();
        invalidatePreferredSize();
        return v;
    }

    public var rotationAngle(default, set):Float;
    private function set_rotationAngle(v:Float):Float {
        rotationAngle = v;
        repaint();
        return v;
    }

    public var rotationPivot(default, set):IntPoint;
    private function set_rotationPivot(v:IntPoint):IntPoint {
        rotationPivot = v;
        repaint();
        return v;
    }

    public var alpha(default, set):Float;
    private function set_alpha(v:Float):Float {
        alpha = v;
        repaint();
        return v;
    }

    public var sprite(default, null): Sprite;

    public var parent(default, set):Container;
    private function set_parent(c:Container):Container {
        parent = c;
        repaint();
        invalidatePreferredSize();
        return c;
    }

    private var cachedPreferredSize: IntDimension;


    public function new() {
        super();
        sprite = new Sprite();
        x = Metric.absolute(0);
        y = Metric.absolute(0);
        width = Metric.none;
        height = Metric.none;
        margin = new MetricInsets();
    }

    /**
    * Destroy component
    * e.g. delete all bitmap graphics
    * and remove all listeners
    **/

    public function dispose() {
        for (l in listeners)
            sprite.removeEventListener(l.type, l.listener, l.useCapture);
        listeners = null;
    }


    //****************************************************************
    // Start IEventDispatcher methods
    //****************************************************************

    private var listeners:Array<EventListenerInfo>;

    override public function addEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false,
                                              priority:Int = 0, useWeakReference:Bool = false):Void {

        if (listeners == null) {
            listeners = new Array<EventListenerInfo>();
        }

        sprite.addEventListener(type, listener, useCapture, priority, useWeakReference);

        listeners.push({
            type: type,
            listener: listener,
            useCapture: useCapture
        });
    }

    override public function dispatchEvent(event:Event):Bool {
        return sprite.dispatchEvent(event);
    }

    override public function hasEventListener(type:String):Bool {
        return sprite.hasEventListener(type);
    }

    override public function removeEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false):Void {
        var found = listeners.filter(function(info:EventListenerInfo) {
            return info.type == type && info.listener == listener && info.useCapture == useCapture;
        });

        // should be only one
        for (f in found)
            listeners.remove(f);

        sprite.removeEventListener(type, listener, useCapture);
    }

    override public function toString():String {
        return sprite.toString();
    }

    override public function willTrigger(type:String):Bool {
        return sprite.willTrigger(type);
    }

    public function paint(size: IntDimension) {
        if (needsPaint) {
            needsPaint = false;
            doPaint(size);
        }
    }

    private function doPaint(size: IntDimension) {
        updateSpriteScrollRect(size);
    }

    private inline function updateSpriteTransformationMatrix(x: Int, y: Int) {
        var pivot = if (null != rotationPivot) rotationPivot else new IntPoint(0,0);
        var matrix:Matrix = new Matrix();
        if (rotationAngle != 0.0) {
            matrix.translate(-pivot.x, -pivot.y);
            matrix.rotate((rotationAngle / 180) * Math.PI);
            matrix.translate(x + pivot.x, y + pivot.y);
        } else {
            matrix.translate(x, y);
        }
        sprite.transform.matrix = matrix;
    }

    private inline function updateSpriteScrollRect(size: IntDimension) {
        if (sprite.scrollRect != null) {
            var rect = sprite.scrollRect;

            rect.width = size.width;
            rect.height = size.height;

            sprite.scrollRect = rect;
        } else {
            sprite.scrollRect = new Rectangle(0, 0, size.width, size.height);
        }
    }

    public function repaint() {
        needsPaint = true;
        if (parent != null) parent.repaintChildren();
    }

    public function reposition() {
        if (parent != null) parent.repaintChildren();
    }

    /**
    * It's used by containers to get the size of a child.
    * The calcPreferredSize should be overriden by the children that
    * need a special way to calculate the size.
    **/

    public function getPreferredSize(?request: DimensionRequest): IntDimension {
        if (null == cachedPreferredSize) {
            cachedPreferredSize = calcPreferredSize(request);
        }
        return cachedPreferredSize;
    }

    @:dox("hide")
    @:noCompletion
    public function calcPreferredSize(request: DimensionRequest): IntDimension {
        return new IntDimension(this.absoluteWidth(), this.absoluteHeight());
    }

    @:dox("hide")
    @:noCompletion
    public function invalidatePreferredSize() {
        cachedPreferredSize = null;
        if (null != parent) parent.invalidatePreferredSize();
    }
}

typedef EventListenerInfo = {
    public var type:String;
    public var listener:Dynamic -> Void;
    public var useCapture:Bool;
}