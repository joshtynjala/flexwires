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

package com.flextoolbox.controls.wireClasses
{
	import com.joshtynjala.utils.BezierUtil;
	import com.yahoo.astra.utils.DisplayObjectUtil;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;

	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	[Style(name="fillColor",type="uint")]
	[Style(name="borderColor",type="uint")]
	[Style(name="thickness",type="Number")]
	[Style(name="bezierPrecision",type="Number")]
	[Style(name="disconnectCursorSkin",type="Class")]
	
	/**
	 * A simple wire renderer that uses bezier curves to draw a line between two
	 * jacks.
	 * 
	 * @author Josh Tynjala (joshblog.net)
	 */
	public class DefaultWireRenderer extends BaseWireRenderer
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function DefaultWireRenderer()
		{
			super();
			
			this.addEventListener(MouseEvent.CLICK, clickHandler);
			this.addEventListener(MouseEvent.ROLL_OVER, wireRollOverHandler);
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		private var _disconnectCursorID:int;
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			this.graphics.clear();
			
			if(!this.jack1 || !this.jack2)
			{
				return;
			}
			
			var start:Point = new Point(this.jack1.width / 2, this.jack1.height / 2);
			start = DisplayObjectUtil.localToLocal(start, jack1, this);
			var end:Point = new Point(this.jack2.width / 2, this.jack2.height / 2);
			end = DisplayObjectUtil.localToLocal(end, jack2, this);
			
			var angle1:Number = this.jack1.connectionAngle;
			var angle2:Number = this.jack2.connectionAngle;
			
			var minX:Number = Math.min(start.x, end.x);
			var maxX:Number = Math.max(start.x, end.x);
			var minY:Number = Math.min(start.y, end.y);
			var maxY:Number = Math.max(start.y, end.y);
			var middle:Point = new Point(minX + (maxX - minX) / 2, minY + (maxY - minY) / 2);
			
			var c1:Point = new Point(middle.x, minY);
			var c2:Point = new Point(middle.x, maxY);
			
			//curve always starts from top
			if(minY != start.y)
			{
				var temp:Point = start;
				start = end;
				end = temp;
				
				var temp2:Number = angle1;
				angle1 = angle2;
				angle2 = temp2;
			}
			
			var distance:Number = Math.min(100, Point.distance(start, end) / 2);
			
			var controlPoints:Vector.<Point> = new <Point>[c1, c2];
			if(!isNaN(angle1))
			{
				var d1:Point = Point.polar(distance, angle1 * Math.PI / 180);
				d1.y *= -1;
				d1 = d1.add(start);
				if(d1.x == c1.x)
				{
					c1.y = d1.y;
				}
				else if(d1.y == c1.y)
				{
					c1.x = d1.x;
				}
				else
				{
					controlPoints[0] = d1;
				}
			}
			if(!isNaN(angle2))
			{
				var d2:Point = Point.polar(distance, angle2 * Math.PI / 180);
				d2.y *= -1;
				d2 = d2.add(end);
				if(d2.x == c2.x)
				{
					c2.y = d2.y;
				}
				else if(d2.y == c2.y)
				{
					c2.x = d2.x;
				}
				else
				{
					controlPoints[1] = d2;
				}
			}
			
			var thickness:Number = this.getStyle("thickness");
			var borderColor:uint = this.getStyle("borderColor");
			var fillColor:uint = this.getStyle("fillColor");
			var bezierPrecision:Number = this.getStyle("bezierPrecision");
			
			//draw circles to show connection to jack.
			this.graphics.lineStyle(1, borderColor);
			this.graphics.beginFill(fillColor);
			this.graphics.drawCircle(start.x, start.y, thickness);
			this.graphics.drawCircle(end.x, end.y, thickness);
			this.graphics.endFill();
			
			this.graphics.lineStyle(thickness, borderColor);
			BezierUtil.drawBezierCurve(this.graphics, start, end, controlPoints, bezierPrecision);
			this.graphics.lineStyle(thickness - 2, fillColor);
			BezierUtil.drawBezierCurve(this.graphics, start, end, controlPoints, bezierPrecision);
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 * When you click on the wire, it disconnects.
		 */
		protected function clickHandler(event:MouseEvent):void
		{
			this.disconnect();
		}
		
		/**
		 * @private
		 * When the mouse rolls over the wire, the disconnect cursor is shown.
		 */
		protected function wireRollOverHandler(event:MouseEvent):void
		{
			var disconnectCursorSkin:Class = this.getStyle("disconnectCursorSkin");
			this._disconnectCursorID = this.cursorManager.setCursor(disconnectCursorSkin);
			
			this.addEventListener(MouseEvent.ROLL_OUT, wireRollOutHandler);
		}
		
		/**
		 * @private
		 * When the mouse rolls off the wire, the disconnect cursor is removed.
		 */
		protected function wireRollOutHandler(event:MouseEvent):void
		{
			this.cursorManager.removeCursor(this._disconnectCursorID);
			this.removeEventListener(MouseEvent.ROLL_OUT, wireRollOutHandler);
		}
	}
}