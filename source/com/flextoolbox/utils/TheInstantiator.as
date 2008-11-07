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

package com.flextoolbox.utils
{
	import flash.utils.getDefinitionByName;
	
	import mx.core.IFactory;
	import mx.styles.ISimpleStyleClient;
	
	/**
	 * Utility for creating instances of Flex sub-components or skins.
	 * 
	 * @author Josh Tynjala (joshblog.net)
	 */
	public class TheInstantiator
	{
		/**
		 * Creates a new instance of an object. Supports Class, Function, a
		 * fully-qualified class name String, or mx.core.IFactory.
		 * 
		 * @param type			The type to instantiate
		 * @param styleName		The styleName to set if the instantiated object supports styles.
		 */
		public static function newInstance(type:Object, styleName:String = null):Object
		{	
			var instance:Object = null;
			
			//first check whether type is a String.
			//if so, try to convert to a class
			if(type is String)
			{
				try
				{
					//will throw an error if it's not a fully qualified class name
					type = getDefinitionByName(type as String);
				}
				catch(error:Error)
				{
					return null;
				}
			}
			
			//Class and Function may be used with the new keyword
			if(type is Class || type is Function)
			{
				instance = new type();
			}
			else if(type is IFactory)
			{
				//mmmmm... factories are great
				instance = IFactory(type).newInstance();
			}
			
			//if the new instance supports styles, set the styleName property.
			if(instance is ISimpleStyleClient)
			{
				ISimpleStyleClient(instance).styleName = styleName;
			}
			
			return instance;
		}
	}
}