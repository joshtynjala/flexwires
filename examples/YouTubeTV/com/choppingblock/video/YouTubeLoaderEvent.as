package com.choppingblock.video{

	/**
	Constructs a YouTubeLoaderEvent object

	@author Matthew Richmond <matthew@choppingblock.com>
	@version 1.0
	@history 2008-10-07
	
	@Copyright 2008 Matthew Richmond <matthew@choppingblock.com>
    * 
	* This file is part of Sawdust, a collection of useful frameworks
	* managed by the folks at The Chopping Block, Inc.
    * 
	* Sawdust is free software: you can redistribute it and/or modify
	* it under the terms of the GNU Lesser General Public License as published by
	* the Free Software Foundation, either version 3 of the License, or
	* (at your option) any later version.
    * 
	* Sawdust is distributed in the hope that it will be useful,
	* but WITHOUT ANY WARRANTY; without even the implied warranty of
	* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	* GNU Lesser General Public License for more details.
    * 
	* You should have received a copy of the GNU Lesser General Public License
	* along with Sawdust.  If not, see <http://www.gnu.org/licenses/>.

	@usage
	Activate with:
		<code>

		</code>

	*/

	import flash.events.Event;
	
	public class YouTubeLoaderEvent extends Event {

		public static const LOADED:String = "YouTubeLoaderEvent: Loaded";
		public static const STATE_CHANGE:String = "YouTubeLoaderEvent: State Change";
		public static const IO_ERROR:String = "YouTubeLoaderEvent: IO Error";
		
		/**
		 * A text message that can be passed to an event handler
		 * with this event object.
		 */
		public var state:String;

		// ------------------------------------
		// CONSTRUCTOR
		// ------------------------------------

		/**
	 	 *  Constructor.
		 *  @param message The message of the event.
		 */
		public function YouTubeLoaderEvent (type:String, bubbles:Boolean = false, cancelable:Boolean = false, state:String = undefined) {
			// Pass constructor parameters to the superclass constructor
			super(type, bubbles, cancelable);
			
			this.state = state;		
		}

		// ------------------------------------
		// ACCESSORS
		// ------------------------------------

		// ------------------------------------
		// INIT METHODS
		// ------------------------------------

		// ------------------------------------
		// CREATE / DESTROY
		// ------------------------------------
		
		// ------------------------------------
		// METHODS
		// ------------------------------------
		
		/**
		* Creates and returns a copy of the current instance.
		* @return A copy of the current instance.
		*/
		public override function clone():Event {
			return new YouTubeLoaderEvent(type, bubbles, cancelable, state);
		}

		/**
		 * Returns a String containing all the properties of the current
		 * instance.
		 * @return A string representation of the current instance.
		 */
		public override function toString():String {
			return formatToString("YouTubeLoaderEvent", "type", "bubbles", "cancelable", "eventPhase", "state");
		}
		
		// ------------------------------------
		// EVENT METHODS
		// ------------------------------------
	};
};

