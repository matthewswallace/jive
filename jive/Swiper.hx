package jive;

import jive.geom.Metric;
import jive.geom.IntDimension;
import jive.geom.MetricDimension;
import jive.gestures.Gestures;
import jive.gestures.PanGesture;
import jive.gestures.SwipeGesture;
import jive.gestures.core.Gesture;
import jive.gestures.core.GestureState;
import jive.gestures.core.Touch;
import jive.gestures.events.GestureEvent;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.display.Sprite;

import motion.Actuate;
import motion.actuators.IGenericActuator;


using jive.geom.MetricHelper;

class Swiper extends ScrolledContainer {
    private var currentIndex: Int;
    private var isHolded: Bool;
    private var prevX: Float;
    private var initX: Float;
    private var gestures: Gestures;
    private var pan: PanGesture;
    private var swipe:SwipeGesture;

    // for debug 
    private static var GAP:Int = 100;
    private var pool:Array<Component>;
    private var actuator: IGenericActuator;
    private var isInAnimationProcess:Bool;

    public function new() {
        super();

        Gestures.init();

        pool = new Array<Component>();

        currentIndex = 0;

        isInAnimationProcess = false;

        pan = new PanGesture(this);
        pan.direction = PanGesture.HORIZONTAL;
        pan.gesturesShouldRecognizeSimultaneously = panShouldRecognizeSimultaneously;

        pan.name = 'swiperPan';

        swipe = new SwipeGesture(this);
        swipe.direction = SwipeGesture.HORIZONTAL;
        swipe.gesturesShouldRecognizeSimultaneously = swipeShouldRecognizeSimultaneously;

        swipe.name = 'swiperSwipe';


        // addEventListener(MouseEvent.MOUSE_DOWN, touchDownHandler);
        /*addEventListener(MouseEvent.MOUSE_MOVE, touchMoveHandler);
        addEventListener(MouseEvent.MOUSE_UP, touchUpHandler);
        addEventListener(MouseEvent.MOUSE_OUT, touchUpHandler);*/

        pan.addEventListener(GestureEvent.GESTURE_BEGAN, function(event:GestureEvent){
            // trace('stop animation');
            Actuate.stop(actuator);
            //onPan(event);
        });
        pan.addEventListener(GestureEvent.GESTURE_CHANGED, onPan);
        pan.addEventListener(GestureEvent.GESTURE_ENDED, onPanEnded);
        // pan.addEventListener(GestureEvent.GESTURE_FAILED, onPan);
        // pan.addEventListener(GestureEvent.GESTURE_CANCELLED, onPan);

        swipe.addEventListener(GestureEvent.GESTURE_RECOGNIZED, onSwipe);

        //swipe.addEventListener(GestureEvent.GESTURE_FAILED, onSwipeFailed);
        //swipe.addEventListener(GestureEvent.GESTURE_ENDED, onSwipeFailed);
        //swipe.addEventListener(GestureEvent.GESTURE_CANCELLED, onSwipeFailed);
    }

    function onPan(event:GestureEvent) 
    {
        // var i = 0;
        // var current = children.get(currentIndex);

        // displayObject.scrollRect =new Rectangle(displayObject.scrollRect.x - pan.offsetX, 0, absoluteWidth, absoluteHeight);

        displayObjectContainer.x += pan.offsetX;

        
        // if ( current.absoluteX + pan.offsetX > - absoluteWidth / 3  && current.absoluteX + pan.offsetX < 2 * absoluteWidth / 3 ) 
        //for (c in pool) {
        // trace('onPan = ' + event.newState);

        /*for(d in [-1, 0, 1]) {
            var c = children.get(currentIndex + d);
            if (c != null) {
                c.x = Metric.absolute(Std.int(c.absoluteX + pan.offsetX));
            }
        }*/



            // trace('Child ' + (++i) + ':' + Std.int(c.absoluteX + pan.offsetX));
        //}
    }

    function onPanEnded(event:GestureEvent) {
        // trace('pan ended, currentIndex = $currentIndex');
        if (!isInAnimationProcess) {
            var index = currentIndex;
            // var current = children.get(currentIndex);        
            // // sync changes
            // if (current.absoluteX <= -absoluteWidth / 3 ){
            //     // to right
            //     if(currentIndex < children.length - 1)
            //         currentIndex ++ ;
            // } else if (current.absoluteX >= absoluteWidth / 3) {
            //     // to left
            //     if(currentIndex > 0)
            //         currentIndex -- ;
            // } 
            if (displayObjectContainer.x <= - absoluteWidth / 3 - currentIndex * absoluteWidth){
                // to right
                if(currentIndex < children.length - 1)
                    currentIndex ++ ;
            } else if (displayObjectContainer.x >= absoluteWidth / 3 - currentIndex * absoluteWidth) {
                // to left
                if(currentIndex > 0)
                    currentIndex -- ;
            } 
            animate(index);
        }
    }

