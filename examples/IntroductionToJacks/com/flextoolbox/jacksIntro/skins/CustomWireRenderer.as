package com.flextoolbox.jacksIntro.skins
{
	import com.flextoolbox.controls.wireClasses.BaseWireRenderer;
	import com.joshtynjala.utils.GraphicsUtil;
	import com.yahoo.astra.utils.DisplayObjectUtil;
	import com.yahoo.astra.utils.GeomUtil;
	
	import flash.display.CapsStyle;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * 
	 * 
	 * @author Josh Tynjala (joshblog.net)
	 */
	public class CustomWireRenderer extends BaseWireRenderer
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function CustomWireRenderer()
		{
			super();
			
			this.buttonMode = true;
			this.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
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
			
			var controlPoints:Array = [c1, c2];
			if(!isNaN(angle1))
			{
				var d1:Point = Point.polar(distance, -GeomUtil.degreesToRadians(angle1));
				d1 = d1.add(start);
				controlPoints[0] = d1;
			}
			if(!isNaN(angle2))
			{
				var d2:Point = Point.polar(distance, -GeomUtil.degreesToRadians(angle2));
				d2 = d2.add(end);
				controlPoints.push(d2);
				controlPoints[1] = d2;
			}
			
			this.graphics.lineStyle(6, 0xd8d8d8, 1, true, "normal", CapsStyle.NONE);
			this.graphics.moveTo(start.x, start.y);
			var lastPoint:Point = start;
			var controlPointCount:int = controlPoints.length;
			for(var i:int = 0; i < controlPointCount; i++)
			{
				var currentPoint:Point = Point(controlPoints[i]);
				GraphicsUtil.drawDashedLine(this.graphics, lastPoint.x, lastPoint.y, currentPoint.x, currentPoint.y);
				this.graphics.lineTo(currentPoint.x, currentPoint.y);
				lastPoint = currentPoint;
			}
			GraphicsUtil.drawDashedLine(this.graphics, lastPoint.x, lastPoint.y, end.x, end.y);
			//this.graphics.lineTo(end.x, end.y);
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
	}
}