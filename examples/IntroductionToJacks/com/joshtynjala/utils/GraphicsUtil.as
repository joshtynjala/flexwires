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
//  Contains modified third-party source code released under the following
//  license terms:
//
//  [Functions are] free to use as you see fit. They are free of charge or
//  obligation. I have endeavored to make these methods robust and useful,
//  however I can make no guarantees about their suitability to your specific
//  needs. I similarly make no guarantees that they are bug or problem free:
//  caveat emptor. 
//
//  Author: Ric Ewing (ric@formequalsfunction.com) with thanks to Robert Penner,
//  Eric Mueller and Michael Hurwicz for their contributions.
//
//  Source: http://www.adobe.com/devnet/flash/articles/adv_draw_methods.html
//
////////////////////////////////////////////////////////////////////////////////

package com.joshtynjala.utils
{
	import com.yahoo.astra.utils.GeomUtil;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	
	/**
	 * A collection of utility functions for manipulating Graphics objects.
	 * 
	 * @author Ric Ewing (ported to AS3 by Josh Tynjala)
	 */
	public class GraphicsUtil
	{
		/**
		 * Draws a regular or elliptical arc segment.
		 * 
		 * @param target		The Graphics object to which to draw
		 * @param centerX		x component of the arc's center point
		 * @param centerY		y component of the arc's center point
		 * @param startDegrees	Starting angle, in degrees.
		 * @param arc			Sweep of the arc. Negative values draw clockwise.
		 * @param radius		Radius of the arc. If the optional yRadius is defined, then radius is the x-axis radius.
		 * @param yRadius		Y-axis radius for arc.
		 */
		public static function drawArc(target:Graphics, centerX:Number, centerY:Number, startDegrees:Number, arcDegrees:Number, radius:Number, yRadius:Number = NaN):Point
		{
			if(isNaN(yRadius))
			{
				yRadius = radius;
			}
			
			// no sense in drawing more than is needed :)
			if(Math.abs(arcDegrees) > 360)
			{
				arcDegrees = 360;
			}
			
			// Flash uses 8 segments per circle, to match that, we draw in a maximum
			// of 45 degree segments. First we calculate how many segments are needed
			// for our arc.
			var segmentCount:int = Math.ceil(Math.abs(arcDegrees) / 45);
			
			// Now calculate the sweep of each segment
			// The math requires radians rather than degrees.
			var theta:Number = GeomUtil.degreesToRadians(arcDegrees / segmentCount);
			
			// convert angle startAngle to radians
			var currentAngle:Number = GeomUtil.degreesToRadians(startDegrees);
			
			// find our starting points (ax,ay) relative to the secified x,y
			var startX:Number = centerX + Math.cos(currentAngle) * radius;
			var startY:Number = centerY - Math.sin(currentAngle) * yRadius;
			
			target.moveTo(startX, startY);
			
			// if our arc is larger than 45 degrees, draw as 45 degree segments
			// so that we match Flash's native circle routines.
			if(segmentCount > 0)
			{
				// Loop for drawing arc segments
				for(var i:int = 0; i < segmentCount; i++)
				{
					// increment our angle
					currentAngle += theta;
					
					// find the angle halfway between the last angle and the new
					var angleMid:Number = currentAngle - (theta / 2);
					
					// calculate our end point
					var endX:Number = centerX + Math.cos(currentAngle) * radius;
					var endY:Number = centerY - Math.sin(currentAngle) * yRadius;
					
					// calculate our control point
					var controlX:Number = centerX + Math.cos(angleMid) * (radius / Math.cos(theta / 2));
					var controlY:Number = centerY - Math.sin(angleMid) * (yRadius / Math.cos(theta / 2));
					
					// draw the arc segment
					target.curveTo(controlX, controlY, endX, endY);
				}
			}
			// In the native draw methods the user must specify the end point
			// which means that they always know where they are ending at, but
			// here the endpoint is unknown unless the user calculates it on their 
			// own. Lets be nice and let save them the hassle by passing it back. 
			return new Point(endX, endY);
		}
		
		/**
		 * @private
		 * Draws a pie slice-shaped wedge.
		 * 
		 * @param target		The Graphics object to which to draw
		 * @param centerX		x component of the wedge's center point
		 * @param centerY		y component of the wedge's center point
		 * @param startDegrees	Starting angle, in degrees
		 * @param arc			Sweep of the wedge. Negative values draw clockwise.
		 * @param radius		Radius of the wedge. If the optional yRadius is defined, then radius is the x-axis radius.
		 * @param yRadius		The y-axis radius for wedge.
		 */
		public static function drawWedge(target:Graphics, centerX:Number, centerY:Number, startDegrees:Number, arc:Number, radius:Number, yRadius:Number = NaN):void
		{
			// move to x,y position
			target.moveTo(centerX, centerY);
			
			// if yRadius is undefined, yRadius = radius
			if(isNaN(yRadius))
			{
				yRadius = radius;
			}
			
			// limit sweep to reasonable numbers
			if(Math.abs(arc) > 360)
			{
				arc = 360;
			}
			
			// Flash uses 8 segments per circle, to match that, we draw in a maximum
			// of 45 degree segments. First we calculate how many segments are needed
			// for our arc.
			var segs:int = Math.ceil(Math.abs(arc) / 45);
			
			// Now calculate the sweep of each segment.
			var segAngle:Number = arc / segs;
			
			// The math requires radians rather than degrees. To convert from degrees
			// use the formula (degrees/180)*Math.PI to get radians.
			var theta:Number = -(segAngle / 180) * Math.PI;
			
			// convert angle startAngle to radians
			var angle:Number = -(startDegrees / 180) * Math.PI;
			
			// draw the curve in segments no larger than 45 degrees.
			if(segs > 0)
			{
				// draw a line from the center to the start of the curve
				var ax:Number = centerX + Math.cos(startDegrees / 180 * Math.PI) * radius;
				var ay:Number = centerY + Math.sin(-startDegrees / 180 * Math.PI) * yRadius;
				target.lineTo(ax, ay);
				
				// Loop for drawing curve segments
				for(var i:int = 0; i < segs; i++)
				{
					angle += theta;
					var angleMid:Number = angle - (theta / 2);
					var bx:Number = centerX + Math.cos(angle) * radius;
					var by:Number = centerY + Math.sin(angle) * yRadius;
					var cx:Number = centerX + Math.cos(angleMid) * (radius / Math.cos(theta / 2));
					var cy:Number = centerY + Math.sin(angleMid) * (yRadius / Math.cos(theta / 2));
					target.curveTo(cx, cy, bx, by);
				}
				// close the wedge by drawing a line to the center
				target.lineTo(centerX, centerY);
			}
		}
		
		/**
		 * Draws a dashed line between two points.
		 * 
		 * @param target	The Graphics object to which to draw
		 * @param xStart	The x position of the start of the line
		 * @param yStart	The y position of the start of the line
		 * @param xEnd		The x position of the end of the line
		 * @param yEnd		The y position of the end of the line
		 * @param dashSize	the size of dashes, in pixels
		 * @param gapSize	the size of gaps between dashes, in pixels
		 */
		public static function drawDashedLine(target:Graphics, xStart:Number, yStart:Number, xEnd:Number, yEnd:Number, dashSize:Number = 10, gapSize:Number = 10):void
		{
			// calculate the length of a segment
			var segmentLength:Number = dashSize + gapSize;
			
			// calculate the length of the dashed line
			var xDelta:Number = xEnd - xStart;
			var yDelta:Number = yEnd - yStart;
			var delta:Number = Math.sqrt(Math.pow(xDelta, 2) + Math.pow(yDelta, 2));
			
			// calculate the number of segments needed
			var segmentCount:int = Math.floor(Math.abs(delta / segmentLength));
			
			// get the angle of the line in radians
			var radians:Number = Math.atan2(yDelta, xDelta);
			
			// start the line here
			var xCurrent:Number = xStart;
			var yCurrent:Number = yStart;
			
			// add these to cx, cy to get next seg start
			xDelta = Math.cos(radians) * segmentLength;
			yDelta = Math.sin(radians) * segmentLength;
			
			// loop through each segment
			for(var i:int = 0; i < segmentCount; i++)
			{
				target.moveTo(xCurrent, yCurrent);
				target.lineTo(xCurrent + Math.cos(radians) * dashSize, yCurrent + Math.sin(radians) * dashSize);
				xCurrent += xDelta;
				yCurrent += yDelta;
			}
			
			// handle last segment as it is likely to be partial
			target.moveTo(xCurrent, yCurrent);
			delta = Math.sqrt((xEnd - xCurrent) * (xEnd - xCurrent) + (yEnd - yCurrent) * (yEnd - yCurrent));
			
			if(delta > dashSize)
			{
				// segment ends in the gap, so draw a full dash
				target.lineTo(xCurrent + Math.cos(radians) * dashSize, yCurrent + Math.sin(radians) * dashSize);
			}
			else if(delta > 0)
			{
				// segment is shorter than dash so only draw what is needed
				target.lineTo(xCurrent + Math.cos(radians) * delta, yCurrent + Math.sin(radians) * delta);
			}
			
			// move the pen to the end position
			target.moveTo(xEnd, yEnd);
		}
		
		/**
		 * Draws a regular polygon with the specified number of sides. Negative
		 * values for sideCount will draw the polygon in the reverse direction,
		 * which allows for creating knock-outs in masks.
		 * 
		 * @param target		The Graphics object to which to draw.
		 * @param centerX		x component of the polygon's center point.
		 * @param centerY		y component of the polygon's center point.
		 * @param sideCount		The number of sides on the polygon, must be greater than two.
		 * @param radius		The radius of the points of the polygon from the center.
		 * @param startDegrees	The starting angle from which to draw, in degrees.
		 */
		public static function drawPolygon(target:Graphics, centerX:Number, centerY:Number, sideCount:int, radius:Number, startDegrees:Number = 0):void
		{
			// convert sides to positive value
			var count:int = Math.abs(sideCount);
			
			// check that count is sufficient to build polygon
			if(count <= 2)
			{
				throw new ArgumentError("Cannot draw a polygon with fewer than three sides.");
			}
			
			// calculate span of sides
			var step:Number = (Math.PI * 2) / sideCount;
			
			// calculate starting angle in radians
			var startDegrees:Number = (startDegrees / 180) * Math.PI;
			
			var startX:Number = centerX + (Math.cos(startDegrees) * radius);
			var startY:Number = centerY - (Math.sin(startDegrees) * radius);
			target.moveTo(startX, startY);
			
			// draw the polygon
			for(var i:int = 1; i <= count; i++)
			{
				var currentX:Number = centerX + Math.cos(startDegrees + (step * i)) * radius;
				var currentY:Number = centerY - Math.sin(startDegrees + (step * i)) * radius;
				target.lineTo(currentX, currentY);
			}
		}
		
		/**
		 * Draws a star-shaped polygon. Note that the stars by default 'point'
		 * to the right. This is because the method starts drawing at 0 degrees
		 * by default, putting the first point to the right of center. Using
		 * negative values for the pointCount draws the star in reverse
		 * direction, allowing for knock-outs when used as part of a mask.
		 * 
		 * @param target		The Graphics object to which to draw.
		 * @param centerX		x component of the polygon's center point.
		 * @param centerY		y component of the polygon's center point.
		 * @param pointCount	The number of points on the star, must be greater than two.
		 * @param innerRadius	The radius of the indent of the points from the center.
		 * @param outerRadius	The radius of the tips of the points from the center.
		 * @param startDegrees	The starting angle from which to draw, in degrees.
		 */
		public static function drawStar(target:Graphics, centerX:Number, centerY:Number, pointCount:int, innerRadius:Number, outerRadius:Number, startDegrees:Number = 0):void
		{
			var count:int = Math.abs(pointCount);
			
			if(count <= 2)
			{
				throw new ArgumentError("Cannot draw a star with fewer than three points.");
			}
				
			// calculate distance between points
			var step:Number = (Math.PI * 2) / pointCount;
			var halfStep:Number = step / 2;
			
			// calculate starting angle in radians
			var startRadians:Number = (startDegrees/180)*Math.PI;
			
			var startX:Number = centerX + (Math.cos(startRadians) * outerRadius);
			var startY:Number = centerY - (Math.sin(startRadians) * outerRadius); 
			target.moveTo(startX, startY);
			
			for(var i:int = 1; i <= count; i++)
			{
				var currentX:Number = centerX + Math.cos(startRadians + (step * i) - halfStep) * innerRadius;
				var currentY:Number = centerY - Math.sin(startRadians + (step * i) - halfStep) * innerRadius;
				target.lineTo(currentX, currentY);
				
				currentX = centerX + Math.cos(startRadians + (step * i)) * outerRadius;
				currentY = centerY - Math.sin(startRadians + (step * i)) * outerRadius;
				target.lineTo(currentX, currentY);
			}
		}
		
		/**
		 * Draws a gear, a cog with teeth and a hole in the middle where an axle
		 * may be placed.
		 * 
		 * @param target		The Graphics object to which to draw.
		 * @param centerX		x component of the gear's center point.
		 * @param centerY		y component of the gear's center point.
		 * @param sideCount		The number of "teeth" on the gear, must be greater than two.
		 * @param innerRadius	The radius of the indent of the points from the center.
		 * @param outerRadius	The radius of the tips of the points from the center.
		 * @param startDegrees	The starting angle from which to draw, in degrees.
		 * @param holeSides		The number of sides to the polygonal hole in the middle of the gear. Must be greater than two.
		 */
		public static function drawGear(target:Graphics, centerX:Number, centerY:Number, sideCount:int, innerRadius:Number, outerRadius:Number, startDegrees:Number, holeSideCount:int = 0, holeRadius:Number = NaN):void
		{
			if(sideCount <= 2)
			{
				throw new ArgumentError("Cannot draw a gear with fewer than three teeth.");
			}
			
			// calculate length of sides
			var step:Number = (Math.PI * 2) / sideCount;
			var quarterStep:Number = step / 4;
			
			// calculate starting angle in radians
			var startRadians:Number = (startDegrees / 180) * Math.PI;
			
			var startX:Number = centerX + (Math.cos(startRadians) * outerRadius);
			var startY:Number = centerY - (Math.sin(startRadians) * outerRadius); 
			target.moveTo(startX, startY);
			
			// draw lines
			for(var i:int = 1; i <= sideCount; i++)
			{
				var currentX:Number = centerX + Math.cos(startRadians + (step * i) - (quarterStep * 3)) * innerRadius;
				var currentY:Number = centerY - Math.sin(startRadians + (step * i) - (quarterStep * 3)) * innerRadius;
				target.lineTo(currentX, currentY);
				
				currentX = centerX + Math.cos(startRadians + (step * i) - (quarterStep * 2)) * innerRadius;
				currentY = centerY - Math.sin(startRadians + (step * i) - (quarterStep * 2)) * innerRadius;
				target.lineTo(currentX, currentY);
				
				currentX = centerX + Math.cos(startRadians + (step * i) - quarterStep) * outerRadius;
				currentY = centerY - Math.sin(startRadians + (step * i) - quarterStep) * outerRadius;
				target.lineTo(currentX, currentY);
				
				currentX = centerX + Math.cos(startRadians + (step * i)) * outerRadius;
				currentY = centerY - Math.sin(startRadians + (step * i)) * outerRadius;
				target.lineTo(currentX, currentY);
			}
			
			if(holeSideCount > 2)
			{
				if(isNaN(holeRadius))
				{
					holeRadius = innerRadius / 3;
				}
				
				drawPolygon(target, centerX, centerY, holeSideCount, holeRadius, startDegrees);
			}
		}
		
		/**
		 * Draws a star-like burst.
		 * 
		 * @param target		The Graphics object to which to draw.
		 * @param centerX		x component of the burst's center point.
		 * @param centerY		y component of the burst's center point.
		 * @param pointCount	The number of points on the burst, must be greater than two.
		 * @param innerRadius	The radius of the indent of the points from the center.
		 * @param outerRadius	The radius of the tips of the points from the center.
		 * @param startDegrees	The starting angle from which to draw, in degrees.
		 */
		public static function drawBurst(target:Graphics, x:Number, y:Number, pointCount:int, innerRadius:Number, outerRadius:Number, startDegrees:Number):void
		{
			if(pointCount <= 2)
			{
				throw new ArgumentError("Cannot draw a burst with fewer than three points.");
			}
			
			// calculate length of sides
			var step:Number = (Math.PI * 2) / pointCount;
			var halfStep:Number = step / 2;
			var quarterStep:Number = step / 4;
			
			// calculate starting angle in radians
			var startRadians:Number = (startDegrees / 180) * Math.PI;
			var startX:Number = x + (Math.cos(startRadians) * outerRadius);
			var startY:Number = y - (Math.sin(startRadians) * outerRadius);
			target.moveTo(startX, startY);
			
			// draw curves
			for(var i:int = 1; i <= pointCount; i++)
			{
				var currentControlX:Number = x + Math.cos(startRadians + (step * i) - (quarterStep * 3)) * (innerRadius / Math.cos(quarterStep));
				var currentControlY:Number = y - Math.sin(startRadians + (step * i) - (quarterStep * 3)) * (innerRadius / Math.cos(quarterStep));
				var controlX:Number = x + Math.cos(startRadians + (step * i) - halfStep) * innerRadius;
				var controlY:Number = y - Math.sin(startRadians + (step * i) - halfStep) * innerRadius;
				target.curveTo(currentControlX, currentControlY, controlX, controlY);
				
				currentControlX = x + Math.cos(startRadians + (step * i) - quarterStep) * (innerRadius / Math.cos(quarterStep));
				currentControlY = y - Math.sin(startRadians + (step * i) - quarterStep) * (innerRadius / Math.cos(quarterStep));
				controlX = x + Math.cos(startRadians + (step * i)) * outerRadius;
				controlY = y - Math.sin(startRadians + (step * i)) * outerRadius;
				target.curveTo(currentControlX, currentControlY, controlX, controlY);
			}
		}

	}
}