    function onSwipe(event:GestureEvent)
    {
        // trace("swipe! " + swipe.offsetX);
        if (!isInAnimationProcess){
            var index = currentIndex;
            if (swipe.offsetX < 0) {
                // to right
                if(currentIndex < children.length - 1)
                    currentIndex ++ ;
            } else {
                // to right
                if(currentIndex > 0)
                    currentIndex -- ;
            }
            animate(index);
        }
        //TweenMax.to(menu, 1, {bezierThrough:[{scaleX:2}, {scaleX:1}]});
    }

    function animate(index: Int) {

        // Actuate.stop(actuator);

        // trace('index=$index, currentIndex=$currentIndex');
        
        var ci = currentIndex; // closure

        var current = children.get(index);
        var animation = {
            // x: current.absoluteX 
            x: displayObjectContainer.x
        };

        isInAnimationProcess = true;

        actuator = Actuate.tween(animation, 0.6, {
            // x: (index - ci) * absoluteWidth
            x: - ci * absoluteWidth
        }).onUpdate(function(){
            /*for(d in [-1,0,1]) {
                var c = children.get(index + d);
                if (c != null)
                    c.x = Metric.absolute(Std.int(animation.x + d * absoluteWidth));
            }*/
            // displayObject.scrollRect = new Rectangle(animation.x, 0, absoluteWidth, absoluteHeight);
            displayObjectContainer.x = animation.x;
            // .x = Std.int(animation.x);
        }).onComplete(function(){

            isInAnimationProcess = false;

            actuator = null;

            // trace('animation completed');
            if (ci < index) {
                // to left 
                var c = children.get(index+1);
                if (c != null)
                    displayObjectContainer.removeChild(c.displayObject);
                    
                if (ci > 0) {
                    var target = children.get(ci - 1);
                    displayObjectContainer.addChild(target.displayObject);
                    target.repaint();
                }
            } else if (ci > index) {
                // to right

                var c = children.get(index-1);
                if (c != null)
                    displayObjectContainer.removeChild(c.displayObject);

                if (ci < children.length - 1) {
                    var target = children.get(ci + 1);
                    displayObjectContainer.addChild(target.displayObject);
                    target.repaint();
                }
            }

        });
    }

    //----------------------------------
    // Begin of IGestureDelegate implementation
    //----------------------------------
    public function swipeShouldRecognizeSimultaneously(gesture:Gesture, otherGesture:Gesture):Bool
    {
        return otherGesture == pan;
    }
    public function panShouldRecognizeSimultaneously(gesture:Gesture, otherGesture:Gesture):Bool
    {
        return otherGesture == swipe;
    }
    //----------------------------------
    // End of IGestureDelegate implementation
    //----------------------------------

    private function touchDownHandler(event:MouseEvent) {
        // Actuate.stop(actuator);
        if (!isHolded) {
            initX = event.localX;
            prevX = event.localX;
            isHolded = true;
        }
    }

    override public function append(child: Component) {
        child.width = Metric.percent(100);
        child.height = Metric.percent(100);
        child.x = Metric.percent(GAP * children.length);
        //child.margin.left = children.length > 0 ? Metric.absolute(1) : Metric.absolute(0);
                    
        // if (currentIndex == 0 && children.length == 0) {
        // displayObjectContainer.addChild(child.displayObject);
        // trace('First added');
        // }
        //if (children.length - 1 == currentIndex) {
            // child.x = Metric.percent(GAP);
        // }

        children.add(child);
        // if (children.length - 1 >= currentIndex - 1 && children.length - 1 <= currentIndex + 1)
           //  displayObjectContainer.addChild(child.displayObject);
        child.parent = this;
        child.repaint();

        //childrenNeedRepaint = true;
        layoutChildren();
    }

    private function layoutChildren() {

        for (d in [-1, 1, 0]) {
            var target = children.get(currentIndex + d);
            if (null != target && displayObjectContainer.getChildIndex(target.displayObject) < 0) {
                displayObjectContainer.addChild(target.displayObject);
            }
        }
    }

    /**
    * paints only previous, current and next children
    * isn't used standart paint method of children cause
    * custom coordinates are necessary
    **/

    override public function paint(size: IntDimension):IntDimension {
        var np = needsPaint;
        

        var result = super.processPaint(size);


        // for debug ? make for every component
        if (np) {
            displayObjectContainer.graphics.beginFill(0x009900, 0.2);
            displayObjectContainer.graphics.drawRect(0, 0, absoluteWidth, absoluteHeight);
            displayObjectContainer.graphics.endFill();
        }

        if (childrenNeedRepaint) {
            childrenNeedRepaint = false;
            for (d in [-1, 1, 0]) {
                var target = children.get(currentIndex + d);
                if (null != target) {
                    if ( d == 0 ) {
                        displayObjectContainer.setChildIndex(target.displayObject, 0);
                    }
                    target.paint(calcPaintDimension(size));
                }
            }
        }

        // if (childrenNeedRepaint) {
        //     childrenNeedRepaint = false;

        //     for (d in [-1, 0, 1]) {
        //         var target = children.get(currentIndex + d);
        //         if (null != target) {
        //             target.x = Metric.percent(d * GAP);
        //             target.paint(calcPaintDimension(size));
        //         }

        //     }
        // }

        return result;
    }
}