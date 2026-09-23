shader_type canvas_item;
render_mode unshaded;

uniform vec4 base_color : source_color = vec4(0.09, 0.11, 0.16, 0.85);
uniform float noise_strength : hint_range(0.0, 0.3) = 0.08;
uniform float glow_intensity : hint_range(0.0, 1.0) = 0.25;
uniform vec2 light_position = vec2(0.3, 0.2);

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
    vec2 uv = UV;
    
    // Soft noise for frosted look
    float n = noise(uv * 18.0) * noise_strength;
    
    // Soft light gradient (like liquid glass highlight)
    float light = smoothstep(0.8, 0.0, distance(uv, light_position));
    light = light * glow_intensity;
    
    vec3 color = base_color.rgb + n + light * 0.15;
    
    COLOR = vec4(color, base_color.a);
}