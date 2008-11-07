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

package com.flextoolbox.controls.wireClasses
{
	import com.flextoolbox.controls.WireJack;
	import com.flextoolbox.managers.IWireManager;
	
	import mx.core.IUIComponent;
	
	/**
	 * Renderers used by an IWireManager must implement this interface.
	 * 
	 * @see com.flextoolbox.managers.IWireManager
	 * @author Josh Tynjala (joshblog.net)
	 */
	public interface IWireRenderer extends IUIComponent
	{
		/**
		 * A jack to which this wire is connected.
		 */
		function get jack1():WireJack;
		
		/**
		 * @private
		 */
		function set jack1(value:WireJack):void;
		
		/**
		 * Another jack to which this wire is connected.
		 */
		function get jack2():WireJack;
		
		/**
		 * @private
		 */
		function set jack2(value:WireJack):void;
		
		/**
		 * The manager that displays and controls this wire.
		 */
		function get wireManager():IWireManager;
		
		/**
		 * @private
		 */
		function set wireManager(value:IWireManager):void;
		
		/**
		 * Removes the wire, if it is connected to any jacks.
		 */
		function disconnect():void;
	}
}