/**
 * @author Joshua Granick
 * @author Zeh Fernando, Nate Chatellier
 * @author Andreas Rønning
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */


package tween.easing;
	
	
class Back {
	
	public static var DRIVE:Float = 1.70158;
	public static inline function easeIn(start:Float, delta:Float, t:Float):Float {
		return delta * t * t * ((DRIVE + 1) * t - DRIVE) + start;
	}
	public static inline function easeOut(start:Float, delta:Float, t:Float):Float {
		return delta * ((t -= 1) * t * ((DRIVE + 1) * t + DRIVE) + 1) + start;
	}
	public static inline function easeInOut(start:Float, delta:Float, t:Float):Float {
		var s = DRIVE * 1.525;
		if ((t*=2) < 1) return (delta * 0.5) * (t * t * (((s) + 1) * t - s)) + start;
		return (delta * 0.5) * ((t -= 2) * t * (((s) + 1) * t + s) + 2) + start;
	}	
}