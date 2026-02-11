#version 330 core
#define WEB 1
#ifdef GL_ES
precision highp float;
precision highp int;
precision mediump sampler3D;
#endif
#define HW_PERFORMANCE 1

uniform vec2 iResolution;
uniform float iTime;
uniform vec4 iCurrentCursor;
uniform vec4 iPreviousCursor;
uniform float iTimeCursorChange;
uniform vec4 iCurrentCursorColor;
uniform vec4 iPreviousCursorColor;
uniform sampler2D iChannel0;

out vec4 fragColor;


#define TAU 6.28318530718
#define MAX_ITER 6

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Based on Inigo Quilez's 2D distance functions article: https://iquilezles.org/articles/distfunctions2d/
// Potencially optimized by eliminating conditionals and loops to enhance performance and reduce branching

float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfParallelogram(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);

    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);

    return s * sqrt(d);
}

vec2 norm(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialising(float distance) {
    return 1. - smoothstep(0., norm(vec2(2., 2.), 0.).x, distance);
}

float determineStartVertexFactor(vec2 c, vec2 p) {
    // Conditions using step
    float condition1 = step(p.x, c.x) * step(c.y, p.y); // c.x < p.x && c.y > p.y
    float condition2 = step(c.x, p.x) * step(p.y, c.y); // c.x > p.x && c.y < p.y

    // If neither condition is met, return 1 (else case)
    return 1.0 - max(condition1, condition2);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}
float ease(float x) {
    return pow(1.0 - x, 3.0);
}

vec4 saturate(vec4 color, float factor) {
    float gray = dot(color, vec4(0.299, 0.587, 0.114, 0.)); // luminance
    return mix(vec4(gray), color, factor);
}
const vec4 TRAIL_COLOR = vec4(1.0, 0.725, 0.161, 1.0);
const vec4 TRAIL_COLOR_ACCENT = vec4(1.0, 0., 0., 1.0);
const float DURATION = 1.0; //IN SECONDS

vec2 shake(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;

    float shakeDuration = 0.5; // seconds
    float timeSinceShake = iTime - iTimeCursorChange;

    vec2 shakeOffset = vec2(0.0);

    if (timeSinceShake >= 0.0 && timeSinceShake < shakeDuration) {
        float intensity = 0.0008; // Adjust shake intensity here

        float decay = 1.0 - (timeSinceShake / shakeDuration);

        shakeOffset.x = sin(iTime * 40.0) * intensity * decay;
        shakeOffset.y = cos(iTime * 35.0) * intensity * decay;
    }

    uv += shakeOffset;
	return uv;

}
void fire(out vec4 fragColor, in vec2 fragCoord)
{
    // Normalization for fragCoord to a space of -1 to 1;
    vec2 vu = norm(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    // Normalization for cursor position and size;
    // cursor xy has the postion in a space of -1 to 1;
    // zw has the width and height
    vec4 currentCursor = vec4(norm(vec2(iCurrentCursor.x, iCurrentCursor.y), 1.), norm(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(norm(vec2(iPreviousCursor.x, iPreviousCursor.y), 1.), norm(iPreviousCursor.zw, 0.));

    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    // When drawing a parellelogram between cursors for the trail i need to determine where to start at the top-left or top-right vertex of the cursor
    float vertexFactor = determineStartVertexFactor(currentCursor.xy, previousCursor.xy);
    float invertedVertexFactor = 1.0 - vertexFactor;

    // Set every vertex of my parellogram
    vec2 v0 = vec2(currentCursor.x + currentCursor.z * vertexFactor, currentCursor.y - currentCursor.w);
    vec2 v1 = vec2(currentCursor.x + currentCursor.z * invertedVertexFactor, currentCursor.y);
    vec2 v2 = vec2(previousCursor.x + currentCursor.z * invertedVertexFactor, previousCursor.y);
    vec2 v3 = vec2(previousCursor.x + currentCursor.z * vertexFactor, previousCursor.y - previousCursor.w);

    float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
    float sdfTrail = getSdfParallelogram(vu, v0, v1, v2, v3);

    float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    float easedProgress = ease(progress);
    // Distance between cursors determine the total length of the parallelogram;
    float lineLength = distance(centerCC, centerCP);

    float mod = .007;
    //trailblaze
    // HACK: Using the saturate function because I currently don't know how to blend colors without losing saturation.
    vec4 trail = mix(saturate(TRAIL_COLOR_ACCENT, 1.5), fragColor, 1. - smoothstep(0., sdfTrail + mod, 0.007));
    trail = mix(saturate(TRAIL_COLOR, 1.5), trail, 1. - smoothstep(0., sdfTrail + mod, 0.006));
    trail = mix(trail, saturate(TRAIL_COLOR, 1.5), step(sdfTrail + mod, 0.));
    //cursorblaze
    trail = mix(saturate(TRAIL_COLOR_ACCENT, 1.5), trail, 1. - smoothstep(0., sdfCurrentCursor + .002, 0.004));
    trail = mix(saturate(TRAIL_COLOR, 1.5), trail, 1. - smoothstep(0., sdfCurrentCursor + .002, 0.004));
    fragColor = mix(trail, fragColor, 1. - smoothstep(0., sdfCurrentCursor, easedProgress * lineLength));
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 water_color = vec3(1.0, 1.0, 1.0) * 0.5;
	float time = iTime * 0.5+23.0;
	vec2 uv = fragCoord.xy / iResolution.xy;
	uv = shake(fragColor, fragCoord);

    vec2 p = mod(uv*TAU, TAU)-250.0;
	vec2 i = vec2(p);
	float c = 1.0;
	float inten = 0.005;

	for (int n = 0; n < MAX_ITER; n++)
	{
		float t = time * (1.0 - (3.5 / float(n+1)));
		i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
		c += 1.0/length(vec2(p.x / (sin(i.x+t)/inten),p.y / (cos(i.y+t)/inten)));
	}
	c /= float(MAX_ITER);
	c = 1.17-pow(c, 1.4);
	vec3 color = vec3(pow(abs(c), 15.0));
    color = clamp((color + water_color)*1.2, 0.0, 1.0);

    // perterb uv based on value of c from caustic calc above
    vec2 tc = vec2(cos(c)-0.75,sin(c)-0.75)*0.04;
    uv = clamp(uv + tc,0.0,1.0);

    fragColor = texture(iChannel0, uv);
    // give transparent pixels a color
    if ( fragColor.a == 0.0 ) fragColor=vec4(1.0,1.0,1.0,1.0);
    fragColor *= vec4(color, 1.0);
    // Normalization for fragCoord to a space of -1 to 1;
    vec2 vu = norm(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    // Normalization for cursor position and size;
    // cursor xy has the postion in a space of -1 to 1;
    // zw has the width and height
    vec4 currentCursor = vec4(norm(vec2(iCurrentCursor.x, iCurrentCursor.y), 1.), norm(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(norm(vec2(iPreviousCursor.x, iPreviousCursor.y), 1.), norm(iPreviousCursor.zw, 0.));

    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    // When drawing a parellelogram between cursors for the trail i need to determine where to start at the top-left or top-right vertex of the cursor
    float vertexFactor = determineStartVertexFactor(currentCursor.xy, previousCursor.xy);
    float invertedVertexFactor = 1.0 - vertexFactor;

    // Set every vertex of my parellogram
    vec2 v0 = vec2(currentCursor.x + currentCursor.z * vertexFactor, currentCursor.y - currentCursor.w);
    vec2 v1 = vec2(currentCursor.x + currentCursor.z * invertedVertexFactor, currentCursor.y);
    vec2 v2 = vec2(previousCursor.x + currentCursor.z * invertedVertexFactor, previousCursor.y);
    vec2 v3 = vec2(previousCursor.x + currentCursor.z * vertexFactor, previousCursor.y - previousCursor.w);

    float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
    float sdfTrail = getSdfParallelogram(vu, v0, v1, v2, v3);

    float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    float easedProgress = ease(progress);
    // Distance between cursors determine the total length of the parallelogram;
    float lineLength = distance(centerCC, centerCP);

    float mod = .007;
    //trailblaze
    // HACK: Using the saturate function because I currently don't know how to blend colors without losing saturation.
    vec4 trail = mix(saturate(TRAIL_COLOR_ACCENT, 1.5), fragColor, 1. - smoothstep(0., sdfTrail + mod, 0.007));
    trail = mix(saturate(TRAIL_COLOR, 1.5), trail, 1. - smoothstep(0., sdfTrail + mod, 0.006));
    trail = mix(trail, saturate(TRAIL_COLOR, 1.5), step(sdfTrail + mod, 0.));
    //cursorblaze
    trail = mix(saturate(TRAIL_COLOR_ACCENT, 1.5), trail, 1. - smoothstep(0., sdfCurrentCursor + .002, 0.004));
    trail = mix(saturate(TRAIL_COLOR, 1.5), trail, 1. - smoothstep(0., sdfCurrentCursor + .002, 0.004));
    fragColor = mix(trail, fragColor, 1. - smoothstep(0., sdfCurrentCursor, easedProgress * lineLength));
	// fire(fragColor, fragCoord);
}

void main() {
    mainImage(fragColor, gl_FragCoord.xy);
}
