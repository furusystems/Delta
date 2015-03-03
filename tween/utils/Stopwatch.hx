package tween.utils;

/**
 * Simple stopwatch. Tick first, then tock to get the delta.
 * @author Andreas Rønning
 */
class Stopwatch
{
	static var sample:Float = 0.0;
	public static var time:Float = 0.0;
	public static var delta:Float;
	public static inline function tick():Void {
		sample = getTime();
	}
	public static inline function tock():Float {
		delta = getTime() - sample;
		time += delta;
		return delta;
	}
	static inline function getTime():Float {
		#if flash
		return flash.Lib.getTimer() * 0.001;
		#elseif cpp
		return haxe.Timer.stamp();
		#else
		return 0.0;
		#end
	}
}