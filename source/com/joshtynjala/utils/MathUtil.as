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

package com.joshtynjala.utils
{
	/**
	 * Some generic mathematical utility functions.
	 * 
	 * @author Josh Tynjala (joshblog.net)
	 */
	public class MathUtil
	{
		/**
		 * Calculate the factorial of an integer.
		 * 
		 * @param n			An integer for which to calculate the factorial.
		 * @return			The factorial of integer n.
		 */
		public static function factorial(n:int):Number
		{
			var result:Number = 1;
			for(var i:int = 1; i <= n; i++)
			{
				result *= i;
			}
			return result;
		}
		
		/**
		 * Calculate the binomial coefficient of two integers
		 * 
		 * @param n			A non-negative integer.
		 * @param k			An integer.
		 * @return			The binomial coefficient of n and k.
		 */
		public static function binomialCoefficient(n:int, k:int):Number
		{
			return factorial(n) / (factorial(k) * factorial(n - k));
		}
		
		/**
		 * Calculate the greatest common denominator of a set of numbers.
		 * 
		 * @param a			A numeric value.
		 * @param b			Another numeric value.
		 * @return			The greatest common denominator of the input numbers.
		 */
		public static function gcd(a:Number, b:Number, ...rest:Array):Number
		{
			//we need to require two parameters at minimum at compile time.
			//add them to the beginning of rest.
			rest.unshift(b);
			
			var divisor:Number = a;
			var count:int = rest.length;
			for(var i:int = 0; i < count; i++)
			{
				divisor = MathUtil.gcd2(divisor, Number(rest[i]));
			}
			return divisor;
		}
		
		/**
		 * @private
		 * The real implementation of gcd(). We call this while looping through
		 * the parameters.
		 */
		private static function gcd2(a:Number, b:Number):Number
		{
			if(a == 0) return b;

			var remainder:Number;
			while(b != 0)
			{
				remainder = a % b;
				a = b;
				b = remainder;
			}
			
			return a;
		}
		
		/**
		 * Calculates the sum of an Array of numbers.
		 * 
		 * @example The following example shows a fast way to find the sum of
		 * 		an Array of Numbers.
		 * <listing version="3.0">
		 * var numbers:Array = [1, 2, 3, 4, 5];
		 * var sum:Number = MathUtil.sum.apply(null, numbers);
		 * </listing>
		 */
		public static function sum(a:Number, b:Number, ...rest:Array):Number
		{
			//we need to require two parameters at minimum at compile time.
			//add them to the beginning of rest.
			rest.unshift(b);
			
			var sum:Number = a;
			var count:int = rest.length;
			for(var i:int = 0; i < count; i++)
			{
				sum += Number(rest[i]);
			}
			return sum;
		}

	}
}