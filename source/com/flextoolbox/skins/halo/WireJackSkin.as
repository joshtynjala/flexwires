////////////////////////////////////////////////////////////////////////////////
//
// 	The contents of this file are subject to the Mozilla Public License
//	Version 1.1 (the "License"); you may not use this file except in
//	compliance with the License. You may obtain a copy of the License at
//	http://www.mozilla.org/MPL/
//
//	Software distributed under the License is distributed on an "AS IS"
//	basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
//	License for the specific language governing rights and limitations
//	under the License.
//
//	The Original Code is from the Open Source Flex 3 SDK.
//
//	The Initial Developer of the Original Code is Adobe Systems, Inc.
//
//	Portions created by Josh Tynjala (joshblog.net) are
//	Copyright (C) 2008 Josh Tynjala. All Rights Reserved.
//
////////////////////////////////////////////////////////////////////////////////

package com.flextoolbox.skins.halo
{
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	
	import mx.skins.Border;
	import mx.skins.halo.HaloColors;
	import mx.styles.StyleManager;
	import mx.utils.ColorUtil;
	
	/**
	 * The skin for all the states of a WireJack.
	 * 
	 * <p>Based on the Halo-style RadioButton icon.</p>
	 */
	public class WireJackSkin extends Border
	{
		/**
		 * @private
		 */
		private static var cache:Object = {};
		
		/**
		 * @private
		 * Several colors used for drawing are calculated from the base colors
		 * of the component (themeColor, borderColor and fillColors).
		 * Since these calculations can be a bit expensive,
		 * we calculate once per color set and cache the results.
		 */
		private static function calcDerivedStyles(themeColor:uint,
			borderColor:uint, fillColor0:uint,
												  fillColor1:uint):Object
		{
			var key:String = HaloColors.getCacheKey(themeColor, borderColor, fillColor0, fillColor1);
			if(!cache[key])
			{
				var o:Object = cache[key] = {};
				
				// Cross-component styles
				HaloColors.addHaloColors(o, themeColor, fillColor0, fillColor1);
				
				// RadioButton-unique styles
				o.borderColorDrk1 = ColorUtil.adjustBrightness2(borderColor, -60);
			}
			
			return cache[key];
		}
		
		/**
		 * Constructor.
		 */
		public function WireJackSkin()
		{
			super();
		}
		
	    /**
	     * @private
	     */    
	    override public function get measuredWidth():Number
	    {
	        return 14;
	    }
	    
	    /**
	     * @private
	     */        
	    override public function get measuredHeight():Number
	    {
	        return 14;
	    }
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
	
			// User-defined styles
			var radioColor:uint = getStyle("iconColor");
			var borderColor:uint = getStyle("borderColor");
			var fillAlphas:Array = getStyle("fillAlphas");
			var fillColors:Array = getStyle("fillColors");
			StyleManager.getColorNames(fillColors);
			var highlightAlphas:Array = getStyle("highlightAlphas");		
			var themeColor:uint = getStyle("themeColor");
			
			// Derived styles
			var derStyles:Object = calcDerivedStyles(themeColor, borderColor,
													 fillColors[0], fillColors[1]);
			var borderColorDrk1:Number =
				ColorUtil.adjustBrightness2(borderColor, -50);
			
			var themeColorDrk1:Number =
				ColorUtil.adjustBrightness2(themeColor, -25);
			
			var r:Number = width / 2;
			
			var upFillColors:Array;
			var upFillAlphas:Array;
	
			var disFillColors:Array;
			var disFillAlphas:Array;
	
			var g:Graphics = graphics;
			
			g.clear();
			
			switch (name)
			{			
				case "disconnectedSkin":
				{
	   				upFillColors = [ fillColors[0], fillColors[1] ];
					upFillAlphas = [ fillAlphas[0], fillAlphas[1] ];
	
					// border
					g.beginGradientFill(GradientType.LINEAR, 
										[ borderColor, borderColorDrk1 ],
										[100, 100], [ 0, 0xFF],
										verticalGradientMatrix(0, 0, w, h));
					g.drawCircle(r, r, r);
					g.drawCircle(r, r, (r - 1));
					g.endFill();
	
						// radio fill
					g.beginGradientFill(GradientType.LINEAR, 
										upFillColors,
										upFillAlphas, [ 0, 0xFF ],
										verticalGradientMatrix(1, 1, w - 2, h - 2));
					g.drawCircle(r, r, (r - 1));
					g.endFill();
	
					// top highlight
					drawRoundRect(
						1, 1, w - 2, (h - 2) / 2, 
						{ tl: r, tr: r, bl: 0, br: 0 },
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						verticalGradientMatrix(0, 0, w - 2, (h - 2) / 2 )); 
	
					break;
				}
	
				case "highlightedSkin":
				{
					// border
					g.beginGradientFill(
						GradientType.LINEAR,
						[ themeColor, themeColorDrk1 ], [ 100, 100 ], [ 0, 0xFF ],
						verticalGradientMatrix(0, 0, w, h));
					g.drawCircle(r, r, r);
					g.endFill();
						
					// radio fill
					g.beginGradientFill(
						GradientType.LINEAR,
						[ derStyles.fillColorPress1, derStyles.fillColorPress2 ],
						[ 100, 100 ], [ 0, 0xFF ],
						verticalGradientMatrix(1, 1, w - 2, h - 2));
					g.drawCircle(r, r, (r - 1));
					g.endFill();
					
					// top highlight
					drawRoundRect(
						1, 1, w - 2, (h - 2) / 2, 
						{ tl: r, tr: r, bl: 0, br: 0 },
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						verticalGradientMatrix(0, 0, w - 2, (h - 2) / 2)); 
	
					break;
				}
				
				case "overSkin":
				{
					var overFillColors:Array;
					if (fillColors.length > 2)
						overFillColors = [ fillColors[2], fillColors[3] ];
					else
						overFillColors = [ fillColors[0], fillColors[1] ];
	
					var overFillAlphas:Array;
					if (fillAlphas.length > 2)
						overFillAlphas = [ fillAlphas[2], fillAlphas[3] ];
	  				else
						overFillAlphas = [ fillAlphas[0], fillAlphas[1] ];
	
					// border
					g.beginGradientFill(
						GradientType.LINEAR, 
						[ themeColor, themeColorDrk1 ], [ 100, 100 ], [ 0, 0xFF ],
						verticalGradientMatrix(0, 0, w, h));
					g.drawCircle(r, r, r);
					g.drawCircle(r, r, r - 1);
					g.endFill();
	
					// radio fill
					g.beginGradientFill(
						GradientType.LINEAR,
						overFillColors, overFillAlphas, [ 0, 0xFF ],
						verticalGradientMatrix(1, 1, w - 2, h - 2));
					g.drawCircle(r, r, (r - 1));
					g.endFill();
					
					// top highlight
					drawRoundRect(
						1, 1, w - 2, (h - 2) / 2, 
						{ tl: r, tr: r, bl: 0, br: 0 },
						[ 0xFFFFFF, 0xFFFFFF ],
						highlightAlphas,
						verticalGradientMatrix(0, 0, w - 2, (h - 2) / 2)); 
	
					break;
				}
				
				case "disabledSkin":
				{
	   				disFillColors = [ fillColors[0], fillColors[1] ];
					disFillAlphas = [ Math.max( 0, fillAlphas[0] - 0.15),
									  Math.max( 0, fillAlphas[1] - 0.15) ];
	
					g.beginGradientFill(
						GradientType.LINEAR,
						[ borderColor, borderColorDrk1 ], [ 0.5, 0.5 ], [ 0, 0xFF ],
						verticalGradientMatrix(0, 0, w, h));
					g.drawCircle(r, r, r);
					g.drawCircle(r, r, (r - 1));
					g.endFill();
					
					g.beginGradientFill(
						GradientType.LINEAR, 
						disFillColors, disFillAlphas, [ 0, 0xFF ],
						verticalGradientMatrix(1, 1, w - 2, h - 2));
					g.drawCircle(r, r, (r - 1));
					g.endFill();
					
					break;
				}
								
				case "connectedSkin":
				{
	   				upFillColors = [ fillColors[0], fillColors[1] ];
					upFillAlphas = [ fillAlphas[0], fillAlphas[1] ];
	
					// border
					g.beginGradientFill(
						GradientType.LINEAR,
						[ borderColor, borderColorDrk1 ], [ 100, 100 ], [ 0, 0xFF ],
						verticalGradientMatrix(0, 0, w, h));
					g.drawCircle(r, r, r);
					g.drawCircle(r, r, (r - 1));
					g.endFill();
	
					// radio fill
					g.beginGradientFill(
						GradientType.LINEAR, 
						upFillColors, upFillAlphas, [ 0, 0xFF],
						verticalGradientMatrix(1, 1, w - 2, h - 2));
					g.drawCircle(r, r, (r - 1));
					g.endFill();
	
					// top highlight
					drawRoundRect(
						1, 1, w - 2, (h - 2) / 2, 
						{ tl: r, tr: r, bl: 0, br: 0 },
						[0xFFFFFF, 0xFFFFFF], highlightAlphas,
						verticalGradientMatrix(0, 0, w - 2, (h - 2) / 2));
	
					// radio symbol
					g.beginFill(radioColor);
					g.drawCircle(r, r, 2);
					g.endFill();
					
					break;
				}
				
				case "connectedOverSkin":
				{
					if (fillColors.length > 2)
						overFillColors = [ fillColors[2], fillColors[3] ];
					else
						overFillColors = [ fillColors[0], fillColors[1] ];
	
					if (fillAlphas.length > 2)
						overFillAlphas = [ fillAlphas[2], fillAlphas[3] ];
	  				else
						overFillAlphas = [ fillAlphas[0], fillAlphas[1] ];
	
					// border
					g.beginGradientFill(
						GradientType.LINEAR, 
						[ themeColor, themeColorDrk1 ], [ 100, 100 ], [ 0, 0xFF ],
						verticalGradientMatrix(0, 0, w, h));
					g.drawCircle(r, r, r);
					g.drawCircle(r, r, r - 1);
					g.endFill();
	
					// radio fill
					g.beginGradientFill(
						GradientType.LINEAR,
						overFillColors, overFillAlphas, [ 0, 0xFF ],
						verticalGradientMatrix(1, 1, w - 2, h - 2));
					g.drawCircle(r, r, (r - 1));
					g.endFill();
					
					// top highlight
					drawRoundRect(
						1, 1, w - 2, (h - 2) / 2, 
						{ tl: r, tr: r, bl: 0, br: 0 },
						[ 0xFFFFFF, 0xFFFFFF ],
						highlightAlphas,
						verticalGradientMatrix(0, 0, w - 2, (h - 2) / 2)); 
	
	
					// radio symbol
					g.beginFill(radioColor);
					g.drawCircle(r, r, 2);
					g.endFill();
					
					break;
				}
	
	
				case "connectedHighlightedSkin":
				{
					// border
					g.beginGradientFill(
						GradientType.LINEAR,
						[ themeColor, themeColorDrk1 ], [ 100, 100 ], [ 0, 0xFF ],
						verticalGradientMatrix(0, 0, w, h));
					g.drawCircle(r, r, r);
					g.endFill();
						
					// radio fill
					g.beginGradientFill(
						GradientType.LINEAR,
						[ derStyles.fillColorPress1, derStyles.fillColorPress2 ],
						[ 100, 100 ], [ 0, 0xFF ],
						verticalGradientMatrix(1, 1, w - 2, h - 2));
					g.drawCircle(r, r, (r - 1));
					g.endFill();
					
					// top highlight
					drawRoundRect(
						1, 1, w - 2, (h - 2) / 2, 
						{ tl: r, tr: r, bl: 0, br: 0 },
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						verticalGradientMatrix(0, 0, w - 2, (h - 2) / 2)); 
	
					// radio symbol
					g.beginFill(radioColor);
					g.drawCircle(r, r, 2);
					g.endFill();
					
					break;
				}
				
				case "connectedDisabledSkin":
				{
	   				disFillColors = [ fillColors[0], fillColors[1] ];
					disFillAlphas = [ Math.max( 0, fillAlphas[0] - 0.15),
									  Math.max( 0, fillAlphas[1] - 0.15) ];
	
					// border
					g.beginGradientFill(
						GradientType.LINEAR,
						[ borderColor, borderColorDrk1 ], [ 0.5, 0.5 ], [ 0, 0xFF ],
						verticalGradientMatrix(0, 0, w, h));
					g.drawCircle(r, r, r);
					g.drawCircle(r, r, (r - 1));
					g.endFill();
					
					// radio fill
					g.beginGradientFill(
						GradientType.LINEAR,
						disFillColors, disFillAlphas, [ 0, 0xFF],
						verticalGradientMatrix(1, 1, w - 2, h - 2));
					g.drawCircle(r, r, (r - 1));
					g.endFill();
					
					radioColor = getStyle("disabledIconColor");
					
					// radio symbol
					g..beginFill(radioColor);
					g..drawCircle(r, r, 2);
					g..endFill();
					
					break;
				}
			}
		}
	}

}
