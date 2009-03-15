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

package com.flextoolbox.controls
{

	[Exclude(name="acceptedDataFormat", kind="property")]

	/**
	 * A specialized WireJack designed to send data to compatible input jacks.
	 * 
	 * @see InputWireJack
	 * @author Josh Tynjala (joshblog.net)
	 */
	public class OutputWireJack extends WireJack
	{
		
	//--------------------------------------
	//  Static Properties
	//--------------------------------------
	
		/**
		 * @private
		 * Error that is thrown when a developer tries to set the dataFormat
		 * property.
		 */
		private static const SET_ACCEPTED_DATA_FORMAT_ERROR:String = "Cannot set acceptedDataFormat property on OutputWireJack. Only dataFormat may be changed.";
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		/**
		 * Constructor.
		 */
		public function OutputWireJack()
		{
			super();
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
	
		/**
		 * @inheritDoc
		 * 
		 * <p><strong>Important:</strong> The <code>acceptedDataFormat</code>
		 * property of an OutputWireJack cannot be changed. This value is equal
		 * to the value of InputWireJack's <code>dataFormat</code> property.</p>
		 */
		override public function get acceptedDataFormat():String
		{
			return InputWireJack.INPUT_DATA_FORMAT;
		}
		
		/**
		 * @private
		 */
		override public function set acceptedDataFormat(value:String):void
		{
			throw OutputWireJack.SET_ACCEPTED_DATA_FORMAT_ERROR;
		}
		
	}
}