--- Mixins to send data through textures, e.g. see [Encoding Floats to RGBA - the Final?](http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/)

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

if system.getInfo("gpuSupportsHighPrecisionFragmentShaders") then
	Replacements.PRECISION = [[P_DEFAULT]]
else
	Replacements.PRECISION = [[P_POSITION]]
end

-- Export the functions.
return {

[[
	$(PRECISION) float DecodeFloatRGBA ($(PRECISION) vec4 rgba)
	{
		return dot(rgba, vec4(1., 1. / 255., 1. / 65025., 1. / 16581375.));
	}

	$(PRECISION) vec2 DecodeTwoFloatsRGBA ($(PRECISION) vec4 rgba)
	{
		return vec2(dot(rgba.xy, vec2(1., 1. / 255.)), dot(rgba.zw, vec2(1., 1. / 255.)));
	}
]], [[
	$(PRECISION) vec4 EncodeFloatRGBA ($(PRECISION) float v)
	{
		$(PRECISION) vec4 enc = vec4(1., 255., 65025., 16581375.) * v;

		enc = fract(enc);

		enc -= enc.yzww * vec4(1. / 255., 1. / 255., 1. / 255., 0.);

		return enc;
	}

	$(PRECISION) vec4 EncodeTwoFloatsRGBA ($(PRECISION) vec2 v)
	{
		$(PRECISION) vec4 enc = vec4(1., 255., 1., 255.) * v.xxyy;

		enc = fract(enc);

		enc -= enc.yyww * vec4(1. / 255., 0., 1. / 255., 0.);

		return enc;
	}
]], replacements = Replacements

}