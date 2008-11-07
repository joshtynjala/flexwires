package com.choppingblock.video{

	/**
	Constructs a YouTubeLoader object which uses ExternalInterface to interact with javascript
	within the "youTubeLoader.js" file to create an ActionScript 3 Wrapper for the YouTube
	chromeless player and API.

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
			
			// Create instance of YouTubeLoader and add it to display stack (EventListeners are optional)
			_youTubeLoader = new YouTubeLoader(); 
			_youTubeLoader.addEventListener(YouTubeLoaderEvent.LOADED, youTubePlayerLoadedHandler, false, 0, true);
			_youTubeLoader.addEventListener(YouTubeLoaderEvent.STATE_CHANGE, youTubePlayerStateChangeHandler, false, 0, true);
			_youTubeLoader.create(); //Creates actual Loader object
			_youTubeLoader.x = 290;
			_youTubeLoader.y = 27;
			addChild(_youTubeLoader);
		
		</code>

	*/

	import flash.display.*;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;

	public class YouTubeLoader extends Sprite {

		private static const CHROMELESS_PLAYER_URL:String="http://www.youtube.com/apiplayer?enablejsapi=1"
		private var _loader:Loader;
		private var _isReady:Boolean = false;
		private var _state:String;
		
		// ------------------------------------
		// CONSTRUCTOR
		// ------------------------------------

		public function YouTubeLoader () {
			//trace("YouTubeLoader");
			
			ExternalInterface.addCallback( "playerStateUpdateHandler", playerStateUpdateHandler)
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
		
		public function create ():void{
			//trace("YouTubeLoader: create");
			
			_loader = new Loader(); 
			//_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_loader.load(new URLRequest(CHROMELESS_PLAYER_URL));
			addChild(_loader);
		}
		
		public function destroy ():void{
			//trace("YouTubeLoader: destroy");
			
			_loader.unload();
			removeChild(_loader);
			//_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_loader = null;
		}
		
		// ------------------------------------
		// METHODS
		// ------------------------------------
		
		/**
		Called from External Interface when player is ready
		*/
		private function playerStateUpdateHandler (state:Number):void{
			//trace("YouTubeLoader: playerStateUpdateHandler for "+state);
			
			// if this is the first load we can dispatch our LOADED event 
			if ( (_isReady == false) && (state == -1) ){
				_isReady = true;
				var e:YouTubeLoaderEvent = new YouTubeLoaderEvent(YouTubeLoaderEvent.LOADED);
				dispatchEvent(e);
			}
			
			// update our status
			switch ( state ) {
				case -1 : 
					_state = "unstarted";
					break;
				case 0:
					_state = "ended"
					break;
				case 1:
					_state = "playing"
					break;
				case 2:
					_state = "paused"
					break;
				case 3:
					_state = "buffering"
					break;
				case 5:
					_state = "video cued"
					break;
			}
			
			// otherwise we can call a 
			var f:YouTubeLoaderEvent = new YouTubeLoaderEvent(YouTubeLoaderEvent.STATE_CHANGE, true, false, _state);
			dispatchEvent(f);
		}
		
		// ------------------------------------
		// YOUTUBE METHODS
		// ------------------------------------
		
		/**
		Loads and plays a YouTube video by id
		
		@param id:				id string of YouTube video
		@param startSeconds:	milliseconds into clip where playback begins
		*/
		public function loadVideoById (id:String, startSeconds:Number = 0):void{
			//trace("YouTubeLoader: loadVideoById");
			ExternalInterface.call("loadVideoById", id, startSeconds);
		}
		
		public function cueNewVideo (id:String, startSeconds:Number = 0):void{
			//trace("YouTubeLoader: cueNewVideo");
			ExternalInterface.call("cueNewVideo", id, startSeconds);
		}
	
		public function clearVideo ():void{
			//trace("YouTubeLoader: clearVideo");
			ExternalInterface.call("clearVideo");
		}
		
		public function setSize (w:Number, h:Number):void{
			//trace("YouTubeLoader: setSize");
			ExternalInterface.call("setSize", w, h);
		}
		
		public function play():void {
			//trace("YouTubeLoader: play");
			ExternalInterface.call("play");
		}

		public function pause():void {
			//trace("YouTubeLoader: pause");
			ExternalInterface.call("pause");
		}

		public function stop():void {
			//trace("YouTubeLoader: stop");
			ExternalInterface.call("stop");
		}
		
		public function seekTo(seconds:Number):void {
			//trace("YouTubeLoader: seekTo");
			ExternalInterface.call("seekTo", seconds);
		}
		
		public function getPlayerState():String {
			//trace("YouTubeLoader: getPlayerState");
			return ExternalInterface.call("getPlayerState");
		}
		
		public function getBytesLoaded():Number {
			//trace("YouTubeLoader: getBytesLoaded");
			return ExternalInterface.call("getBytesLoaded");
		}
		
		public function getBytesTotal():Number {
			//trace("YouTubeLoader: getBytesTotal");
			return ExternalInterface.call("getBytesTotal");
		}
		
		public function getCurrentTime():Number {
			//trace("YouTubeLoader: getCurrentTime");
			return ExternalInterface.call("getCurrentTime");
		}
		
		public function getDuration():Number {
			//trace("YouTubeLoader: getDuration");
			return ExternalInterface.call("getDuration");
		}
		
		public function getStartBytes():Number {
			//trace("YouTubeLoader: getStartBytes");
			return ExternalInterface.call("getStartBytes");
		}
		
		public function setVolume(newVolume:Number):void {
			//trace("YouTubeLoader: setVolume");
			ExternalInterface.call("setVolume", newVolume);
		}
		
		public function getVolume():Number {
			//trace("YouTubeLoader: getVolume");
			return ExternalInterface.call("getVolume");
		}
		
		public function mute():void {
			//trace("YouTubeLoader: mute");
			ExternalInterface.call("mute");
		}
		
		public function unMute():void {
			//trace("YouTubeLoader: unMute");
			ExternalInterface.call("unMute");
		}
		
		public function getEmbedCode():String {
			//trace("YouTubeLoader: getEmbedCode");
			return ExternalInterface.call("getEmbedCode");
		}
		
		public function getVideoUrl():String {
			//trace("YouTubeLoader: getVideoUrl");
			return ExternalInterface.call("getVideoUrl");
		}
		
		// ------------------------------------
		// EVENT METHODS
		// ------------------------------------
		
		private function ioErrorHandler(event:IOErrorEvent):void {
		    //trace("YouTubeLoader: ioErrorHandler: "+event.text);
			// tell the world
			var e:YouTubeLoaderEvent = new YouTubeLoaderEvent(YouTubeLoaderEvent.IO_ERROR);
			dispatchEvent(e);
		}
	};
};