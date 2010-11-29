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
	import com.flextoolbox.controls.WireJack;
	import com.flextoolbox.managers.IWireManager;
	import com.yahoo.astra.utils.DisplayObjectUtil;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	/**
	 * An abstract base class for IWireRenderer implementations. Does not draw
	 * the wire, nor does it provide an implementation for disconnecting the
	 * wire through user interaction.
	 * 
	 * @author Josh Tynjala (joshblog.net)
	 */
	public class BaseWireRenderer extends UIComponent implements IWireRenderer
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		private static const FRAME_EVENT_SHAPE:Shape = new Shape();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function BaseWireRenderer()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 * Storage for the jack1 property.
		 */
		private var _jack1:WireJack;
		
		/**
		 * @inheritDoc
		 */
		public function get jack1():WireJack
		{
			return this._jack1;
		}
		
		/**
		 * @private
		 */
		public function set jack1(value:WireJack):void
		{
			this._jack1 = value;
			this.invalidateDisplayList();
		}
		
		/**
		 * @private
		 * Storage for the jack2 property.
		 */
		private var _jack2:WireJack;
		
		/**
		 * @inheritDoc
		 */
		public function get jack2():WireJack
		{
			return this._jack2;
		}
		
		/**
		 * @private
		 */
		public function set jack2(value:WireJack):void
		{
			this._jack2 = value;
			this.invalidateDisplayList();
		}
		
		/**
		 * @private
		 * Flag to indicate if this wire will redraw every frame.
		 */
		private var _isListeningForEnterFrame:Boolean = false;
		
		/**
		 * @private
		 * Storage for the wireManager property.
		 */
		private var _wireManager:IWireManager;
		
		/**
		 * @inheritDoc
		 */
		public function get wireManager():IWireManager
		{
			return this._wireManager;
		}
		
		/**
		 * @private
		 */
		public function set wireManager(value:IWireManager):void
		{
			this.disconnect();
			
			this._wireManager = value;
		}
		
		/**
		 * @private
		 * The last position of jack1.
		 */
		private var _lastJack1Position:Point;
		
		/**
		 * @private
		 * The last position of jack2.
		 */
		private var _lastJack2Position:Point;
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function disconnect():void
		{
			if(this.jack1 || this.jack2)
			{
				this.wireManager.disconnect(this.jack1, this.jack2);
			}
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
			
			if(!this.jack1 || !this.jack2)
			{
				FRAME_EVENT_SHAPE.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				this._isListeningForEnterFrame = false;
				return;
			}
			
			//we have to know when the wire jack moves, or one of its parents
			//moves. there's no event for that, so we have to check every frame
			//possible optimization: do it in the manager.
			if(!this._isListeningForEnterFrame)
			{
				this._isListeningForEnterFrame = true;
				FRAME_EVENT_SHAPE.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
			
			var jackPositions:Array = this.calculateJackPositions();
			this._lastJack1Position = Point(jackPositions[0]);
			this._lastJack2Position = Point(jackPositions[1]);
		}
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
		
		/**
		 * @private
		 * Determines the current positions of the wire jacks.
		 */
		protected function calculateJackPositions():Array
		{
			var start:Point = new Point(this.jack1.width / 2, this.jack1.height / 2);
			start = DisplayObjectUtil.localToLocal(start, jack1, this);
			var end:Point = new Point(this.jack2.width / 2, this.jack2.height / 2);
			end = DisplayObjectUtil.localToLocal(end, jack2, this);
			
			return [start, end]
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 * Every frame, we check to see if one of the jacks has moved. If one
		 * or the other isn't in the same position, then we need to redraw.
		 */
		protected function enterFrameHandler(event:Event):void
		{
			if(!this.jack1 || !this.jack2)
			{
				return;
			}
			
			var jackPositions:Array = this.calculateJackPositions();
			var start:Point = Point(jackPositions[0]);
			var end:Point = Point(jackPositions[1]);
			if(!this._lastJack1Position.equals(start) || !this._lastJack2Position.equals(end))
			{
				this.invalidateDisplayList();
				//we're drawing immediately to avoid the wire jumping after a
				//short, but noticeable, delay.
				this.validateNow();
			}
		}
		
	}
}