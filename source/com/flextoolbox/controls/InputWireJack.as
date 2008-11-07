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

package com.flextoolbox.controls
{
	import com.flextoolbox.events.WireJackEvent;
	
	import mx.events.FlexEvent;
	
	/**
	 * A specialized WireJack designed to receive data from compatible output
	 * jacks. It may only have one connection.
	 * 
	 * @see OutputWireJack
	 * @author Josh Tynjala (joshblog.net)
	 */
	public class InputWireJack extends WireJack
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
		
		/**
		 * @private
		 * Error that is thrown when a developer tries to set the data property.
		 */
		private static const SET_DATA_ERROR:String = "Cannot set the data property of an InputWireJack. Data may only come from jacks to which the InputWireJack is connected.";
		
		/**
		 * @private
		 * Error that is thrown when a developer tries to set the maxConnections
		 * property.
		 */
		private static const SET_MAX_CONNECTIONS_ERROR:String = "Cannot set the maxConnections property of an InputWireJack. An InputWireJack must only have one connection.";
		
		/**
		 * @private
		 * Error that is thrown when a developer tries to set the dataFormat
		 * property.
		 */
		private static const SET_DATA_FORMAT_ERROR:String = "Cannot set dataFormat property on InputWireJack. Only acceptedDataFormat may be changed.";
		
		/**
		 * @private
		 * The dataFormat of the InputWireJack. This value is private and should
		 * <strong>never</strong> be used outside this class. It is used to
		 * ensure that two InputWireJacks can never be connected.
		 */
		internal static const INPUT_DATA_FORMAT:String = "flextoolbox::inputWireJackDataFormat";
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function InputWireJack()
		{
			super();
			this.addEventListener(WireJackEvent.CONNECT_WIRE, wireConnectHandler);
			this.addEventListener(WireJackEvent.DISCONNECT_WIRE, wireDisconnectHandler);
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		[Bindable("dataChange")]
		/**
		 * @inheritDoc
		 * 
		 * <p><strong>Important:</strong> The value of an InputWireJack's
		 * <code>data</code> property comes from the <code>data</code> property
		 * of the jack to which the InputWireJack is connected. If the
		 * InputWireJack is not connected to another jack, the <code>data</code>
		 * value is <code>null</code>.</p>
		 */
		override public function get data():Object
		{
			if(this.connectedJacks.length == 0)
			{
				if(this._noDataValue !== null)
				{
					return this._noDataValue;
				}
				return null;
			}
			
			var jack:WireJack = WireJack(this.connectedJacks[0]);
			return jack.data;
		}
		
		/**
		 * @private
		 */
		override public function set data(value:Object):void
		{
			throw new Error(InputWireJack.SET_DATA_ERROR);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get maxConnections():uint
		{
			return 1;
		}
		
		/**
		 * @private
		 */
		override public function set maxConnections(value:uint):void
		{
			throw new Error(InputWireJack.SET_MAX_CONNECTIONS_ERROR);
		}
		
		/**
		 * @inheritDoc
		 * 
		 * <p><strong>Important:</strong> The <code>dataFormat</code> property
		 * of an InputWireJack cannot be changed. This value is equal to the
		 * value of OutputWireJack's <code>acceptedDataFormat</code>
		 * property.</p>
		 */
		override public function get dataFormat():String
		{
			return InputWireJack.INPUT_DATA_FORMAT;
		}
		
		/**
		 * @private
		 */
		override public function set dataFormat(value:String):void
		{
			throw InputWireJack.SET_DATA_FORMAT_ERROR;
		}
		
		/**
		 * @private
		 * Storage for the noDataValue property.
		 */
		private var _noDataValue:* = null;
		
		/**
		 * When the InputWireJack is not connected to another jack, it still
		 * must return a value for its data property.
		 * 
		 * <p>If a jack should only receive a primitive type like Number then
		 * a developer may prefer to set noDataValue to <code>0</code> (zero) or
		 * <code>NaN</code> (not a number) rather than the default value of
		 * <code>null</code>.</p>
		 * 
		 * @default null
		 */
		public function get noDataValue():*
		{
			return this._noDataValue;
		}
		
		/**
		 * @private
		 */
		public function set noDataValue(value:*):void
		{
			this._noDataValue = value;
			
			//if we're currently in a no-data state, then the data value
			//has now changed.
			if(this.connectedJacks.length == 0)
			{
				this.dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
			}
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
	
		/**
		 * @private
		 * When a jack is connected, our data property is updated.
		 */
		protected function wireConnectHandler(event:WireJackEvent):void
		{
			event.otherJack.addEventListener(FlexEvent.DATA_CHANGE, connectedJackDataChangeHandler, false, 0, true);
			this.dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
			
		}
		
		/**
		 * @private
		 * When a jack is disconnected, our data property is updated.
		 */
		protected function wireDisconnectHandler(event:WireJackEvent):void
		{	
			event.otherJack.removeEventListener(FlexEvent.DATA_CHANGE, connectedJackDataChangeHandler);
			
			this.dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
		}
		
		/**
		 * @private
		 * If the data in the connected jack changes, our data changes too.
		 */
		protected function connectedJackDataChangeHandler(event:FlexEvent):void
		{
			this.dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
		}
		
	}
}