--- Mixins to acquire data sent by **corona_shader.encode.vars** routines.

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

-- --
local Replacements = {}

if system.getInfo("platformName") == "Win" then
	Replacements.D_OUT = [[P_DEFAULT out]]
	Replacements.UV_OUT = [[P_UV out]]
else
	Replacements.D_OUT = [[out P_DEFAULT]]
	Replacements.UV_OUT = [[out P_UV]]
end

Replacements.DECODE = -- Formatting is a little awkward, but makes the GLSL line up
		[[P_DEFAULT $(TYPE) axy = abs(xy);

		// Select a 2^16-wide floating point range, comprising elements (1 + s / 65536) *
		// 2^bin, where significand s is an integer in [0, 65535]. The range's ulp will be
		// 2^bin / 2^16, i.e. 2^(bin - 16), and can be used to extract s.
		P_DEFAULT $(TYPE) bin = floor(log2(axy));

		// N.B. Floating point and real numbers are not the same thing; this is especially
		// important when working closely with the representation. Some care must be taken
		// regarding which of several "equivalent" formulae is chosen to find s, in order to
		// avoid corner cases that show up on certain architectures.
		P_DEFAULT $(TYPE) num = exp2(16. - bin) * axy - 65536.;

		// The lower 10 bits of the offset make up the y-value. The upper 6 bits, along with
		// the bin index, are used to compute the x-value. The bin index can exceed 15, so x
		// can assume the value 1024 without incident. It seems at first that y cannot, since
		// 10 bits fall just short. If the original input was signed, however, this is taken
		// to mean "y = 1024". Rather than conditionally setting it directly, though, 1023 is
		// found in the standard way and then incremented.
		P_DEFAULT $(TYPE) rest = floor(num / 1024.);
		P_DEFAULT $(TYPE) y = num - rest * 1024.;
		P_DEFAULT $(TYPE) y_bias = step(0., -xy);
]]

-- Export the functions.
return {

[[
	#if defined(FRAGMENT_SHADER) && !defined(GL_FRAGMENT_PRECISION_HIGH)
		#error "Not enough precision to decode number"
	#endif

	P_DEFAULT vec2 TenBitsPair (P_DEFAULT float xy)
	{
		${ TYPE = float }
		$(DECODE)

		return vec2(bin * 64. + rest, y + y_bias);
	}
]], [[
	#if defined(FRAGMENT_SHADER) && !defined(GL_FRAGMENT_PRECISION_HIGH)
		#error "Not enough precision to decode number"
	#endif

	void TenBitsPair4_OutH (P_DEFAULT vec4 xy, $(D_OUT) vec4 xo, $(D_OUT) vec4 yo)
	{
		${ TYPE = vec4 }
		$(DECODE)

		xo = bin * 64. + rest;
		yo = y + y_bias;
	}

	void TenBitsPair4_OutM (P_DEFAULT vec4 xy, $(UV_OUT) vec4 xo, $(UV_OUT) vec4 yo)
	{
		P_DEFAULT vec4 xhp, yhp;

		TenBitsPair4_OutH(xy, xhp, yhp);

		xo = xhp;
		yo = yhp;
	}
]], [[
	P_DEFAULT vec2 UnitPair (P_DEFAULT float xy)
	{
		return TenBitsPair(xy) / 1024.;
	}
]], [[
	void UnitPair4_OutH (P_DEFAULT vec4 xy, $(D_OUT) vec4 xo, $(D_OUT) vec4 yo)
	{
		TenBitsPair4_OutH(xy, xo, yo);

		xo /= 1024.;
		yo /= 1024.;
	}

	void UnitPair4_OutM (P_DEFAULT vec4 xy, $(UV_OUT) vec4 xo, $(UV_OUT) vec4 yo)
	{
		P_DEFAULT vec4 xhp, yhp;

		UnitPair4_OutH(xy, xhp, yhp);

		xo = xhp;
		yo = yhp;
	}
]], replacements = Replacements

}