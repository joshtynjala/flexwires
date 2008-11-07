package com.flextoolbox.youtubetv.controls
{
	import com.choppingblock.video.YouTubeLoader;
	import com.choppingblock.video.YouTubeLoaderEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.effects.Fade;
	import mx.events.EffectEvent;

	[Event(name="videoReady")]

	/**
	 * A YouTube video player that looks like a retro television.
	 * 
	 * @author Josh Tynjala
	 */
	public class Television extends UIComponent
	{
		
		[Embed(source="/assets/Skins.swf",symbol="Television")]
		/**
		 * @private
		 * The main television skin.
		 */
		private static const TV_SKIN:Class;
		
		[Embed(source="/assets/Skins.swf",symbol="ScreenMask")]
		/**
		 * @private
		 * A mask in the shape of the skin's screen to use on the video.
		 */
		private static const SCREEN_MASK_SHAPE:Class;
		
		[Embed(source="/assets/Skins.swf",symbol="ScreenOverlay")]
		/**
		 * @private
		 * An overlay for the screen of that goes above the video.
		 */
		private static const SCREEN_OVERLAY_SKIN:Class;
		
		/**
		 * Constructor.
		 */
		public function Television()
		{
			super();
		}
		
		/**
		 * @private
		 * The main TV skin.
		 */
		private var _skin:DisplayObject;
		
		/**
		 * @private
		 * The YouTube video player.
		 */
		private var _youTubePlayer:YouTubeLoader;
		
		/**
		 * @private
		 * A mask for the video player to fit the skin's screen area.
		 */
		private var _screenMask:DisplayObject;
		
		/**
		 * @private
		 * When the TV doesn't have a video signal (videoActive), then static
		 * will be displayed.
		 */
		private var _staticView:StaticBitmap;
		
		/**
		 * @private
		 * The Fade effect we use for the static.
		 */
		private var _fade:Fade;
		
		/**
		 * @private
		 * Flag indicating that the video player is playing.
		 */
		private var _isPlaying:Boolean = false;
		
		/**
		 * @private
		 * Flag indicating that the videoActive property has changed.
		 */
		private var _videoActiveChanged:Boolean = false;
		
		/**
		 * @private
		 * Storage for the videoActive property.
		 */
		private var _videoActive:Boolean = false;
		
		[Bindable]
		/**
		 * If true, the static should fade out and the video should be visible.
		 */
		public function get videoActive():Boolean
		{
			return this._videoActive;
		}
		
		/**
		 * @private
		 */
		public function set videoActive(value:Boolean):void
		{
			this._videoActive = value;
			this._videoActiveChanged = true;
			this.invalidateProperties();
		}
		
		/**
		 * @private
		 * Flag indicating that the audioActive property has changed.
		 */
		private var _audioActiveChanged:Boolean = false;
		
		/**
		 * @private
		 * Storage for the audioActive property.
		 */
		private var _audioActive:Boolean = false;
		
		[Bindable]
		/**
		 * If true, the audio should be audible.
		 */
		public function get audioActive():Boolean
		{
			return this._audioActive;
		}
		
		/**
		 * @private
		 */
		public function set audioActive(value:Boolean):void
		{
			this._audioActive = value;
			this._audioActiveChanged = true;
			this.invalidateProperties();
		}
		
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			this._skin = new TV_SKIN();
			this.addChild(this._skin);
			
			var content:Sprite = new Sprite();
			content.x = 40;
			content.y = 20;
			this.addChild(content);
			
			this._youTubePlayer = new YouTubeLoader();
			this._youTubePlayer.addEventListener(YouTubeLoaderEvent.LOADED, youTubePlayerLoadedHandler);
			this._youTubePlayer.addEventListener(YouTubeLoaderEvent.IO_ERROR, youTubePlayerIOErrorHandler);
			this._youTubePlayer.create();
			
			content.addChild(this._youTubePlayer);
			
			this._screenMask = new SCREEN_MASK_SHAPE();
			content.mask = this._screenMask;
			content.addChild(this._screenMask);
			
			this._staticView = new StaticBitmap(this._screenMask.width, this._screenMask.height);
			content.addChild(this._staticView);
			
			var overlay:Sprite = new SCREEN_OVERLAY_SKIN();
			this.addChild(overlay);
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if((this._videoActive || this._audioActive) && !this._isPlaying)
			{
				this._isPlaying = true;
				this._youTubePlayer.play();
			}
			
			if(this._videoActiveChanged)
			{
				if(this._fade)
				{
					this._fade.stop();
					this._fade.removeEventListener(EffectEvent.EFFECT_END, fadeEffectEndHandler);
					this._fade = null;
				}
				
				//show or hide the static
				this._fade = new Fade(this._staticView);
				if(this._videoActive)
				{
					this._fade.alphaTo = 0;
				}
				else
				{
					this._fade.alphaTo = 1;
				}
				this._fade.addEventListener(EffectEvent.EFFECT_END, fadeEffectEndHandler);
				this._fade.play();
				
				this._videoActiveChanged = false;
			}
			
			if(this._audioActiveChanged)
			{
				if(this._audioActive)
				{
					this._youTubePlayer.setVolume(100);
				}
				else
				{
					this._youTubePlayer.setVolume(0);
				}
				this._audioActiveChanged = false;
			}
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			this.measuredWidth = this._skin.width;
			this.measuredHeight = this._skin.height;
		}
		
		/**
		 * @private
		 * Turn off the sound and pre-load our very special video.
		 */
		private function initVideo():void
		{
			//once it starts playing, we're going to stop it, so listen for the state change
			this._youTubePlayer.addEventListener(YouTubeLoaderEvent.STATE_CHANGE, youTubePlayerStateChangeHandler);

			//turn off the sound until the audio cable is connected.
			this._youTubePlayer.setVolume(0);
			
			//match the width and height
			//this._youTubePlayer.setSize(this._screenMask.width, this._screenMask.height);
			this._youTubePlayer.width = this._screenMask.width;
			this._youTubePlayer.height = this._screenMask.height; 

			//load our awesome video
			this._youTubePlayer.loadVideoById("oHg5SJYRHA0");
		}
		
		/**
		 * @private
		 * Here's where we tell the outside world that we're ready.
		 */
		private function finishVideoPreparation():void
		{
			this._youTubePlayer.pause();
			this.dispatchEvent(new Event("videoReady"));
		}
		
		/**
		 * @private
		 * Once we're communicating with the YouTube player, we need to load
		 * our video.
		 */
		private function youTubePlayerLoadedHandler(event:YouTubeLoaderEvent):void
		{
			this.callLater(initVideo);
		}
		
		/**
		 * @private
		 * Handle IOErrors from the YouTube player.
		 */
		private function youTubePlayerIOErrorHandler(event:YouTubeLoaderEvent):void
		{
			trace("ERROR!");
		}
		
		/**
		 * @private
		 * Once the video starts playing, pause it. We'll restart once the wire is connected.
		 */
		private function youTubePlayerStateChangeHandler(event:YouTubeLoaderEvent):void
		{
			//we only care if the state is playing because we want to pause it
			if(event.state != "playing")
			{
				return;
			}
			
			//stop listening for state changes. we only need to pause once.
			this._youTubePlayer.removeEventListener(YouTubeLoaderEvent.STATE_CHANGE, youTubePlayerStateChangeHandler);
			this.callLater(finishVideoPreparation);
		}
		
		/**
		 * @private
		 * Once the static finishes fading in or out, clean it up.
		 */
		private function fadeEffectEndHandler(event:EffectEvent):void
		{
			this._fade.removeEventListener(EffectEvent.EFFECT_END, fadeEffectEndHandler);
			this._fade = null;
		}
	}
}