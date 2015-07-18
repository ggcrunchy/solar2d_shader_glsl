--- Mixins to acquire data sent by @{corona_shader.encode.vars} routines.

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

[[
	vec2 UnitPair (float xy)
	{
		P_UV float axy = abs(xy);
		P_UV float frac = fract(axy);

		return vec2((axy - frac) / 1023., sign(xy) * frac + .5);
	}
]], [[
	void UnitPair4_Out (vec4 xy, out vec4 x, out vec4 y)
	{
		P_UV vec4 axy = abs(xy);
		P_UV vec4 frac = fract(axy);

		x = (axy - frac) / 1023.;
		y = sign(xy) * frac + .5;
	}
]], [[
	P_UV vec2 TenBitsPair (P_DEFAULT float xy)
	{
		P_DEFAULT float axy = abs(xy);

		// Select the 2^16-wide floating point range. The first element in this range is 1 *
		// 2^bin, while the ulp will be 2^bin / 2^16 or, equivalently, 2^(bin - 16). Then the
		// index of axy is found by dividing its offset into the range by the ulp.
		P_DEFAULT float bin = floor(log2(axy));
		P_DEFAULT float num = (axy - exp2(bin)) * exp2(16. - bin);

		// The lower 10 bits of the offset make up the y-value. The upper 6 bits, along with
		// the bin index, are used to compute the x-value. The bin index can exceed 15, so x
		// can assume the value 1024 without incident. It seems at first that y cannot, since
		// 10 bits fall just short. If the original input was signed, however, this is taken
		// to mean "y = 1024". Rather than conditionally setting it directly, though, 1023 is
		// found in the standard way and then incremented.
		P_DEFAULT float rest = floor(num / 1024.);
		P_DEFAULT float y = num - rest * 1024.;
		P_DEFAULT float y_bias = 1. - step(0., xy);

		return vec2(bin * 64. + rest, y + y_bias);
	}
]]

}