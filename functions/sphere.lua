--- Sphere mixins.

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
local M = {}

-- Common snippets --
local Replacements = {}

Replacements.GET_Z = -- Formatting is a little awkward, but makes the GLSL line up...
		[[P_POSITION float dist_sq = dot(diff, diff);

		#ifndef SPHERE_NO_DISCARD
			if (dist_sq > 1.) return $(Z_RET_TYPE)(-1.);
		#endif

		P_POSITION float z = sqrt(1. - dist_sq);
]]

Replacements.PHI_TO_U = -- ...ditto
		[[P_POSITION float angle = .5 + phi / TWO_PI;

		#ifdef SPHERE_PINGPONG_ANGLE
			angle = mod(angle + dphi, 2.);
			angle = mix(angle, 2. - angle, step(1., angle));
		#else
			angle = fract(angle + dphi);
		#endif
]]

return {

[[
	P_POSITION vec2 GetUV (P_POSITION vec2 diff)
	{
		${ Z_RET_TYPE = vec2 }
		$(GET_Z)

		return vec2(.5 + atan(z, diff.x) / TWO_PI, .5 + asin(diff.y) / PI);
	}

	P_POSITION vec2 GetUV (P_POSITION vec3 dir)
	{
		return vec2(.5 + atan(dir.z, dir.x) / TWO_PI, .5 + asin(dir.y) / PI);
	}
]], [[
	P_POSITION vec4 GetUV_ZPhi (P_POSITION vec2 diff)
	{
		${ Z_RET_TYPE = vec2 }
		$(GET_Z)

		P_POSITION float phi = atan(z, diff.x);

		return vec4(.5 + phi / TWO_PI, .5 + asin(diff.y) / PI, z, phi);
	}
]], [[
	P_POSITION vec2 GetUV_PhiDelta (P_POSITION vec2 diff, P_POSITION float dphi)
	{
		${ Z_RET_TYPE = vec2 }
		$(GET_Z)

		P_POSITION float phi = atan(z, diff.x);

		$(PHI_TO_U)

		return vec2(angle, .5 + asin(diff.y) / PI);
	}
]], [[
	P_POSITION vec4 GetUV_PhiDelta_ZPhi (P_POSITION vec2 diff, P_POSITION float dphi)
	{
		${ Z_RET_TYPE = vec4 }
		$(GET_Z)

		P_POSITION float phi = atan(z, diff.x);

		$(PHI_TO_U)

		return vec4(angle, .5 + asin(diff.y) / PI, z, phi);
	}
]], [[
	P_POSITION vec3 GetTangent (P_POSITION vec2 diff, P_POSITION float phi)
	{
		// In unit sphere, diff.y = sin(theta), sqrt(1 - sin(theta)^2) = cos(theta).
		return normalize(vec3(diff.yy * sin(vec2(phi + PI_OVER_TWO, -phi)), sqrt(1. - diff.y * diff.y)));
	}
]], replacements = Replacements

}