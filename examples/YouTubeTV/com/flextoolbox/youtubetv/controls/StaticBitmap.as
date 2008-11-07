package com.flextoolbox.youtubetv.controls
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;

	/**
	 * A bitmap that displays static like a television.
	 * 
	 * @author Josh Tynjala
	 */
	public class StaticBitmap extends Bitmap
	{
		/**
		 * Constructor.
		 */
		public function StaticBitmap(bitmapWidth:Number, bitmapHeight:Number)
		{
			var bitmapData:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, false, 0x000000)
			super(bitmapData, "auto", false);
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * @private
		 * While we're on stage, we need to update the static every frame.
		 */
		private function addedToStageHandler(event:Event):void
		{
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * @private
		 * Stop updating the static if we're not on the stage.
		 */
		private function removedFromStageHandler(event:Event):void
		{
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}
		
		/**
		 * @private
		 * Fill the bitmap data with noise to simulate TV static.
		 */
		private function enterFrameHandler(event:Event):void
		{
			if(!this.bitmapData)
			{
				return;
			}
			var seed:int = int(Math.random() * int.MAX_VALUE);
			this.bitmapData.noise(seed, 0, 0xff, 7, true);
		}
		
	}
}