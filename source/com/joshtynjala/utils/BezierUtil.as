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
//
//  Contains third-party source code released with the same license terms
//  that appear above with the following copyright notice:
//
//  Copyright (c) 2008 nicolas levavasseur (nicolas.levavasseur@gmail.com)
//
//  Source: http://code.google.com/p/beziercurve/
//
////////////////////////////////////////////////////////////////////////////////

package com.joshtynjala.utils
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	/**
	 * Utility functions used for drawing bezier curves.
	 * 
	 * @author Nicolas Levavasseur (with tweaks by Josh Tynjala)
	 */
	public class BezierUtil
	{
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		/**
		 * Draws a bezier curve.
		 * 
		 * @param graphics		The Graphics object to which to draw the curve.
		 * @param start			The point at which to begin drawing.
		 * @param end			The point at which to end drawing.
		 * @param controls		The control points of the curve.
		 * @param precision		The number of line segments to use to draw the curve.
		 */
		public static function drawBezierCurve(graphics:Graphics, start:Point, end:Point, controls:Vector.<Point>, precision:int):void
		{
			var points:Vector.<Point> = controls.concat();
			points.unshift(start);
			points.push(end);
			
			var knotVector:Vector.<Number> = createKnotVector(precision);
			var knotVectorLength:int = knotVector.length;
			var bezierPoint:Point = new Point();
			for(var i:int = 0; i < knotVectorLength; i++)
			{
				bezierPoint.x = 0;
				bezierPoint.y = 0;
				var p:Point = getBezierPoint(bezierPoint, knotVector[i], points);
				if(i == 0)
				{
					graphics.moveTo(p.x, p.y);
				}
				else
				{
					graphics.lineTo(p.x, p.y);
				}
			}
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		/**
		 * @private
		 * Generates a knot vector.
		 */
		private static function createKnotVector(precision:int):Vector.<Number>
		{
			var result:Vector.<Number> = new <Number>[];
			for(var i:int = 0; i <= precision; i++){
				//T.push(i / precision);
				//T.push((i / precision) * (i / precision));
				result.push(Math.pow(i / precision, 1.01));
			}
			return result;
		}
		
		/**
		 * @private
		 * Gets a point for the next line segment.
		 */
		private static function getBezierPoint(bezierPoint:Point, knotValue:Number, points:Vector.<Point>):Point
		{
			var pointCount:int = points.length;
			for(var i:int = 0; i < pointCount; i++)
			{
				var r:Number = MathUtil.binomialCoefficient(pointCount - 1, i) * Math.pow(1 - knotValue, pointCount - 1 - i) * Math.pow(knotValue, i);
				var p:Point = points[i];
				bezierPoint = bezierPoint.add(PointUtil.scalarMultiply(p, r));
			}
			return bezierPoint;
		}

	}
}