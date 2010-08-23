////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2010 Josh Tynjala
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

package com.flextoolbox.skins.halo
{
	import com.flextoolbox.controls.WireJack;
	import com.joshtynjala.utils.PointUtil;
	import com.yahoo.astra.utils.DisplayObjectUtil;
	import com.yahoo.astra.utils.DynamicRegistration;
	import com.yahoo.astra.utils.GeomUtil;
	
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	import mx.managers.dragClasses.DragProxy;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;

	//--------------------------------------
	//  Styles
	//--------------------------------------

	/**
	 * The size of the arrow head, in pixels.
	 */
	[Style(name="headSize",type="Number")]

	/**
	 * The thickness of the arrow's shaft, in pixels.
	 */
	[Style(name="shaftThickness",type="Number")]

	/**
	 * The radius of the arrow's origin (the connection at the starting wire
	 * jack), in pixels.
	 */
	[Style(name="originRadius",type="Number")]
	
	/**
	 * A drag image used by the WireJack to display an arrow pointing from the
	 * origin WireJack to the mouse pointer.
	 * 
	 * @see com.flextoolbox.controls.WireJack
	 * @author Josh Tynjala (joshblog.net)
	 */
	public class WireJackArrowDragImage extends UIComponent
	{	
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function WireJackArrowDragImage()
		{
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		/**
		 * @private
		 * The head of the arrow.
		 */
		protected var arrowhead:Shape;
		
		/**
		 * @private
		 * A flag indicating that the drop has been finished.
		 */
		protected var done:Boolean = false;
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			var fillColor:uint = this.getStyle("themeColor");
			var headSize:Number = this.getStyle("headSize");
			
			this.arrowhead = new Shape();
			this.addChild(this.arrowhead);
			
			this.arrowhead.graphics.endFill();
			this.arrowhead.graphics.beginFill(fillColor);
			this.arrowhead.graphics.moveTo(0, 0);
			this.arrowhead.graphics.lineTo(headSize, headSize / 2);
			this.arrowhead.graphics.lineTo(0, headSize);
			this.arrowhead.graphics.lineTo(0, 0);
			this.arrowhead.graphics.endFill();
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			this.graphics.clear();
			var proxy:DragProxy = DragProxy(this.parent);
			if(this.done || !proxy)
			{
				this.arrowhead.visible = false;
				return;
			}
			
			var startJack:WireJack = WireJack(proxy.dragInitiator);
			var startJackRadius:Number = Math.min(startJack.width / 2, startJack.height / 2);
			
			var startPosition:Point = new Point(startJack.width / 2, startJack.height / 2);
			startPosition = startJack.localToGlobal(startPosition);
			var endPosition:Point = new Point(this.stage.mouseX, this.stage.mouseY);
			var angle:Number = PointUtil.angle(startPosition, endPosition);
			
			var headSize:Number = this.getStyle("headSize");
			var distance:Number = Point.distance(startPosition, endPosition);
			if(distance - headSize < startJackRadius)
			{
				//ensure that the arrow head doesn't overlap the jack
				distance = startJackRadius + headSize;
			}
			distance -= headSize;
			endPosition = Point.polar(distance, angle).add(startPosition);
			
			var originRadius:Number = this.getStyle("originRadius");
			var shaftThickness:Number = this.getStyle("shaftThickness");
			var fillColor:uint = this.getStyle("themeColor");
			this.graphics.beginFill(fillColor);
			this.graphics.drawCircle(startPosition.x, startPosition.y, originRadius);
			this.graphics.endFill();
			
			this.graphics.lineStyle(shaftThickness, fillColor, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
			this.graphics.moveTo(startPosition.x, startPosition.y);
			this.graphics.lineTo(endPosition.x, endPosition.y);
			
			this.arrowhead.rotation = 0;
			this.arrowhead.x = endPosition.x;
			this.arrowhead.y = endPosition.y - headSize / 2;
			var degrees:Number = GeomUtil.radiansToDegrees(angle);
			DynamicRegistration.rotate(this.arrowhead, new Point(0, headSize / 2), degrees);
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		private function finish():void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			
			this.done = true;
			this.invalidateDisplayList();
			this.validateNow();
		}
		
	//--------------------------------------
	//  Private Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 * Once this drag image is added to the stage, we need to listen for
		 * mouse events.
		 */
		private function addedToStageHandler(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
		}
		
		/**
		 * @private
		 * If removed from stage, then we need to finish immediately.
		 */
		private function removedFromStageHandler(event:Event):void
		{
			this.finish();
		}
		
		/**
		 * @private
		 * Once the mouse is released, this operation is done.
		 */
		private function stage_mouseUpHandler(event:MouseEvent):void
		{
			this.finish();
		}
		
		/**
		 * @private
		 * While the mouse is moving, we need to be sure we're redrawing.
		 */
		private function stage_mouseMoveHandler(event:MouseEvent):void
		{
			this.invalidateDisplayList();
			this.validateNow();
		}
	}
}