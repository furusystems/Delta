package tween;
import tween.easing.Linear;

/**
 * ...
 * @author Andreas Rønning
 */

private typedef TweenFunc = Float->Float->Float->Float;

private class PropertyTween {
	public var tween:Tween;
	public var duration:Float;
	public var durationR:Float;
	public var time:Float;
	public var isProperty:Bool;
	public var from:Float;
	public var to:Float;
	public var difference:Float;
	public var current:Float;
	public var tweenFunc:TweenFunc;
	public var complete:Bool;
	public var name:String;
	var hasUpdated:Bool;
	
	#if release inline #end 
	public function new(tween:Tween, name:String, to:Float, duration:Float) {
		tweenFunc = Delta.defaultTweenFunc;
		this.duration = duration;
		this.durationR = 1 / duration;
		this.tween = tween;
		this.to = to;
		this.name = name;
		time = 0.0;
	}
	public inline function init() {
		if(!hasUpdated){
			from = Reflect.getProperty(tween.target, name);
			difference = to - from;
			hasUpdated = true;
		}
	}
	
	#if release inline #end 
	public function step(delta:Float) {
		init();
		time += delta;
		var c = current;
		if (time > duration) {
			time = duration;
			c = from + difference;
			complete = true;
		}else {
			var rt = Math.max(0, time);
			c = tweenFunc(from, difference, time * durationR);
		}
		apply(c);
	}
	
	#if release inline #end
	function apply(val:Float) 
	{
		if (val != current) {
			Reflect.setProperty(tween.target, name, current = val);
		}
	}
}

private class Tween {
	var prev:Null<Tween>;
	var next:Null<Tween>;
	var properties:Null<Map<String, PropertyTween>>;
	var time:Float;
	var totalDuration:Float;
	var prevPropCreated:Null<PropertyTween>;
	var onCompleteFunc:Null<Void->Void>;
	public var target:Dynamic;
	public function new(target:Dynamic) {
		time = totalDuration = 0.0;
		this.target = target;
	}
	
	
	#if release inline #end 
	function append(t:Tween):Tween {
		next = t;
		t.prev = this;
		return t;
	}
	#if release inline #end 
	function remove() {
		if (prev != null) {
			prev.next = next;
		}
		if (next != null) {
			next.prev = prev;
		}
	}
	
	public inline function onComplete(func:Void->Void):Tween {
		onCompleteFunc = func;
		return this;
	}
	
	public inline function ease(func:Float->Float->Float->Float, all:Bool = true):Tween {
		if (all) {
			for (p in properties) p.tweenFunc = func;
		}else {
			if (prevPropCreated != null ) prevPropCreated.tweenFunc = func;
		}
		return this;
	}
	
	#if release inline #end 
	public function wait(duration:Float):Tween {
		var step = createStep();
		step.totalDuration = duration;
		return step.createStep();
	}
	
	#if release inline #end 
	public function createStep():Tween {
		return append(new Tween(target));
	}
	
	#if release inline #end 
	public function tween(target:Dynamic):Tween {
		return append(new Tween(target));
	}
	
	#if release inline #end 
	public function prop(property:String, value:Float, duration:Float):Tween {
		
		if(properties==null) properties = new Map<String,PropertyTween>();
		#if debug
			if (!Reflect.hasField(target, property)) throw 'No property "$property" on object';
			//TODO: Check if the field is a property or not and if so, warn
		#end
		totalDuration = Math.max(totalDuration, duration);
		properties.set(property, prevPropCreated = new PropertyTween(this, property, value, duration));
		return this;
	}
	
	#if release inline #end 
	public function propMultiple(properties:Dynamic, duration:Float):Tween {
		for (p in Reflect.fields(properties)) {
			prop(p, Reflect.getProperty(properties, p), duration);
		}
		return this;
	}
	
	/**
	 * Complete this node's properties and proceed to the next one
	 * @param	ffwd
	 */
	public function skip(ffwd:Bool) {
		for (p in properties) {
			Reflect.setProperty(target, p.name, p.to);
		}
		time = totalDuration;
		finish();
	}
	
	inline function finish() 
	{
		if (onCompleteFunc != null) onCompleteFunc();
		remove();
	}
	
	public function abort():Void {
		getSequence().abort();
	}
	
	public function getSequence():TweenSequence {
		var n = prev;
		while (n != null) {
			if (n.prev == null) return cast n;
			n = n.prev;
		}
		return null;
	}
	
	public function step(delta:Float):Tween {
		var allComplete:Bool = true;
		if (properties != null) {
			for (p in properties) {
				p.step(delta);
				if (!p.complete) allComplete = false;
			}
		}
		time += delta;
		if (time >= totalDuration) {
			finish();
		}
		return this;
	}
}

private class TweenSequence extends Tween {
	public var complete:Bool;
	public function new(target:Dynamic) {
		super(target);
	}
	override public function step(delta:Float):Tween {
		if (complete) return this;
		if (next == null) {
			complete = true;
		}else {
			next.step(delta);
		}
		return this;
	}
	
	public function removeTweensOf(target:Dynamic) {
		var removeList:Array<Tween> = [];
		var c = next;
		while (c != null) {
			if (c.target == target) {
				removeList.push(c);
			}
			c = c.next;
		}
		for (t in removeList) {
			t.remove();
		}
	}
	
	override public function abort():Void {
		complete = true;
	}
	
	public function skipCurrent() {
		if (next != null) next.skip(true);
	}
	public function length():Int {
		var i = 0;
		var n = next;
		while (n != null) {
			i++;
			n = n.next;
		}
		return i;
	}
}

class Delta
{
	function new() { }
	
	static var sequences:Array<TweenSequence> = [];
	public static var timeScale:Float = 1.0;
	public static var defaultTweenFunc:TweenFunc = Linear.none;
	static var count:Int = 0;
	
	#if release inline #end 
	static function createSequence(target:Dynamic):TweenSequence {
		var s = new TweenSequence(target); 
		sequences.push(s);
		return s;
	}
	
	public static function tween(target:Dynamic):Tween {
		return createSequence(target).createStep();
	}
	
	public static function delayCall(func:Void->Void, interval:Float):Tween {
		return createSequence(null).wait(interval).onComplete(func);
	}
	
	public static function removeTweensOf(target:Dynamic) {
		for (s in sequences) {
			s.removeTweensOf(target);
		}
	}

	public static function step(delta:Float) {
		delta *= timeScale;
		var n = sequences.length;
		while (n-->0) {
			var s = sequences[n];
			s.step(delta);
		}
		count++;
		//Clean up every 60 frames
		if (count > 60) {
			count = 0;
			n = sequences.length;
			while (n-->0) {
				var s = sequences[n];
				if (s.complete) {
					sequences.splice(n, 1);
				}
			}
		}
	}
	
}