// SkyBox Shader
const vs = '#version 330' + LE +
           '// Input vertex attributes' +LE +
           'in vec3 vertexPosition;' +LE +
           '// Input uniform values' +LE+
           'uniform mat4 matProjection;' +LE+
           'uniform mat4 matView;' +LE+
           '// Output vertex attributes (to fragment shader)' +LE+
           'out vec3 fragPosition;' +LE+
           'void main()' +LE+
           '{' +LE+
           '// Calculate fragment position based on model transformations' +LE+
           'fragPosition = vertexPosition;' +LE+
           '// Remove translation from the view matrix' +LE+
           'mat4 rotView = mat4(mat3(matView));' +LE+
           'vec4 clipPos = matProjection*rotView*vec4(vertexPosition, 1.0);' +LE+
           '// Calculate final vertex position' +LE+
           'gl_Position = clipPos;' +LE+
           '}' +LE;

const fs = '#version 330' +LE+
           '// Input vertex attributes (from vertex shader)' +LE+
           'in vec3 fragPosition;' +LE+
           '// Input uniform values' +LE+
           'uniform samplerCube environmentMap;' +LE+
           'uniform bool vflipped;' +LE+
           'uniform bool doGamma;' +LE+
           '// Output fragment color' +LE+
           'out vec4 finalColor;' +LE+
           'void main()' +LE+
           '{' +LE+
           '// Fetch color from texture map' +LE+
           'vec3 color = vec3(0.0);' +LE+
           'if (vflipped) color = texture(environmentMap, vec3(fragPosition.x, -fragPosition.y, fragPosition.z)).rgb;' +LE+
           'else color = texture(environmentMap, fragPosition).rgb;' +LE+
           'if (doGamma)// Apply gamma correction' +LE+
           '{' +LE+
           'color = color/(color + vec3(1.0));' +LE+
           'color = pow(color, vec3(1.0/2.2));' +LE+
           '}' +LE+
           '// Calculate final fragment color' +LE+
           'finalColor = vec4(color, 1.0);' +LE+
           '}' +LE;    
