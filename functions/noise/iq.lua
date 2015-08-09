--- Mixins for "iq" noise.

--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
--

-- Export the functions.
return {
	ignore = { "hash" },

	[[
		// Created by inigo quilez - iq/2013
		// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
		P_POSITION float hash (P_UV float n)
		{
		#if GL_FRAGMENT_PRECISION_HIGH
			return fract(sin(n) * 4375.85453);
		#else
			return fract(sin(n) * 43.7585453);
		#endif
			// TODO: Find a way to detect the precision and tune these!
		}

		// Created by inigo quilez - iq/2013
		// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
		P_POSITION float IQ (P_POSITION vec2 x)
		{
			P_POSITION vec2 p = floor(x);
			P_POSITION vec2 f = fract(x);

			f = f * f * (3.0 - 2.0 * f);

			P_POSITION float n = p.x + p.y * 57.0;

			return mix(mix(hash(n +  0.0), hash(n +  1.0), f.x),
					   mix(hash(n + 57.0), hash(n + 58.0), f.x), f.y);
		}
	]]
}