/**
 * @author Joshua Granick
 * @author Andreas Rønning
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */


package tween.easing;



class Expo {
	
	public static inline function easeIn(start:Float, delta:Float, t:Float):Float {
		return t == 0 ? start : delta * Math.pow(2, 10 * (t - 1)) + start;
	}
	public static inline function easeOut(start:Float, delta:Float, t:Float):Float {
		return t == 1 ? start + delta : delta * (1 - Math.pow(2, -10 * t)) + start;
	}
	public static inline function easeInOut(start:Float, delta:Float, t:Float):Float {
		if (t == 0) {
			return start;
		}
		if (t == 1) {
			return start + delta;
		}
		if ((t / 2.0) < 1.0) {
			return delta / 2 * Math.pow(2, 10 * (t - 1)) + start;
		}
		return delta / 2 * (2 - Math.pow(2, -10 * --t)) + start;
	}	
}