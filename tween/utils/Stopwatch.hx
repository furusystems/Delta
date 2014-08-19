package tween.utils;

/**
 * ...
 * @author Andreas Rønning
 */
class Stopwatch
{
	static var time:Float = 0.0;
	public static inline function tick():Void {
		time = getTime();
	}
	public static inline function tock():Float {
		return getTime() - time;
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