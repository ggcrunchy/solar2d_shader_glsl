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
	P_UV vec2 UP (P_DEFAULT float xy)
	{
		P_DEFAULT float axy = abs(xy);

		// Negative values are interpreted as "add (+1, +1)", to account for values of 1024.
		P_DEFAULT float inc = 1. - step(0., xy);

		// The value 0, meanwhile, stands for (0, 1024). This will cause problems when fed to
		// the logarithm in the next step, so 2^0 (1) is used as a replacement. Down the line
		// this resolves to (0, 0), which is easy to convert to (0, 1024) in turn.
		P_DEFAULT float scale = step(0., -axy);

		axy += scale;

		// Find the 2^16-wide floating point range. The first element in this range is 1 *
		// 2^bin, while the ulp will be 2^bin / 2^16 or, equivalently, 2^(bin - 16). Then the
		// index of axy is found by dividing its offset into the range by the ulp. Note that
		// axy may be 2^16, to deal with the (1024, 0) case.
		P_DEFAULT float bin = floor(log2(axy));
		P_DEFAULT float num = (axy - exp2(bin)) * exp2(16. - bin);

		// Use the lower 10 bits of the offset as the y-value. The upper 6 bits, together
		// with the bin, are used to compute the x-value. If one or both of these values will
		// be 1024 (but neither will be 0), increment them afterward; if instead the original
		// input was 0, do the final conversion to (0, 1024).
		P_DEFAULT float rest = floor(num / 1024.);
		P_DEFAULT float y = num - rest * 1024.;

		return vec2(bin * 64. + rest, y + scale * 1024.) + inc;
	}
]]

}