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
	import com.flextoolbox.controls.wireClasses.IWireRenderer;
	import com.flextoolbox.managers.IWireManager;
	import com.flextoolbox.managers.WireManager;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	import mx.core.IFactory;
	import mx.core.UIComponent;
	import mx.managers.dragClasses.DragProxy;
	
	/**
	 * A drag image to be used by the WireJack to display an wire connecting
	 * from the origin WireJack to the mouse pointer..
	 * 
	 * @see com.flextoolbox.controls.WireJack
	 * @author Josh Tynjala (joshblog.net)
	 */
	public class WireJackWireDragImage extends UIComponent
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function WireJackWireDragImage()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 * A wire that follows the mouse during a drag and drop operation.
		 */
		protected var wire:IWireRenderer;
		
		/**
		 * @private
		 * The wire renderer needs to connect to two jacks. Since this drag
		 * image skin is used before a connection is made, a fake end jack
		 * is needed so that the wire follows the mouse.
		 */
		protected var fakeEndJack:WireJack;
		
		/**
		 * @private
		 * A flag indicating that the drop has been finished.
		 */
		protected var done:Boolean = false;
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void
		{
			var allStyles:Boolean = !styleProp || styleProp == "styleName";
			
			if(allStyles || styleProp == "wireJackStyleName")
			{
				if(this.fakeEndJack)
				{
					this.fakeEndJack.styleName = this.getStyle("wireJackStyleName");
				}
			}
		}
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			if(!this.fakeEndJack)
			{
				this.fakeEndJack = new WireJack();
				//we don't actually need to see the jack. it's just there so the
				//wire can follow the mouse
				this.fakeEndJack.visible = false;
				this.fakeEndJack.mouseEnabled = this.fakeEndJack.mouseChildren = false;
				this.addChild(this.fakeEndJack);
				this.fakeEndJack.move(this.parentApplication.mouseX, this.parentApplication.mouseY);
			}
			
			if(!this.wire)
			{
				var dragProxy:DragProxy = DragProxy(this.parent);
				var startJack:WireJack = WireJack(dragProxy.dragSource.dataForFormat(WireJack.WIRE_JACK_DRAG_FORMAT));
				this.wire = startJack.wireManager.wireRenderer.newInstance();
				InteractiveObject(this.wire).mouseEnabled = DisplayObjectContainer(this.wire).mouseChildren = false;
				this.addChild(DisplayObject(this.wire));
				
				this.wire.jack1 = startJack;
				this.wire.jack2 = fakeEndJack;
			}
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if(this.done)
			{
				if(this.fakeEndJack)
				{
					this.removeChild(this.fakeEndJack);
					this.fakeEndJack = null;
				}
				
				if(this.wire)
				{
					this.removeChild(DisplayObject(this.wire));
					this.wire.jack1 = null;
					this.wire.jack2 = null;
					this.wire = null;
				}
			}
			else
			{
				this.fakeEndJack.setActualSize(this.fakeEndJack.getExplicitOrMeasuredWidth(), this.fakeEndJack.getExplicitOrMeasuredHeight());
				this.fakeEndJack.move(this.stage.mouseX - this.fakeEndJack.width / 2, this.stage.mouseY - this.fakeEndJack.height / 2);
			}
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
		 * While the mouse is moving, we need to be sure we're redrawing because
		 * the fakeEndJack follows the mouse.
		 */
		private function stage_mouseMoveHandler(event:MouseEvent):void
		{
			this.invalidateDisplayList();
			this.validateNow();
		}

	}
}