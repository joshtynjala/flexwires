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

package com.flextoolbox.managers
{
	import com.flextoolbox.controls.WireJack;
	
	import flash.events.IEventDispatcher;
	
	import mx.core.IFactory;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * Dispatched when a registered WireJack wants to make a connection with
	 * another WireJack. Generally, compatible WireJack instances are expected
	 * to highlight themselves so that the user knows where a connection can be
	 * made.
	 * 
	 * @eventType com.flextoolbox.events.WireManagerEvent.BEGIN_CONNECTION_REQUEST
	 */
	[Event(name="beginConnectionRequest",type="com.flextoolbox.events.WireManagerEvent")]
	
	/**
	 * Dispatched when a registered WireJack wants to end a connection request.
	 * Generally, compatible WireJack instances are expected to remove their
	 * highlight at this time.
	 * 
	 * @eventType com.flextoolbox.events.WireManagerEvent.END_CONNECTION_REQUEST
	 */
	[Event(name="endConnectionRequest",type="com.flextoolbox.events.WireManagerEvent")]
	
	/**
	 * Dispatched when a connection is made between two WireJack instances. May
	 * be cancelled.
	 * 
	 * @eventType com.flextoolbox.events.WireManagerEvent.CREATE_CONNECTION
	 */
	[Event(name="createConnection",type="com.flextoolbox.events.WireManagerEvent")]
	
	/**
	 * Dispatched when a connection is deleted between two WireJack instances.
	 * 
	 * @eventType com.flextoolbox.events.WireManagerEvent.DELETE_CONNECTION
	 */
	[Event(name="deleteConnection",type="com.flextoolbox.events.WireManagerEvent")]
	
	/**
	 * An interface that defines a wire manager used by WireJacks.
	 * 
	 * @author Josh Tynjala (joshblog.net)
	 */
	public interface IWireManager extends IEventDispatcher
	{
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * The class used to render wires. Must implement IWireRenderer.
		 * 
		 * @see com.flextoolbox.controls.wireClasses.IWireRenderer
		 */
		function get wireRenderer():IFactory;
		
		/**
		 * @private
		 */
		function set wireRenderer(value:IFactory):void;
		
	//--------------------------------------
	//  Methods
	//--------------------------------------
	
		/**
		 * Registers a jack with this wire manager.
		 * 
		 * @param jack		The jack to register.
		 */
		function registerJack(jack:WireJack):void;
		
		/**
		 * Removes a jack's registration with this wire manager.
		 * 
		 * @param jack		The jack to remove.
		 */
		function deleteJack(jack:WireJack):void;
		
		/**
		 * Called by a registered WireJack, this begins a connection request.
		 * Generally, if a jack should be highlighted when the user is dragging
		 * a wire, the highlight is turned on during a connection request.
		 * 
		 * @param		The jack that will be connected to another jack.
		 */
		function beginConnectionRequest(startJack:WireJack):void;
		
		/**
		 * Called by a registered WireJack, this ends a connection request.
		 * Generally, if other jacks are highlighted during a drag-and-drop
		 * operation, the highlight is turned off when a connection request
		 * ends.
		 * 
		 * @param		The jack that started the connection request.
		 */
		function endConnectionRequest(startJack:WireJack):void;
		
		/**
		 * Connects two jacks.
		 * 
		 * <p>Note: If one or both of the jacks are null, if one or both of the
		 * jacks aren't registered, or the jacks are equal, an ArgumentError will
		 * be thrown. Returns false only when the connection event is cancelled.</p>
		 * 
		 * @param startJack		The first jack to connect.
		 * @param endJack		The second jack to connect.
		 * @return				true if the jacks have been connected, false if not.
		 */
		function connect(startJack:WireJack, endJack:WireJack):Boolean;
		
		/**
		 * Disconnects two connected jacks.
		 * 
		 * <p>Note: If one or both of the jacks are null, if one or both of the
		 * jacks aren't registered, or the jacks aren't connected, an
		 * ArgumentError will be thrown.</p>
		 * 
		 * @param startJack		The first jack to connect.
		 * @param endJack		The second jack to connect.
		 */
		function disconnect(startJack:WireJack, endJack:WireJack):void;
	}
}