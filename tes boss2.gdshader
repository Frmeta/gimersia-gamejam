shader_type canvas_item;

// Position of the center (0.5, 0.5 is the middle of the node)
uniform vec2 pos = vec2(0.5, 0.5);
// Radius of the circle (0.5 would touch the edges of a square node)
uniform float radius = 0.4;
uniform vec4 color : source_color = vec4(1.0);

void fragment() {
    // Calculate distance from the current pixel (UV) to the circle center
    float dist = distance(UV, pos);

    // smoothstep creates a smooth edge for anti-aliasing
    // changing 0.005 to 0.0 makes it a hard pixelated edge
    float alpha = smoothstep(radius, radius - 0.005, dist);

    // Output the color with the calculated alpha
    COLOR = vec4(color.rgb, alpha * color.a);
}