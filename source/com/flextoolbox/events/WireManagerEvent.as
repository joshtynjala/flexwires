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
	 * Events that may be dispatched by an IWireManager.
	 * 
	 * @see com.flextoolbox.managers.IWireManager
	 * @author Josh Tynjala (joshblog.net)
	 */
	public class WireManagerEvent extends Event
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
	
		/**
		 * The WireManagerEvent.BEGIN_CONNECTION_REQUEST constant defines the
		 * value of the <code>type</code> property of a WireManagerEvent object
		 * for a <code>beginConnectionRequest</code> event, which indicates that
		 * a WireJack is attempting to connect to other compatible WireJack instances.
		 */
		public static const BEGIN_CONNECTION_REQUEST:String = "beginConnectionRequest";
		
		/**
		 * The WireManagerEvent.END_CONNNECTION_REQUEST constant defines the
		 * value of the <code>type</code> property of a WireManagerEvent object
		 * for a <code>endConnectionRequest</code> event, which indicates that
		 * a WireJack is no longer attempting to connect to other compatible
		 * WireJack instances.
		 */
		public static const END_CONNNECTION_REQUEST:String = "endConnectionRequest";
		
		/**
		 * The WireManagerEvent.CREATING_CONNECTION constant defines the
		 * value of the <code>type</code> property of a WireManagerEvent object
		 * for a <code>creatingConnection</code> event, which indicates that
		 * two WireJack instances will soon be connected. This action may be
		 * cancelled.
		 */
		public static const CREATING_CONNECTION:String = "creatingConnection";
		
		/**
		 * The WireManagerEvent.CREATE_CONNECTION constant defines the
		 * value of the <code>type</code> property of a WireManagerEvent object
		 * for a <code>createConnection</code> event, which indicates that
		 * two WireJack instances have connected.
		 */
		public static const CREATE_CONNECTION:String = "createConnection";
		
		/**
		 * The WireManagerEvent.DELETING_CONNECTION constant defines the
		 * value of the <code>type</code> property of a WireManagerEvent object
		 * for a <code>deletingConnection</code> event, which indicates that
		 * two WireJack instances will soon be disconnected. This action may be
		 * cancelled.
		 */
		public static const DELETING_CONNECTION:String = "deletingConnection";
		
		/**
		 * The WireManagerEvent.DELETE_CONNECTION constant defines the
		 * value of the <code>type</code> property of a WireManagerEvent object
		 * for a <code>deleteConnection</code> event, which indicates that
		 * two WireJack instances have been disconnected.
		 */
		public static const DELETE_CONNECTION:String = "deleteConnection";
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 * 
		 * @param type			The type of event.
		 * @param startJack		A jack associated with the event.
		 * @param endJack		An optional second jack associated with the event.
		 * @param cancelable	If true, this event may be cancelled.
		 */
		public function WireManagerEvent(type:String, startJack:WireJack, endJack:WireJack = null, cancelable:Boolean = false)
		{
			super(type, false, cancelable);
			
			this.startJack = startJack;
			this.endJack = endJack;
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		/**
		 * A jack associated with the event.
		 */
		public var startJack:WireJack;
		
		/**
		 * Another jack associated with the event.
		 */
		public var endJack:WireJack;
	
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new WireManagerEvent(this.type, this.startJack, this.endJack, this.cancelable);
		}
		
	}
}