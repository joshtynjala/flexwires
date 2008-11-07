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

package com.flextoolbox.events
{
	import com.flextoolbox.controls.WireJack;
	
	import flash.events.Event;

	/**
	 * Events associated with the WireJack control.
	 * 
	 * @see com.flextoolbox.controls.WireJack
	 * @author Josh Tynjala (joshblog.net)
	 */
	public class WireJackEvent extends Event
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
	
		/**
		 * The WireJackEvent.CONNECTING_WIRE constant defines the
		 * value of the <code>type</code> property of a WireJackEvent object
		 * for a <code>connectWire</code> event, which indicates that a Wire
		 * will soon be connected to the target WireJack. This action may be
		 * cancelled.
		 */
		public static const CONNECTING_WIRE:String = "connectingWire";
	
		/**
		 * The WireJackEvent.CONNECT_WIRE constant defines the
		 * value of the <code>type</code> property of a WireJackEvent object
		 * for a <code>connectWire</code> event, which indicates that a Wire
		 * has been connected to the target WireJack.
		 */
		public static const CONNECT_WIRE:String = "connectWire";
		
		/**
		 * The WireJackEvent.WIRE_DISCONNECT constant defines the
		 * value of the <code>type</code> property of a WireJackEvent object
		 * for a <code>wireDisconnect</code> event, which indicates that a Wire
		 * has been disconnected from the target WireJack.
		 */
		public static const DISCONNECT_WIRE:String = "disconnectWire";
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 * 
		 * @param type				The type of event.
		 * @param otherJack			The other jack associated with the event.
		 */
		public function WireJackEvent(type:String, otherJack:WireJack, cancelable:Boolean = false)
		{
			super(type, false, cancelable);
			this.otherJack = otherJack;
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		/**
		 * The other jack associated with this event.
		 */
		public var otherJack:WireJack;
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new WireJackEvent(this.type, this.otherJack, this.cancelable);
		}
		
	}
}