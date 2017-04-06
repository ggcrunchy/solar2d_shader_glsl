--- Distortion mixins.

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

-- Modules --
local screen_fx = require("corona_shader.screen_fx")

-- --
local Code = [[
	P_COLOR vec3 GetDistortedRGB (sampler2D s, P_UV vec2 offset, P_UV vec3 divs_alpha)
	{
		P_UV vec2 uv = (%s + offset) * divs_alpha.xy;

		return texture2D(s, uv).rgb * divs_alpha.z;
	}

	P_COLOR vec3 GetDistortedRGB (sampler2D s, P_UV vec2 offset, P_UV vec4 divs_alpha)
	{
		return GetDistortedRGB(s, offset, divs_alpha.xyz);
	}
]]

-- --
local Name = screen_fx.GetPosVaryingName()

-- Export the functions.
return {
	{ code = Code:format(Name),	[Name] = screen_fx.GetPosVaryingType() }
}