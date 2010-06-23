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
	import com.flextoolbox.controls.wireClasses.DefaultWireRenderer;
	import com.flextoolbox.controls.wireClasses.IWireRenderer;
	import com.flextoolbox.events.WireManagerEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	
	import mx.core.Application;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	
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
	 * Dispatched when a connection will soon made between two WireJack
	 * instances. May be cancelled.
	 * 
	 * @eventType com.flextoolbox.events.WireManagerEvent.CREATING_CONNECTION
	 */
	[Event(name="creatingConnection",type="com.flextoolbox.events.WireManagerEvent")]
	
	/**
	 * Dispatched when a connection is made between two WireJack instances.
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
	 * Manages connections or "wires" that are made between "jacks".
	 * 
	 * @see com.flextoolbox.controls.WireJack
	 * @author Josh Tynjala (joshblog.net)
	 */
	public class WireManager extends EventDispatcher implements IWireManager
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
	
		/**
		 * @private
		 * Storage for the defaultWireManager property.
		 */
		private static var _defaultWireManager:WireManager = new WireManager();
		
		/**
		 * The default wire manager that is used if no wire manager is specified.
		 */
		public static function get defaultWireManager():WireManager
		{
			return WireManager._defaultWireManager;
		}
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 * 
		 * @param surface		if null, a layer is automatically created on the PopUpManager
		 */
		public function WireManager(surface:IUIComponent = null)
		{
			if(!surface)
			{
				this.wireSurface = new UIComponent();
				PopUpManager.addPopUp(this.wireSurface, DisplayObject(Application.application));
			}
			else
			{
				this.wireSurface = surface;
			}
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		/**
		 * @private
		 * The surface on which to draw wires.
		 */
		protected var wireSurface:IUIComponent;
		
		/**
		 * @private
		 * The jacks registered with this wire manager.
		 */
		protected var jacks:Array = [];
		
		/**
		 * @private
		 * The wires created by this wire manager.
		 */
		protected var wires:Array = [];
		
		/**
		 * @private
		 * Flag indicating that a wire is connecting.
		 */
		protected var connecting:Boolean = false;
		
		/**
		 * @private
		 * Storage for the wireRenderer property.
		 */
		private var _wireRenderer:IFactory = new ClassFactory(DefaultWireRenderer);
		
		/**
		 * @inheritDoc
		 */
		public function get wireRenderer():IFactory
		{
			return this._wireRenderer;
		}
		
		/**
		 * @private
		 */
		public function set wireRenderer(value:IFactory):void
		{
			this._wireRenderer = value;
		}
		
		private var _hasActiveConnectionRequest:Boolean = false;
		
		/**
		 * @inheritDoc
		 */
		public function get hasActiveConnectionRequest():Boolean
		{
			return this._hasActiveConnectionRequest;
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		/**
		 * @inheritDoc
		 */
		public function registerJack(jack:WireJack):void
		{
			this.jacks.push(jack);
		}
		
		/**
		 * @inheritDoc
		 */
		public function deleteJack(jack:WireJack):void
		{
			var index:int = this.jacks.indexOf(jack);
			if(index >= 0)
			{
				//make sure there are no connections left!
				jack.disconnectAll();
				this.jacks.splice(index, 1);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function beginConnectionRequest(jack:WireJack):void
		{
			if(this._hasActiveConnectionRequest)
			{
				throw new IllegalOperationError("Cannot have more than one active connection request at a time.");
			}
			this._hasActiveConnectionRequest = true;
			var begin:WireManagerEvent = new WireManagerEvent(WireManagerEvent.BEGIN_CONNECTION_REQUEST, jack);
			this.dispatchEvent(begin);
		}
		
		/**
		 * @inheritDoc
		 */
		public function endConnectionRequest(jack:WireJack):void
		{
			this._hasActiveConnectionRequest = false;
			var end:WireManagerEvent = new WireManagerEvent(WireManagerEvent.END_CONNNECTION_REQUEST, jack);
			this.dispatchEvent(end);
		}
		
		/**
		 * @inheritDoc
		 */
		public function connect(startJack:WireJack, endJack:WireJack):Boolean
		{
			if(!startJack || !endJack)
			{
				throw new ArgumentError("Jack is null. Cannot make connection.");
			}
			
			if(startJack == endJack)
			{
				throw new ArgumentError("Cannot connect a jack to itself. No connection.");
			}
			
			if(this.jacks.indexOf(startJack) < 0 || this.jacks.indexOf(endJack) < 0)
			{
				throw new ArgumentError("One or more of the specified jacks are not registered with this wire manager.");
			}
			
			//check if both jacks are compatible
			if(startJack.isCompatibleWithJack(endJack) && endJack.isCompatibleWithJack(startJack))
			{
				var creating:WireManagerEvent = new WireManagerEvent(WireManagerEvent.CREATING_CONNECTION, startJack, endJack, true);
				var result:Boolean = this.dispatchEvent(creating);
				if(result)
				{
					//if the connection was successful, create the wire
					var wire:IWireRenderer = this.wireRenderer.newInstance();
					wire.wireManager = this;
					wire.jack1 = startJack;
					wire.jack2 = endJack;
					DisplayObjectContainer(this.wireSurface).addChild(DisplayObject(wire));
					this.wires.push(wire);
					
					//this flag indicates that a connection is in progress.
					//disconnect requests during this time will be queued until
					//the connection is complete because not all jacks may have
					//saved the connection while the flag is still true.
					this.connecting = true;
					var create:WireManagerEvent = new WireManagerEvent(WireManagerEvent.CREATE_CONNECTION, startJack, endJack);
					this.dispatchEvent(create);
					this.connecting = false;
				}
				return result;
			}
			
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function disconnect(startJack:WireJack, endJack:WireJack):void
		{
			if(this.connecting)
			{
				//can't disconnect if a connection is in progress.
				Application.application.callLater(disconnect, [startJack, endJack]);
				return;
			}
			
			if(!startJack || !endJack || !startJack.isConnectedToJack(endJack))
			{
				throw new ArgumentError("Specified jack is null or jacks are not connected. Cannot disconnect.");
			}
			
			if(this.jacks.indexOf(startJack) < 0 || this.jacks.indexOf(endJack) < 0)
			{
				throw new ArgumentError("One or more of the specified jacks are not registered with this wire manager.");
			}
			
			var connections:Array = this.wires.filter(function(wire:IWireRenderer, index:int, source:Array):Boolean
			{
				return (wire.jack1 == startJack || wire.jack1 == endJack) &&
					(wire.jack2 == startJack || wire.jack2 == endJack);
			});
			
			for each(var wire:IWireRenderer in connections)
			{
				var index:int = this.wires.indexOf(wire);
				this.wires.splice(index, 1);
				DisplayObjectContainer(this.wireSurface).removeChild(DisplayObject(wire));
				wire.jack1 = null;
				wire.jack2 = null;
			}
			
			var deleteConnection:WireManagerEvent = new WireManagerEvent(WireManagerEvent.DELETE_CONNECTION, startJack, endJack);
			this.dispatchEvent(deleteConnection);
		}

	}
}