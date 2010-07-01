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

package com.flextoolbox.controls
{
	import com.flextoolbox.events.WireJackEvent;
	import com.flextoolbox.events.WireManagerEvent;
	import com.flextoolbox.managers.IWireManager;
	import com.flextoolbox.managers.WireManager;
	import com.flextoolbox.utils.TheInstantiator;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.DragSource;
	import mx.core.IDataRenderer;
	import mx.core.IFlexDisplayObject;
	import mx.core.IInvalidating;
	import mx.core.IProgrammaticSkin;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	import mx.managers.PopUpManager;
	import mx.managers.dragClasses.DragProxy;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.ISimpleStyleClient;
	import mx.styles.StyleManager;

	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
	 * The class used to create the drag image.
	 */
	[Style(name="dragImage",type="Class")]
	
	/**
	 * If the dragImage supports styleNames, this value is used.
	 */
	[Style(name="dragImageStyleName",type="String")]
	
	/**
	 * The class used for the WireJack's skin.
	 */
	[Style(name="skin",type="Class")]
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * Dispatched when a wire will soon connected to the WireJack instance. If
	 * this event is cancelled, the wire will not be connected.
	 * 
	 * @eventType com.flextoolbox.events.WireJackEvent.CONNECTING_WIRE
	 */
	[Event(name="connectingWire",type="com.flextoolbox.events.WireJackEvent")]

	/**
	 * Dispatched when a wire is connected to the WireJack instance.
	 * 
	 * @eventType com.flextoolbox.events.WireJackEvent.CONNECT_WIRE
	 */
	[Event(name="connectWire",type="com.flextoolbox.events.WireJackEvent")]

	/**
	 * Dispatched when a connected wire is removed from the WireJack instance.
	 * 
	 * @eventType com.flextoolbox.events.WireJackEvent.DISCONNECT_WIRE
	 */
	[Event(name="disconnectWire",type="com.flextoolbox.events.WireJackEvent")]

	/**
	 * Dispatched when the value of the data property of the WireJack changes.
	 * 
	 * @eventType mx.events.FlexEvent.DATA_CHANGE
	 */
	[Event(name="dataChange",type="mx.events.FlexEvent")]

	/**
	 * A UI control representing a jack for connecting wires.
	 * 
	 * @author Josh Tynjala (joshblog.net)
	 */
	public class WireJack extends UIComponent implements IDataRenderer
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
		
		/**
		 * @private
		 * Since we can't use DragManager (it's behavior in AIR causes mouse
		 * events to go away), we make a fake drag proxy that acts like the
		 * DragManager.
		 */
		protected static var fakeDragProxy:DragProxy;
		
		/**
		 * If <code>true</code>, dragging a wire from one jack to other will be
		 * initiated by a mouse click event on the first jack in addition to
		 * the standard drag while the mouse is down.
		 * 
		 * <p>Note: In previous versions, the dragging could begin only on click
		 * if clickToDrag is enabled, but not both. This has been changed to
		 * include both, for usability reasons. Click-dragging is still disabled
		 * by default, though.</p>
		 * 
		 * @example To initialize this alternate behavior, use the following code:
		 * <listing version="3.0">
		 * WireJack.clickToDrag = true;
		 * </listing>
		 */
		public static var clickToDrag:Boolean = false;
		
		/**
		 * The dragFormat used by wire jacks for drag and drop operations.
		 */
		public static const WIRE_JACK_DRAG_FORMAT:String = "flextoolbox::wireJack";
		
		/**
		 * @private
		 * Error message when maxConnections is set to a value less than the number of existing connections.
		 */
		private static const TOO_MANY_EXISTING_CONNECTIONS_ERROR:String = "Cannot set maxConnections to a value smaller than the number of existing connections."
		
		/**
		 * @private
		 * Max connections must be at least 0 (zero).
		 */
		private static const MINIMUM_MAX_CONNECTIONS_ERROR:String = "Cannot set maxConnections to a value less than zero.";
		
		/**
		 * @private
		 * Thrown when a jack tries to disconnect from a jack to which it isn't connected.
		 */
		private static const JACKS_NOT_CONNECTED_ERROR:String = "Cannot delete connection if jacks aren't connected.";
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 */
		public function WireJack()
		{
			super();
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			this.addEventListener(MouseEvent.CLICK, clickHandler);
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			this.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
			
			this.wireManager = WireManager.defaultWireManager;
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 * Storage for the wireManager property.
		 */
		private var _wireManager:IWireManager;
		
		[Bindable("wireManagerChange")]
		/**
		 * The IWireManager with which this jack is registered.
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
			if(this._wireManager)
			{
				this._wireManager.deleteJack(this);
				this._wireManager.removeEventListener(WireManagerEvent.BEGIN_CONNECTION_REQUEST, wireManager_beginConnectionRequestHandler);
				this._wireManager.removeEventListener(WireManagerEvent.END_CONNNECTION_REQUEST, wireManager_endConnectionRequestHandler);
				this._wireManager.removeEventListener(WireManagerEvent.CREATING_CONNECTION, wireManager_creatingConnectionHandler);
				this._wireManager.removeEventListener(WireManagerEvent.CREATE_CONNECTION, wireManager_createConnectionHandler);
				this._wireManager.removeEventListener(WireManagerEvent.DELETE_CONNECTION, wireManager_deleteConnectionHandler);
				this._wireManager = null;
			}
			
			if(!value)
			{
				value = WireManager.defaultWireManager;
			}
			
			this._wireManager = value;
			
			if(this._wireManager)
			{
				this._wireManager.registerJack(this);
				this._wireManager.addEventListener(WireManagerEvent.BEGIN_CONNECTION_REQUEST, wireManager_beginConnectionRequestHandler, false, 0, true);
				this._wireManager.addEventListener(WireManagerEvent.END_CONNNECTION_REQUEST, wireManager_endConnectionRequestHandler, false, 0, true);
				this._wireManager.addEventListener(WireManagerEvent.CREATING_CONNECTION, wireManager_creatingConnectionHandler, false, 0, true);
				this._wireManager.addEventListener(WireManagerEvent.CREATE_CONNECTION, wireManager_createConnectionHandler, false, 0, true);
				this._wireManager.addEventListener(WireManagerEvent.DELETE_CONNECTION, wireManager_deleteConnectionHandler, false, 0, true);
			}
			this.dispatchEvent(new Event("wireManagerChange"));
		}
		
		/**
		 * @private
		 * Storage for the data property.
		 */
		private var _data:Object;
		
		[Bindable("dataChange")]
		/**
		 * The data associated with this jack. The related <code>dataFormat</code>
		 * property specifies the type of data that the jack may hold, although
		 * this isn't enforced.
		 * 
		 * @see #dataFormat
		 * @see #acceptedDataFormat
		 */
		public function get data():Object
		{
			return this._data;
		}
		
		/**
		 * @private
		 */
		public function set data(value:Object):void
		{
			if(this._data == value)
			{
				return;
			}
			
			this._data = value;
			this.dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
		}
		
		/**
		 * @private
		 * Storage for the dataFormat property.
		 */
		private var _dataFormat:String = null;
		
		[Bindable("dataFormatChange")]
		/**
		 * The format of the data associated with this jack. Used in combination
		 * with <code>acceptedDataFormat</code> to control which jacks may be
		 * connected to other jacks.
		 * 
		 * @see #data
		 * @see #acceptedDataFormat
		 */
		public function get dataFormat():String
		{
			return this._dataFormat;
		}
		
		/**
		 * @private
		 */
		public function set dataFormat(value:String):void
		{
			this._dataFormat = value;
			this.dispatchEvent(new Event("dataFormatChange"));
		}
		
		/**
		 * @private
		 * Storage for the acceptedDataFormat property.
		 */
		private var _acceptedDataFormat:String = null;
		
		[Bindable("acceptedDataFormatChange")]
		/**
		 * The <code>dataFormat</code> required for other jacks before they may
		 * connect to this jack.
		 * 
		 * @see #dataFormat
		 * @see #data
		 */
		public function get acceptedDataFormat():String
		{
			return this._acceptedDataFormat;
		}
		
		/**
		 * @private
		 */
		public function set acceptedDataFormat(value:String):void
		{
			this._acceptedDataFormat = value;
			this.dispatchEvent(new Event("acceptedDataFormatChange"));
		}
		
		/**
		 * @private
		 * Storage for the maxConnections property.
		 */
		private var _maxConnections:uint = uint.MAX_VALUE;
		
		[Bindable("maxConnectionsChange")]
		/**
		 * The maximum number of wires that may be connected to this jack.
		 */
		public function get maxConnections():uint
		{
			return this._maxConnections;
		}
		
		/**
		 * @private
		 */
		public function set maxConnections(value:uint):void
		{
			if(this.connectedJacks.length > value)
			{
				throw new ArgumentError(WireJack.TOO_MANY_EXISTING_CONNECTIONS_ERROR);
			}
			this._maxConnections = value;
			this.dispatchEvent(new Event("maxConnectionsChange"));
		}
		
		/**
		 * @private
		 * Storage for the connectionAngle property.
		 */
		private var _connectionAngle:Number = NaN;
		
		[Bindable("connectionAngleChange")]
		/**
		 * The angle, in degrees, at which the wire enters or exits the jack.
		 * Used by the wire renderer.
		 * 
		 * @see com.flextoolbox.controls.wireClasses.IWireRenderer
		 */
		public function get connectionAngle():Number
		{
			return this._connectionAngle;
		}
		
		/**
		 * @private
		 */
		public function set connectionAngle(value:Number):void
		{
			this._connectionAngle = value;
			this.invalidateDisplayList();
			this.dispatchEvent(new Event("connectionAngleChange"));
		}
		
		/**
		 * @private
		 * Storage for the ignoredJacks property.
		 */
		private var _ignoredJacks:Array = [];
		
		[Bindable("ignoredJacksChange")]
		/**
		 * A list of jacks that are always incompatible with this jack.
		 */
		public function get ignoredJacks():Array
		{
			return this._ignoredJacks;
		}
		
		/**
		 * @private
		 */
		public function set ignoredJacks(value:Array):void
		{
			this._ignoredJacks = value;
			this.dispatchEvent(new Event("ignoredJacksChange"));
		}
		
		/**
		 * @private
		 * Storage for the connectedJacks property.
		 */
		private var _connectedJacks:Array /*Vector.<WireJack>*/ = [];
		
		/**
		 * The other jacks that are currently connected to this jack. Do not
		 * manipulate this list to add or remove jacks from the connections.
		 * Instead use <code>connectToJack()</code> and <code>disconnect()</code>
		 * 
		 * @see #connectToJack()
		 * @see #disconnect()
		 */
		public function get connectedJacks():Array //Vector.<WireJack>
		{
			return this._connectedJacks.concat();
		}
		
		/**
		 * @private
		 * Storage for the highlighted property.
		 */
		private var _highlighted:Boolean = false;
		
		/**
		 * @private
		 * The jack is highlighted when another jack is attempted to make a
		 * connection and the two jacks are compatible.
		 */
		protected function get highlighted():Boolean
		{
			return this._highlighted;
		}
		
		/**
		 * @private
		 */
		protected function set highlighted(value:Boolean):void
		{
			this._highlighted = value;
			this.invalidateProperties();
			this.invalidateSize();
			this.invalidateDisplayList();
		}
		
		/**
		 * @private
		 * Storage for the mouseIsOver property.
		 */
		private var _mouseIsOver:Boolean = false;
		
		/**
		 * @private
		 * Flag indicating that the mouse is over the jack.
		 */
		protected function get mouseIsOver():Boolean
		{
			return this._mouseIsOver;
		}
		
		/**
		 * @private
		 */
		protected function set mouseIsOver(value:Boolean):void
		{
			this._mouseIsOver = value;
			this.invalidateProperties();
			this.invalidateSize();
			this.invalidateDisplayList();
		}
		
		/**
		 * @private
		 * The jack's skin.
		 */
		protected var backgroundSkin:DisplayObject;
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		/**
		 * Checks if this jack is connected to another jack.
		 * 
		 * @param otherJack		The jack to check.
		 */
		public function isConnectedToJack(otherJack:WireJack):Boolean
		{
			return this.connectedJacks.indexOf(otherJack) >= 0;
		}
		
		/**
		 * Creates a connection between this jack and another jack.
		 * 
		 * @param otherJack		The other jack with which to create a connection
		 * 
		 * @return <code>true</code> if the connection is successful, and
		 * 	<code>false</code> if the connection is not successful. A
		 * 	connection may be unsuccessful for any number of reasons. However,
		 * 	the most likely reason for an unsuccessful connection is that the
		 * 	two jacks don't have compatible data formats.
		 */
		public function connectToJack(otherJack:WireJack):Boolean
		{
			return this.wireManager.connect(this, otherJack);
		}
		
		/**
		 * Destroys a connection between this jack and another jack.
		 * 
		 * @param otherJack		The other jack with which to destroy a connection
		 */
		public function disconnect(otherJack:WireJack):void
		{
			this.wireManager.disconnect(this, otherJack);
		}
		
		/**
		 * Destroys a connection between this jack and any other jacks that are
		 * connected to it.
		 */
		public function disconnectAll():void
		{
			var otherJackCount:int = this.connectedJacks.length;
			for(var i:int = 0; i < otherJackCount; i++)
			{
				var otherJack:WireJack = WireJack(this.connectedJacks[i]);
				this.disconnect(otherJack);
			}
		}
		
		/**
		 * Determines if this jack is compatible with another jack. By default,
		 * the following conditions must be met:
		 * 
		 * <ul>
		 * 	<li>The other jack cannot be <code>null</code>.</li>
		 * 	<li>The other jack cannot be equal to <code>this</code><li>
		 * 	<li>The other jack's <code>dataFormat</code> must be equal to this
		 * jack's <code>acceptedDataFormat</code>.</li>
		 * 	<li>This jack may not exceed its maximum number of connections.</li>
		 * </ul>
		 * 
		 * @param	The other jack used to check compatibility.
		 */
		public function isCompatibleWithJack(jack:WireJack):Boolean
		{
			return jack != null && jack != this && 
				this.connectedJacks.length < this.maxConnections &&
				jack.dataFormat == this.acceptedDataFormat &&
				this.ignoredJacks.indexOf(jack) < 0;
		}
		
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			var allStyles:Boolean = !styleProp || styleProp == "styleName";
			
			if(allStyles || styleProp == "skin")
			{
				this.invalidateProperties();
			}
		}
		
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			this.viewSkin();
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			
			if(this.backgroundSkin is IFlexDisplayObject)
			{
				this.measuredWidth = IFlexDisplayObject(this.backgroundSkin).measuredWidth;
				this.measuredHeight = IFlexDisplayObject(this.backgroundSkin).measuredHeight;
			}
			else
			{
				this.measuredWidth = this.backgroundSkin.width;
				this.measuredHeight = this.backgroundSkin.height;
			}
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var sizeSkin:Boolean = false;
			if(this.backgroundSkin is IInvalidating)
			{
				IInvalidating(this.backgroundSkin).validateNow();
				sizeSkin = true;
			}
			else if(this.backgroundSkin is IProgrammaticSkin)
			{
				IProgrammaticSkin(this.backgroundSkin).validateDisplayList();
				sizeSkin = true;
			}
			
			if(sizeSkin)
			{
				IFlexDisplayObject(this.backgroundSkin).setActualSize(unscaledWidth, unscaledHeight);
			}
		}
		
		/**
		 * @private
		 * Draws the jack's skin.
		 */
		protected function viewSkin():void
		{
			if(this.backgroundSkin)
			{
				this.removeChild(this.backgroundSkin);
				this.backgroundSkin = null;
			}
			
			var skinState:String;
			if(this.enabled)
			{
				if(this.connectedJacks.length > 0)
				{
					if(this.highlighted)
					{
						skinState = "connectedHighlightedSkin";
					}
					else if(this.mouseIsOver && this.connectedJacks.length < this.maxConnections)
					{
						skinState = "connectedOverSkin";
					}
					else
					{
						skinState = "connectedSkin";
					}
				}
				else
				{
					if(this.highlighted)
					{
						skinState = "highlightedSkin";
					}
					else if(this.mouseIsOver)
					{
						skinState = "overSkin";
					}
					else
					{
						skinState = "disconnectedSkin";
					}
				}
			}
			else
			{
				if(this.connectedJacks.length > 0)
				{
					skinState = "connectedDisabledSkin";
				}
				else
				{
					skinState = "disabledSkin";
				}
			}
			
			this.viewSkinForState("skin", skinState);
		}
		
		/**
		 * @private
		 * Draws the jack's current skin.
		 */
		protected function viewSkinForState(skinName:String, state:String):void
		{
			var skinClass:Object = this.getStyle(skinName);
			
			this.backgroundSkin = new skinClass();
			
			if(this.backgroundSkin is ISimpleStyleClient)
			{
				ISimpleStyleClient(this.backgroundSkin).styleName = this;
			}
			
			if(this.backgroundSkin is IUIComponent)
			{
				IUIComponent(this.backgroundSkin).enabled = enabled;
			}
			
			this.backgroundSkin.name = state;
			
			this.addChild(DisplayObject(this.backgroundSkin));
		}
		
		/**
		 * @private
		 * If this an event from the wire manager is associated with this
		 * jack, this function will return the other jack associated with the
		 * event. 
		 */
		protected function findOtherJack(event:WireManagerEvent):WireJack
		{
			//first, make sure this jack is even involved with the connection
			//attempt. if not, then we have nothing to worry about.
			if(this != event.startJack && this != event.endJack)
			{
				return null;
			}
			
			//if this jack is involved, determine which is the other jack
			var otherJack:WireJack = event.startJack;
			if(otherJack == this)
			{
				otherJack = event.endJack;
			}
			
			return otherJack;
		}
		
		/**
		 * @private
		 * We're not actually using the DragManager because AIR's version
		 * doesn't play nice with mouse events. That's okay, though. We can fake
		 * it nicely with DragProxy, which is where DragEvents come from.
		 */
		protected function createFakeDragProxy():void
		{
			var source:DragSource = new DragSource();
			source.addData(this, WIRE_JACK_DRAG_FORMAT);
			
			var dragImageType:Object = this.getStyle("dragImage");
			var dragImage:IFlexDisplayObject = TheInstantiator.newInstance(dragImageType) as IFlexDisplayObject;
			if(dragImage is ISimpleStyleClient)
			{
				ISimpleStyleClient(dragImage).styleName = this.getStyle("dragImageStyleName");
			}
			
			fakeDragProxy = new DragProxy(this, source);
			PopUpManager.addPopUp(fakeDragProxy, DisplayObject(this.parentApplication));
			fakeDragProxy.addChild(DisplayObject(dragImage));
			fakeDragProxy.setActualSize(this.width, this.height);
			dragImage.setActualSize(this.width, this.height);
		}
		
	//--------------------------------------
	//  Protected Event Handlers
	//--------------------------------------
		
		/**
		 * @private
		 * Begins listening for mouseMove to start a drag. If mouseUp happens
		 * before mouseMove, then there will be no drag (except when clickToDrag
		 * is set to true, of course, because a click happens after mouseUp).
		 */
		protected function mouseDownHandler(event:MouseEvent):void
		{
			//don't try to make more connections than this jack allows
			//or do anything if we're disabled
			if(this.wireManager.hasActiveConnectionRequest || this.connectedJacks.length == this.maxConnections || !this.enabled)
			{
				return;
			}
			
			this.systemManager.addEventListener(MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, false, 0, true);
			this.systemManager.addEventListener(MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, false, 0, true);
		}
		
		/**
		 * @private
		 * Begins a drag, if possible, when clickToDrag is true.
		 */
		protected function clickHandler(event:MouseEvent):void 
		{
			if(this.wireManager.hasActiveConnectionRequest || !clickToDrag || this.connectedJacks.length == this.maxConnections || !this.enabled)
			{
				return;
			}
			
			this.systemManager.addEventListener(MouseEvent.MOUSE_UP, connectionEndHandler);
			this.addEventListener(DragEvent.DRAG_COMPLETE, connectionEndHandler);
			
			this.wireManager.beginConnectionRequest(this);
			this.createFakeDragProxy();
		}
		
		/**
		 * @private
		 * Used for skin states.
		 */
		protected function rollOverHandler(event:MouseEvent):void
		{
			if(fakeDragProxy || DragManager.isDragging)
			{
				return;
			}
			
			this.mouseIsOver = true;
			this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}
		
		/**
		 * @private
		 * Used for skin states.
		 */
		protected function rollOutHandler(event:MouseEvent):void
		{
			this.mouseIsOver = false;
			this.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}
		
		/**
		 * @private
		 */
		protected function connectionEndHandler(event:Event):void
		{
			if(fakeDragProxy)
			{
				PopUpManager.removePopUp(fakeDragProxy);
				fakeDragProxy = null;
			}
			
			this.removeEventListener(DragEvent.DRAG_COMPLETE, connectionEndHandler);
			this.systemManager.removeEventListener(MouseEvent.MOUSE_UP, connectionEndHandler);
			this.systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler);
			this.wireManager.endConnectionRequest(this);
			
			//note: we don't care if the connection was successful here.
			//instead, the wire manager will notify us through an event that the
			//connection was made
		}
		
		/**
		 * @private
		 * Highlight and accept drag drop if the other jack is compatible.
		 */
		protected function dragEnterHandler(event:DragEvent):void
		{
			if(!this.enabled)
			{
				return;
			}
			
			var source:DragSource = event.dragSource;
			if(!source.hasFormat(WIRE_JACK_DRAG_FORMAT))
			{
				return;
			}
			
			var otherJack:WireJack = source.dataForFormat(WIRE_JACK_DRAG_FORMAT) as WireJack;
			//make sure both jacks are compatible
			if(this.isCompatibleWithJack(otherJack) && otherJack.isCompatibleWithJack(this))
			{
				this.addEventListener(DragEvent.DRAG_EXIT, dragExitHandler);
				this.addEventListener(DragEvent.DRAG_DROP, dragDropHandler);
				if(fakeDragProxy)
				{
					fakeDragProxy.target = this;
					fakeDragProxy.action = DragManager.LINK;
					fakeDragProxy.showFeedback();
				}
			}
		}
		
		/**
		 * @private
		 */
		protected function dragExitHandler(event:DragEvent):void
		{
			this.removeEventListener(DragEvent.DRAG_EXIT, dragExitHandler);
			this.removeEventListener(DragEvent.DRAG_DROP, dragDropHandler);
		}
		
		/**
		 * @private
		 * Assuming the data is compatible, connect this jack to the other one.
		 */
		protected function dragDropHandler(event:DragEvent):void
		{
			this.removeEventListener(DragEvent.DRAG_EXIT, dragExitHandler);
			this.removeEventListener(DragEvent.DRAG_DROP, dragDropHandler);
			
			var source:DragSource = event.dragSource;
			if(!source.hasFormat(WIRE_JACK_DRAG_FORMAT))
			{
				return;
			}
			
			var otherJack:WireJack = source.dataForFormat(WIRE_JACK_DRAG_FORMAT) as WireJack;
			this.wireManager.connect(otherJack, this);
		}
		
		/**
		 * @private
		 * Dragging starts after mouseDown when the user has moved the mouse;
		 */
		protected function systemManager_mouseMoveHandler(event:MouseEvent):void
		{
			this.systemManager.removeEventListener(MouseEvent.MOUSE_UP, systemManager_mouseUpHandler);
			this.systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler);
			this.systemManager.addEventListener(MouseEvent.MOUSE_UP, connectionEndHandler, false, 0, true);
			this.addEventListener(DragEvent.DRAG_COMPLETE, connectionEndHandler);
			
			this.wireManager.beginConnectionRequest(this);
			this.createFakeDragProxy();
		}
		
		/**
		 * @private
		 * Stop checking for a potential drag started with mouseDown.
		 */
		protected function systemManager_mouseUpHandler(event:MouseEvent):void
		{
			this.systemManager.removeEventListener(MouseEvent.MOUSE_UP, systemManager_mouseUpHandler);
			this.systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler);
		}
		
		/**
		 * @private
		 * This jack will be highlighted if it is compatible with a jack that
		 * is requesting a connection from the wire manager.
		 */
		protected function wireManager_beginConnectionRequestHandler(event:WireManagerEvent):void
		{
			var otherJack:WireJack = event.startJack;
			if(this.isCompatibleWithJack(otherJack) && otherJack.isCompatibleWithJack(this))
			{
				this.highlighted = true;
			}
		}
		
		/**
		 * @private
		 * Any time a connection request is ended, remove the highlight.
		 */
		protected function wireManager_endConnectionRequestHandler(event:WireManagerEvent):void
		{
			this.highlighted = false;
		}
	
		/**
		 * @private
		 */
		protected function wireManager_creatingConnectionHandler(event:WireManagerEvent):void
		{
			var otherJack:WireJack = this.findOtherJack(event);
			if(!otherJack)
			{
				return;
			}
			
			var connect:WireJackEvent = new WireJackEvent(WireJackEvent.CONNECTING_WIRE, otherJack, true);
			var result:Boolean = this.dispatchEvent(connect);
			if(!result)
			{
				event.preventDefault();
			}
		}
	
		/**
		 * @private
		 */
		protected function wireManager_createConnectionHandler(event:WireManagerEvent):void
		{
			var otherJack:WireJack = this.findOtherJack(event);
			if(!otherJack)
			{
				return;
			}
			
			//if we're all good, make the connection
			this._connectedJacks.push(otherJack);
			
			this.invalidateProperties();
			this.invalidateSize();
			this.invalidateDisplayList();
			
			var connect:WireJackEvent = new WireJackEvent(WireJackEvent.CONNECT_WIRE, otherJack, true);
			this.dispatchEvent(connect);
		}
		
		/**
		 * @private
		 * Removes a connection between jacks. If there is no connection, then
		 * it is ignored.
		 */
		protected function wireManager_deleteConnectionHandler(event:WireManagerEvent):void
		{
			var otherJack:WireJack = this.findOtherJack(event);
			if(!otherJack)
			{
				return;
			}
			
			//see if the other jack is in our connections
			var index:int = this.connectedJacks.indexOf(otherJack); 
			if(index < 0)
			{
				throw new Error(JACKS_NOT_CONNECTED_ERROR);
			}
			
			//if we found the other jack in our connections, remove it
			this._connectedJacks.splice(index, 1);
			
			var disconnect:WireJackEvent = new WireJackEvent(WireJackEvent.DISCONNECT_WIRE, otherJack);
			this.dispatchEvent(disconnect);
			
			this.invalidateProperties();
			this.invalidateSize();
			this.invalidateDisplayList();
		}
	}
}