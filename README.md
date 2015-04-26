delta
=====

Game-focused Tweening library for Haxe 3

Primary purpose is simply to have better control of timing issues.
Secondary goals are syntactic: Provide a nice quick way to control and synchronize animations of float properties.

Inspired, of course, by the standards, TweenLite and Actuate. Tween functions adapted from Actuate's adaptions of [The Classics](http://www.robertpenner.com/easing/). 

Key API difference from Actuate is Delta defines "a tween" as a linked list of Tween actions, which is consumed action by action until the full list is empty. This means tweens are inherently sequenced, allowing the rapid creaton of sequences of tweens. It also allows for some synchronization, such as one tween sequence waiting for a trigger ID before proceeding, which can be dispatched either from another tween sequence, or from Delta itself.

Ease functions are simplified to the signature `Float->Float->Float->Float`...

```haxe
Delta.tween(myObject).ease( function(startValue:Float, deltaValue:Float, t:Float):Float
```
... where `startValue` is the initial value, `deltaValue` is the difference between the start value and the target value, and `t` is a scalar between 0 and 1.

```haxe
package ;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import tween.Delta;
import tween.easing.Quad;
import tween.easing.Sine;
import tween.utils.Stopwatch;

class Main extends Sprite 
{
	var obj1:Sprite;
	var obj2:Sprite;
	public function new() 
	{
	    super();
	    
	    obj1 = new Sprite();
	    obj1.graphics.beginFill(0xFF0000);
	    obj1.graphics.drawRect(0, 0, 50, 50);
	    obj2 = new Sprite();
	    obj2.graphics.beginFill(0x00FF00);
	    obj2.graphics.drawRect(0, 0, 50, 50);
	    obj2.x = 400;
	    
	    addChild(obj1);
	    addChild(obj2);
	    
	    Delta.tween(obj1) //Begin a tween with obj1
	        .wait(1.0) //Wait for 1 second
	        .prop("x", 50, 1.0) //Tween x to 50 over 1 second
	        .prop("y", 50, 1.0).ease(Sine.easeInOut, false) //Do the same with y, but apply a sine ease to *that component* of the tween
	        .wait(1.0) //Wait another second
	        .tween(obj2) //Create another tween target
	        .propMultiple( { x:0, y:0 }, 0.5) //Tween both x and y to 0 over .5 seconds
	        .ease(Quad.easeOut) //Apply a Quad ease to all components of that ease (so far)
	        .onComplete(function() { trace("Done");  } ); //Finally report completion
	    
	    addEventListener(Event.ENTER_FRAME, update);
	}
	
	private function update(e:Event):Void 
	{
	    Delta.step(Stopwatch.tock()); //Update the tween engine with a delta in seconds using the stopwatch util
	    
	    Stopwatch.tick(); //Store frame time for next tock
	}
	
	static function main() 
	{
	    Lib.current.addChild(new Main());
	}
}
```
