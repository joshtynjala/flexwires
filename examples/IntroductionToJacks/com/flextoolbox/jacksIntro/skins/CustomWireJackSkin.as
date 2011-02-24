package com.flextoolbox.jacksIntro.skins
{
	import com.flextoolbox.controls.InputWireJack;
	import com.flextoolbox.controls.OutputWireJack;
	import com.flextoolbox.controls.WireJack;
	import com.yahoo.astra.utils.DynamicRegistration;
	
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import ws.tink.flex.skins.SpriteProgrammaticSkin;
	
	public class CustomWireJackSkin extends SpriteProgrammaticSkin
	{
		public function CustomWireJackSkin()
		{
			super();
			
			this.mouseChildren = false;
			this.arrow = new Shape();
			this.addChild(this.arrow);
		}
		
		protected var arrow:Shape;
		
		override public function get measuredWidth():Number
		{
			return 15;
		}
		
		override public function get measuredHeight():Number
		{
			return 15;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			this.graphics.clear();
			
			var connected:Boolean = this.name.toLowerCase().indexOf("connected") >= 0;
			var over:Boolean = this.name.toLowerCase().indexOf("over") >= 0;
			var highlighted:Boolean = this.name.toLowerCase().indexOf("highlighted") >= 0;
			
			var defaultShadowGradientColors:Array = [0x000000, 0x000000];
			var highlightedShadowGradientColors:Array = [0xFFFFFF, 0xFFFFFF];
			var shadowGradientColors:Array = highlighted ? highlightedShadowGradientColors : defaultShadowGradientColors;
			
			var defaultShadowGradientAlphas:Array = [0.011, 0.121];
			var highlightedShadowGradientAlphas:Array = [0, 0.57];
			var shadowGradientAlphas:Array = highlighted ? highlightedShadowGradientAlphas : defaultShadowGradientAlphas;
			
			var shadowMatrix:Matrix = new Matrix();
			shadowMatrix.createGradientBox(unscaledWidth + 2, unscaledHeight + 2, 90, -1, -1);
			this.graphics.lineGradientStyle(GradientType.LINEAR, shadowGradientColors, shadowGradientAlphas, [0x00, 0xff], shadowMatrix);
			this.graphics.drawEllipse(1, 1, unscaledWidth - 2, unscaledHeight - 2);
			
			var defaultFillColors:Array = [0xFFFFFF, 0xD8D8D8];
			var overFillColors:Array = [0xBBBDBD, 0x9FA0A1];
			var highlightFillColors:Array = [0xAAAAAA, 0x929496];
			
			var fillColors:Array = defaultFillColors;
			if(over)
			{
				fillColors = overFillColors;
			}
			else if(highlighted)
			{
				fillColors = highlightFillColors
			}
			
			var fillMatrix:Matrix = new Matrix();
			fillMatrix.createGradientBox(unscaledWidth - 2, unscaledHeight - 2, 90, 1, 1);
			this.graphics.lineStyle(1, 0x000000, 1);
			this.graphics.lineGradientStyle(GradientType.LINEAR, [0x000000, 0x000000], [0.7, 0.8], [0x00, 0xff], fillMatrix);
			this.graphics.beginGradientFill(GradientType.LINEAR, fillColors, [0.85, 0.85], [0x00, 0xff], fillMatrix);
			this.graphics.drawEllipse(1, 1, unscaledWidth - 2, unscaledHeight - 2);
			this.graphics.endFill();
			
			this.arrow.graphics.clear();
			if(!(this.parent is OutputWireJack) && !(this.parent is InputWireJack))
			{
				//we can only display the connection angle arrow if we're
				//using an input jack or an output jack.
				return;
			}
			
			var extraRotation:Number = this.parent is OutputWireJack ? 180 : 0;
			
			var themeColor:uint = this.getStyle("themeColor");
			var arrowColor:uint = highlighted ? themeColor : 0xcccccc;
			this.drawArrow(6, 10, arrowColor);
			
			var jack:WireJack = WireJack(this.parent);
			
			var angle:Number = jack.connectionAngle;
			
			this.arrow.x = unscaledWidth + 2;
			this.arrow.y = (unscaledHeight - 10) / 2;
			this.arrow.rotation = 0;
			
			var regPoint:Point = new Point(-2 - unscaledWidth / 2, 5);
			
			DynamicRegistration.rotate(this.arrow, regPoint, -angle);
			DynamicRegistration.rotate(this.arrow, new Point(3, 5), this.arrow.rotation + extraRotation);
		}
		
		protected function drawArrow(width:Number, height:Number, fillColor:uint):void
		{
			this.arrow.graphics.lineStyle(0, 0, 0);
			this.arrow.graphics.beginFill(fillColor);
			this.arrow.graphics.moveTo(0, height / 2);
			this.arrow.graphics.lineTo(width, 0);
			this.arrow.graphics.lineTo(width, height);
			this.arrow.graphics.lineTo(0, height / 2);
			this.arrow.graphics.endFill();
		}
	}
}