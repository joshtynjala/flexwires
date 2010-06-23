////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2008 Josh Tynjala
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to 
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

package com.joshtynjala.utils
{
	import flash.geom.Point;

	/**
	 * A collection of utility functions for manipulating Point objects.
	 * 
	 * @author Josh Tynjala (joshblog.net)
	 */
	public class PointUtil
	{	
		/**
		 * Reverses a point around the origin. Same as a performing a scalar
		 * multiplication of -1 on the point.
		 * 
		 * @param v		The point to reverse. Does not alter this value.
		 * @return		The reversed point.
		 */
		public static function reverse(v:Point):Point
		{
			return new Point(-v.x, -v.y);
		}
		
		/**
		 * Performs scalar multiplication on a point.
		 */
		public static function scalarMultiply(v:Point, s:Number):Point
		{
			return new Point(v.x * s, v.y * s);	
		}
		
		/**
		 * Performs scalar division on a point.
		 */
		public static function scalarDivide(v:Point, s:Number):Point
		{
			return new Point(v.x / s, v.y / s);
		}
		
		/**
		 * Calculates the dot product of two points.
		 */
		public static function dotProduct(u:Point, v:Point):Number
		{
			return (u.x * v.x) + (u.y * v.y);
		}
		
		/**
		 * Rotates a point around the origin.
		 * 
		 * @param u					The point to rotate.
		 * @param angleRadians		The angle at which to rotate (in radians).
		 * @return					The rotated point.
		 */
		public static function rotate(u:Point, angleRadians:Number):Point
		{
			var v:Point = new Point();
			v.x = u.x * Math.cos(angleRadians) + u.y * Math.sin(angleRadians);
			v.y = -u.x * Math.sin(angleRadians) + u.y * Math.cos(angleRadians);
			return v;
		}
		
		/**
		 * Calculates the angle between two points.
		 * 
		 * @param origin	the first point
		 * @param target	the second point
		 * @return			the angle in radians 
		 */
		public static function angle(origin:Point, target:Point):Number
		{
			var dx:Number = target.x - origin.x;
			var dy:Number = target.y - origin.y;
			return Math.atan2(dy, dx);
		}
	}
}