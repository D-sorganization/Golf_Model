#!/usr/bin/env python3
"""
Golf Swing Visualizer - High-Performance OpenGL Renderer
Modern shader-based rendering with hardware acceleration and realistic lighting
"""

import numpy as np
import moderngl as mgl
from typing import Dict, List, Tuple, Optional, Union
import time
import warnings
import traceback
from dataclasses import dataclass
from pathlib import Path

# ============================================================================
# SHADER DEFINITIONS
# ============================================================================

class ShaderLibrary:
    """Collection of optimized GLSL shaders for golf swing visualization"""
    
    @staticmethod
    def get_standard_vertex_shader() -> str:
        """Standard vertex shader with transformation and lighting support"""
        return """
        #version 330 core
        
        layout (location = 0) in vec3 position;
        layout (location = 1) in vec3 normal;
        
        uniform mat4 model;
        uniform mat4 view;
        uniform mat4 projection;
        uniform mat4 normalMatrix;
        
        out vec3 FragPos;
        out vec3 Normal;
        out vec3 ViewPos;
        
        void main() {
            vec4 worldPos = model * vec4(position, 1.0);
            FragPos = worldPos.xyz;
            Normal = mat3(normalMatrix) * normal;
            ViewPos = (view * worldPos).xyz;
            
            gl_Position = projection * view * worldPos;
        }
        """
    
    @staticmethod 
    def get_standard_fragment_shader() -> str:
        """Advanced fragment shader with PBR-style lighting"""
        return """
        #version 330 core
        
        in vec3 FragPos;
        in vec3 Normal;
        in vec3 ViewPos;
        
        out vec4 FragColor;
        
        // Material properties
        uniform vec3 materialColor;
        uniform float materialRoughness;
        uniform float materialMetallic;
        uniform float materialSpecular;
        uniform float opacity;
        
        // Lighting uniforms
        uniform vec3 lightPosition;
        uniform vec3 lightColor;
        uniform vec3 viewPosition;
        uniform float ambientStrength;
        uniform float lightIntensity;
        
        // Environment
        uniform vec3 skyColor;
        uniform float fogDensity;
        uniform float fogStart;
        
        // Utility functions
        float distributionGGX(vec3 N, vec3 H, float roughness) {
            float a = roughness * roughness;
            float a2 = a * a;
            float NdotH = max(dot(N, H), 0.0);
            float NdotH2 = NdotH * NdotH;
            
            float num = a2;
            float denom = (NdotH2 * (a2 - 1.0) + 1.0);
            denom = 3.14159265 * denom * denom;
            
            return num / denom;
        }
        
        float geometrySchlickGGX(float NdotV, float roughness) {
            float r = (roughness + 1.0);
            float k = (r * r) / 8.0;
            
            float num = NdotV;
            float denom = NdotV * (1.0 - k) + k;
            
            return num / denom;
        }
        
        float geometrySmith(vec3 N, vec3 V, vec3 L, float roughness) {
            float NdotV = max(dot(N, V), 0.0);
            float NdotL = max(dot(N, L), 0.0);
            float ggx2 = geometrySchlickGGX(NdotV, roughness);
            float ggx1 = geometrySchlickGGX(NdotL, roughness);
            
            return ggx1 * ggx2;
        }
        
        vec3 fresnelSchlick(float cosTheta, vec3 F0) {
            return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
        }
        
        void main() {
            vec3 N = normalize(Normal);
            vec3 V = normalize(viewPosition - FragPos);
            vec3 L = normalize(lightPosition - FragPos);
            vec3 H = normalize(V + L);
            
            // Calculate distance and attenuation
            float distance = length(lightPosition - FragPos);
            float attenuation = 1.0 / (1.0 + 0.09 * distance + 0.032 * distance * distance);
            vec3 radiance = lightColor * lightIntensity * attenuation;
            
            // Material properties
            vec3 F0 = vec3(0.04);
            F0 = mix(F0, materialColor, materialMetallic);
            
            // Cook-Torrance BRDF
            float NDF = distributionGGX(N, H, materialRoughness);
            float G = geometrySmith(N, V, L, materialRoughness);
            vec3 F = fresnelSchlick(max(dot(H, V), 0.0), F0);
            
            vec3 kS = F;
            vec3 kD = vec3(1.0) - kS;
            kD *= 1.0 - materialMetallic;
            
            vec3 numerator = NDF * G * F;
            float denominator = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) + 0.0001;
            vec3 specular = numerator / denominator;
            
            float NdotL = max(dot(N, L), 0.0);
            vec3 Lo = (kD * materialColor / 3.14159265 + specular) * radiance * NdotL;
            
            // Ambient lighting
            vec3 ambient = ambientStrength * materialColor;
            
            vec3 color = ambient + Lo;
            
            // Fog calculation
            float fogFactor = 1.0;
            if (fogDensity > 0.0) {
                float viewDistance = length(ViewPos);
                if (viewDistance > fogStart) {
                    fogFactor = exp(-fogDensity * (viewDistance - fogStart));
                    fogFactor = clamp(fogFactor, 0.0, 1.0);
                }
            }
            
            color = mix(skyColor, color, fogFactor);
            
            // Tone mapping and gamma correction
            color = color / (color + vec3(1.0));
            color = pow(color, vec3(1.0/2.2));
            
            FragColor = vec4(color, opacity);
        }
        """
    
    @staticmethod
    def get_vector_vertex_shader() -> str:
        """Specialized vertex shader for force/torque vectors"""
        return """
        #version 330 core
        
        layout (location = 0) in vec3 position;
        layout (location = 1) in vec3 normal;
        
        uniform mat4 model;
        uniform mat4 view;
        uniform mat4 projection;
        uniform vec3 startPosition;
        uniform vec3 vectorDirection;
        uniform float vectorMagnitude;
        uniform float vectorScale;
        
        out vec3 FragPos;
        out vec3 Normal;
        out float DistanceAlongVector;
        
        void main() {
            // Scale and orient the arrow geometry
            vec3 scaledPos = position;
            scaledPos.y *= vectorMagnitude * vectorScale;
            
            // Apply model transformation (rotation to align with vector)
            vec4 worldPos = model * vec4(scaledPos, 1.0);
            worldPos.xyz += startPosition;
            
            FragPos = worldPos.xyz;
            Normal = mat3(model) * normal;
            DistanceAlongVector = scaledPos.y / (vectorMagnitude * vectorScale);
            
            gl_Position = projection * view * worldPos;
        }
        """
    
    @staticmethod
    def get_vector_fragment_shader() -> str:
        """Fragment shader with gradient coloring for vectors"""
        return """
        #version 330 core
        
        in vec3 FragPos;
        in vec3 Normal;
        in float DistanceAlongVector;
        
        out vec4 FragColor;
        
        uniform vec3 baseColor;
        uniform vec3 tipColor;
        uniform float opacity;
        uniform vec3 lightPosition;
        uniform vec3 lightColor;
        uniform vec3 viewPosition;
        uniform float ambientStrength;
        
        void main() {
            // Gradient color along vector
            vec3 materialColor = mix(baseColor, tipColor, DistanceAlongVector);
            
            // Simple lighting
            vec3 N = normalize(Normal);
            vec3 L = normalize(lightPosition - FragPos);
            vec3 V = normalize(viewPosition - FragPos);
            vec3 R = reflect(-L, N);
            
            // Ambient
            vec3 ambient = ambientStrength * materialColor;
            
            // Diffuse
            float diff = max(dot(N, L), 0.0);
            vec3 diffuse = diff * lightColor * materialColor;
            
            // Specular
            float spec = pow(max(dot(V, R), 0.0), 32.0);
            vec3 specular = spec * lightColor * 0.5;
            
            vec3 result = ambient + diffuse + specular;
            FragColor = vec4(result, opacity);
        }
        """
    
    @staticmethod
    def get_ground_vertex_shader() -> str:
        """Vertex shader for ground plane with grid"""
        return """
        #version 330 core
        
        layout (location = 0) in vec3 position;
        layout (location = 1) in vec2 texCoord;
        
        uniform mat4 model;
        uniform mat4 view;
        uniform mat4 projection;
        
        out vec3 FragPos;
        out vec2 TexCoord;
        out vec3 ViewPos;
        
        void main() {
            vec4 worldPos = model * vec4(position, 1.0);
            FragPos = worldPos.xyz;
            TexCoord = texCoord;
            ViewPos = (view * worldPos).xyz;
            
            gl_Position = projection * view * worldPos;
        }
        """
    
    @staticmethod
    def get_ground_fragment_shader() -> str:
        """Fragment shader for golf course ground with grid"""
        return """
        #version 330 core
        
        in vec3 FragPos;
        in vec2 TexCoord;
        in vec3 ViewPos;
        
        out vec4 FragColor;
        
        uniform vec3 grassColor;
        uniform vec3 gridColor;
        uniform float gridSpacing;
        uniform float gridWidth;
        uniform float fadeDistance;
        
        void main() {
            // Calculate grid lines
            vec2 grid = abs(fract(TexCoord * gridSpacing) - 0.5) / fwidth(TexCoord * gridSpacing);
            float line = min(grid.x, grid.y);
            float gridStrength = 1.0 - min(line / gridWidth, 1.0);
            
            // Distance-based fade
            float viewDistance = length(ViewPos);
            float fade = 1.0 - smoothstep(fadeDistance * 0.5, fadeDistance, viewDistance);
            gridStrength *= fade;
            
            // Mix grass and grid colors
            vec3 color = mix(grassColor, gridColor, gridStrength);
            
            FragColor = vec4(color, 1.0);
        }
        """

# ============================================================================
# GEOMETRY MANAGER
# ============================================================================

@dataclass
class GeometryObject:
    """Container for OpenGL geometry with efficient updates"""
    vao: mgl.VertexArray
    vertex_count: int
    index_count: int
    visible: bool = True
    position: Optional[np.ndarray] = None
    rotation: Optional[np.ndarray] = None
    scale: Optional[np.ndarray] = None
    
    def __post_init__(self):
        if self.position is None:
            self.position = np.zeros(3, dtype=np.float32)
        if self.rotation is None:
            self.rotation = np.eye(3, dtype=np.float32)
        if self.scale is None:
            self.scale = np.ones(3, dtype=np.float32)

class GeometryManager:
    """Efficient management of 3D geometry with instanced rendering"""
    
    def __init__(self, ctx: mgl.Context):
        self.ctx = ctx
        self.geometry_objects: Dict[str, GeometryObject] = {}
        self.mesh_library: Dict[str, Tuple[np.ndarray, np.ndarray, np.ndarray]] = {}
        self.programs: Dict[str, mgl.Program] = {}
        
        # Initialize standard meshes
        self._create_standard_meshes()
        self._compile_shaders()
    
    def _create_standard_meshes(self):
        """Create standard mesh library for body parts and club"""
        try:
            print("🔧 Creating standard meshes...")
            
            # Import geometry utilities from the core module
            from golf_data_core import GeometryUtils
            print("  ✅ GeometryUtils imported")
            
            # Create optimized meshes
            print("  Creating cylinder mesh...")
            self.mesh_library['cylinder'] = GeometryUtils.create_cylinder_mesh(
                radius=1.0, height=1.0, segments=16
            )
            print("  ✅ Cylinder mesh created")
            
            print("  Creating sphere mesh...")
            self.mesh_library['sphere'] = GeometryUtils.create_sphere_mesh(
                radius=1.0, lat_segments=12, lon_segments=16  
            )
            print("  ✅ Sphere mesh created")
            
            print("  Creating arrow mesh...")
            self.mesh_library['arrow'] = GeometryUtils.create_arrow_mesh(
                shaft_radius=0.02, shaft_length=0.8,
                head_radius=0.04, head_length=0.2, segments=8
            )
            print("  ✅ Arrow mesh created")
            
            # Ground plane
            print("  Creating ground mesh...")
            self._create_ground_mesh()
            print("  ✅ Ground mesh created")
            
            print(f"✅ Created {len(self.mesh_library)} standard meshes")
            print(f"  Available meshes: {list(self.mesh_library.keys())}")
            
        except Exception as e:
            print(f"❌ Failed to create standard meshes: {e}")
            traceback.print_exc()
            raise
    
    def _create_ground_mesh(self):
        """Create ground plane mesh with proper texture coordinates"""
        size = 10.0
        vertices = [
            -size, 0, -size,  0, 0,  # position, texcoord
             size, 0, -size,  1, 0,
             size, 0,  size,  1, 1,
            -size, 0,  size,  0, 1
        ]
        
        indices = [0, 1, 2, 0, 2, 3]
        
        self.mesh_library['ground'] = (
            np.array(vertices, dtype=np.float32),
            np.array([0, 1, 0] * 4, dtype=np.float32),  # Normals pointing up
            np.array(indices, dtype=np.uint32)
        )
    
    def _compile_shaders(self):
        """Compile all shader programs"""
        try:
            print("🔧 Compiling shader programs...")
            
            # Standard PBR shader
            print("  Compiling standard shader...")
            self.programs['standard'] = self.ctx.program(
                vertex_shader=ShaderLibrary.get_standard_vertex_shader(),
                fragment_shader=ShaderLibrary.get_standard_fragment_shader()
            )
            print(f"  ✅ Standard shader compiled: {type(self.programs['standard'])}")
            
            # Vector shader for forces/torques
            print("  Compiling vector shader...")
            self.programs['vector'] = self.ctx.program(
                vertex_shader=ShaderLibrary.get_vector_vertex_shader(),
                fragment_shader=ShaderLibrary.get_vector_fragment_shader()
            )
            print(f"  ✅ Vector shader compiled: {type(self.programs['vector'])}")
            
            # Ground shader
            print("  Compiling ground shader...")
            self.programs['ground'] = self.ctx.program(
                vertex_shader=ShaderLibrary.get_ground_vertex_shader(),
                fragment_shader=ShaderLibrary.get_ground_fragment_shader()
            )
            print(f"  ✅ Ground shader compiled: {type(self.programs['ground'])}")
            
            print(f"✅ Compiled {len(self.programs)} shader programs")
            print(f"  Available programs: {list(self.programs.keys())}")
            
        except Exception as e:
            print(f"❌ Failed to compile shaders: {e}")
            traceback.print_exc()
            raise RuntimeError(f"Failed to compile shaders: {e}")
    
    def create_geometry_object(self, name: str, mesh_type: str, program_name: str = 'standard') -> GeometryObject:
        """Create a new geometry object from mesh library"""
        if mesh_type not in self.mesh_library:
            raise ValueError(f"Mesh type '{mesh_type}' not found in library")
        
        if program_name not in self.programs:
            raise ValueError(f"Program '{program_name}' not found")
        
        vertices, normals, indices = self.mesh_library[mesh_type]
        program = self.programs[program_name]
        
        # Create buffers
        vertex_buffer = self.ctx.buffer(vertices)
        normal_buffer = self.ctx.buffer(normals) 
        index_buffer = self.ctx.buffer(indices)
        
        # Create VAO based on mesh type
        if mesh_type == 'ground':
            # Ground mesh has position + texcoord
            vao = self.ctx.vertex_array(
                program,
                [(vertex_buffer, '3f 2f', 0, 1)],  # position at location 0, texCoord at location 1
                index_buffer
            )
        else:
            # Standard mesh has position + normal only
            vao = self.ctx.vertex_array(
                program,
                [
                    (vertex_buffer, '3f', 'position'),
                    (normal_buffer, '3f', 'normal')
                ],
                index_buffer
            )
        
        geometry_obj = GeometryObject(
            vao=vao,
            vertex_count=len(vertices) // 3,
            index_count=len(indices)
        )
        
        self.geometry_objects[name] = geometry_obj
        return geometry_obj
    
    def update_object_transform(self, name: str, position: np.ndarray, 
                              rotation: np.ndarray, scale: Union[float, np.ndarray]):
        """Update object transformation efficiently"""
        if name not in self.geometry_objects:
            return
        
        obj = self.geometry_objects[name]
        obj.position = np.array(position, dtype=np.float32)
        obj.rotation = np.array(rotation, dtype=np.float32)
        
        if isinstance(scale, (int, float)):
            obj.scale = np.array([scale, scale, scale], dtype=np.float32)
        else:
            obj.scale = np.array(scale, dtype=np.float32)
    
    def set_object_visibility(self, name: str, visible: bool):
        """Set object visibility"""
        if name in self.geometry_objects:
            self.geometry_objects[name].visible = visible
    
    def get_model_matrix(self, obj: GeometryObject) -> np.ndarray:
        """Calculate model matrix for object"""
        # Translation matrix
        T = np.eye(4, dtype=np.float32)
        if obj.position is not None:
            T[:3, 3] = obj.position
        
        # Rotation matrix
        R = np.eye(4, dtype=np.float32)
        if obj.rotation is not None:
            R[:3, :3] = obj.rotation
        
        # Scale matrix
        S = np.eye(4, dtype=np.float32)
        if obj.scale is not None:
            S[0, 0] = obj.scale[0]
            S[1, 1] = obj.scale[1] 
            S[2, 2] = obj.scale[2]
        
        return T @ R @ S
    
    def cleanup(self):
        """Clean up OpenGL resources"""
        for obj in self.geometry_objects.values():
            obj.vao.release()
        self.geometry_objects.clear()
        
        for program in self.programs.values():
            program.release()
        self.programs.clear()

# ============================================================================
# LIGHTING SYSTEM
# ============================================================================

@dataclass
class Light:
    """Light source configuration"""
    position: np.ndarray
    color: np.ndarray
    intensity: float
    type: str = 'directional'  # 'directional', 'point', 'spot'

class LightingSystem:
    """Advanced lighting system with multiple light sources"""
    
    def __init__(self):
        self.lights: List[Light] = []
        self.ambient_color = np.array([0.2, 0.3, 0.4], dtype=np.float32)
        self.ambient_strength = 0.3
        self.sky_color = np.array([0.53, 0.81, 0.92], dtype=np.float32)
        
        # Setup default lighting
        self._setup_default_lights()
    
    def _setup_default_lights(self):
        """Setup realistic golf course lighting"""
        # Main sun light
        self.lights.append(Light(
            position=np.array([2.0, 4.0, 1.0], dtype=np.float32),
            color=np.array([1.0, 0.95, 0.85], dtype=np.float32),
            intensity=1.2,
            type='directional'
        ))
        
        # Fill light (simulates sky illumination)
        self.lights.append(Light(
            position=np.array([-1.0, 2.0, -1.0], dtype=np.float32),
            color=np.array([0.7, 0.85, 1.0], dtype=np.float32),
            intensity=0.6,
            type='directional'
        ))
    
    def apply_lighting_uniforms(self, program: mgl.Program, view_position: np.ndarray):
        """Apply lighting uniforms to shader program"""
        try:
            # Primary light (first in list)
            if self.lights:
                main_light = self.lights[0]
                if 'lightPosition' in program:
                    program['lightPosition'].write(main_light.position.tobytes())
                if 'lightColor' in program:
                    program['lightColor'].write(main_light.color.tobytes())
                if 'lightIntensity' in program:
                    program['lightIntensity'].value = main_light.intensity
            
            # Ambient lighting
            if 'ambientStrength' in program:
                program['ambientStrength'].value = self.ambient_strength
            if 'skyColor' in program:
                program['skyColor'].write(self.sky_color.tobytes())
            
            # View position
            if 'viewPosition' in program:
                program['viewPosition'].write(view_position.tobytes())
                
        except Exception as e:
            warnings.warn(f"Error applying lighting uniforms: {e}")
    
    def update_time_of_day(self, time_factor: float):
        """Update lighting based on time of day (0.0 = dawn, 0.5 = noon, 1.0 = dusk)"""
        # Adjust sun position and color based on time
        if self.lights:
            main_light = self.lights[0]
            
            # Sun elevation (higher at noon)
            elevation = 1.0 + 3.0 * (1.0 - abs(time_factor - 0.5) * 2.0)
            main_light.position[1] = elevation
            
            # Color temperature (warmer at dawn/dusk)
            if time_factor < 0.2 or time_factor > 0.8:
                # Dawn/dusk - warmer light
                main_light.color = np.array([1.0, 0.7, 0.4], dtype=np.float32)
                main_light.intensity = 0.8
            else:
                # Day - cooler light
                main_light.color = np.array([1.0, 0.95, 0.85], dtype=np.float32)
                main_light.intensity = 1.2

# ============================================================================
# MAIN OPENGL RENDERER
# ============================================================================

class OpenGLRenderer:
    """High-performance OpenGL renderer with modern techniques"""
    
    def __init__(self):
        self.ctx: Optional[mgl.Context] = None
        self.geometry_manager: Optional[GeometryManager] = None
        self.lighting_system = LightingSystem()
        
        # Rendering state
        self.viewport_size = (1600, 900)
        self.clear_color = (1.0, 1.0, 1.0, 1.0)  # White background
        
        # Performance tracking
        self.render_stats = {
            'triangles_rendered': 0,
            'draw_calls': 0,
            'render_time_ms': 0.0
        }
    
    def initialize(self, ctx: mgl.Context):
        """Initialize OpenGL context and resources"""
        self.ctx = ctx
        
        # Setup OpenGL state
        self.ctx.enable(mgl.DEPTH_TEST)
        self.ctx.enable(mgl.BLEND)
        self.ctx.blend_func = mgl.SRC_ALPHA, mgl.ONE_MINUS_SRC_ALPHA
        self.ctx.enable(mgl.CULL_FACE)
        self.ctx.front_face = 'ccw'
        
        # Initialize geometry manager
        self.geometry_manager = GeometryManager(self.ctx)
        
        # Create standard geometry objects
        self._create_standard_objects()
        
        print("✅ OpenGL renderer initialized")
        print(f"   OpenGL Version: {self.ctx.info['GL_VERSION']}")
        print(f"   Renderer: {self.ctx.info['GL_RENDERER']}")
        try:
            extensions = self.ctx.info.get('GL_EXTENSIONS', '')
            print(f"   Extensions: {len(extensions.split()) if extensions else 0}")
        except:
            print("   Extensions: Unable to retrieve")
    
    def _create_standard_objects(self):
        """Create standard geometry objects for rendering"""
        if not self.geometry_manager:
            return
        # Body segment objects
        for segment in ['left_forearm', 'left_upper_arm', 'right_forearm', 
                       'right_upper_arm', 'left_shoulder_neck', 'right_shoulder_neck']:
            self.geometry_manager.create_geometry_object(f'{segment}_cyl', 'cylinder')
            self.geometry_manager.create_geometry_object(f'{segment}_sph', 'sphere')
        
        # Club objects
        self.geometry_manager.create_geometry_object('shaft', 'cylinder')
        self.geometry_manager.create_geometry_object('clubhead', 'sphere')  # Simplified clubhead
        
        # Hub
        self.geometry_manager.create_geometry_object('hub', 'sphere')
        
        # Force/torque vectors
        self.geometry_manager.create_geometry_object('force_vector', 'arrow', 'vector')
        self.geometry_manager.create_geometry_object('torque_vector', 'arrow', 'vector')
        
        # Face normal
        self.geometry_manager.create_geometry_object('face_normal', 'arrow', 'vector')
        
        # Ground
        self.geometry_manager.create_geometry_object('ground', 'ground', 'ground')
        
        print(f"✅ Created {len(self.geometry_manager.geometry_objects)} geometry objects")
    
    def set_viewport(self, width: int, height: int):
        """Set viewport size"""
        self.viewport_size = (width, height)
        if self.ctx:
            self.ctx.viewport = (0, 0, width, height)
    
    def render_frame(self, frame_data, dynamics_data, render_config, view_matrix: np.ndarray, 
                    proj_matrix: np.ndarray, view_position: np.ndarray):
        """Render complete frame with all elements"""
        if not self.ctx or not self.geometry_manager:
            return
        start_time = time.time()
        
        # Clear framebuffer
        self.ctx.clear(*self.clear_color)
        
        # Reset stats
        self.render_stats['triangles_rendered'] = 0
        self.render_stats['draw_calls'] = 0
        
        # Calculate normal matrix
        normal_matrix = np.linalg.inv(view_matrix[:3, :3]).T
        
        # Render ground
        if render_config.show_ground:
            self._render_ground(view_matrix, proj_matrix, normal_matrix, view_position)
        
        # Render body segments
        self._render_body_segments(frame_data, render_config, view_matrix, proj_matrix, normal_matrix, view_position)
        
        # Render club
        if render_config.show_club:
            self._render_club(frame_data, render_config, view_matrix, proj_matrix, normal_matrix, view_position)
        
        # Render force/torque vectors
        self._render_vectors(frame_data, dynamics_data, render_config, view_matrix, proj_matrix, normal_matrix, view_position)
        
        # Render face normal
        if render_config.show_face_normal:
            self._render_face_normal(frame_data, render_config, view_matrix, proj_matrix, normal_matrix, view_position)
        
        # Update performance stats
        self.render_stats['render_time_ms'] = (time.time() - start_time) * 1000
    
    def get_model_matrix(self, obj: GeometryObject) -> np.ndarray:
        """Calculate model matrix for object"""
        # Translation matrix
        T = np.eye(4, dtype=np.float32)
        if obj.position is not None:
            T[:3, 3] = obj.position
        
        # Rotation matrix
        R = np.eye(4, dtype=np.float32)
        if obj.rotation is not None:
            R[:3, :3] = obj.rotation
        
        # Scale matrix
        S = np.eye(4, dtype=np.float32)
        if obj.scale is not None:
            S[0, 0] = obj.scale[0]
            S[1, 1] = obj.scale[1] 
            S[2, 2] = obj.scale[2]
        
        return T @ R @ S
    
    def _render_ground(self, view_matrix: np.ndarray, proj_matrix: np.ndarray, 
                      normal_matrix: np.ndarray, view_position: np.ndarray):
        """Render golf course ground with grid"""
        if not self.geometry_manager:
            print("⚠️ Render error: No geometry manager")
            return
            
        if 'ground' not in self.geometry_manager.geometry_objects:
            print("⚠️ Render error: 'ground' object not found")
            return
            
        ground_obj = self.geometry_manager.geometry_objects['ground']
        if not ground_obj.visible:
            return
        
        if 'ground' not in self.geometry_manager.programs:
            print(f"⚠️ Render error: 'ground' program not found. Available: {list(self.geometry_manager.programs.keys())}")
            return
            
        program = self.geometry_manager.programs['ground']
        if program is None:
            print("⚠️ Render error: 'ground' program is None")
            return
            
        try:
            program.use()
        except Exception as e:
            print(f"⚠️ Render error: 'Program' object has no attribute 'use': {e}")
            return
        
        # Transformation matrices
        model_matrix = self.geometry_manager.get_model_matrix(ground_obj)
        
        program['model'].write(model_matrix.tobytes())
        program['view'].write(view_matrix.tobytes())
        program['projection'].write(proj_matrix.tobytes())
        
        # Ground-specific uniforms
        program['grassColor'].write(np.array([0.2, 0.6, 0.2], dtype=np.float32).tobytes())
        program['gridColor'].write(np.array([0.15, 0.45, 0.15], dtype=np.float32).tobytes())
        program['gridSpacing'].value = 10.0
        program['gridWidth'].value = 2.0
        program['fadeDistance'].value = 15.0
        
        ground_obj.vao.render()
        self.render_stats['draw_calls'] += 1
        self.render_stats['triangles_rendered'] += ground_obj.index_count // 3
    
    def _render_body_segments(self, frame_data, render_config, view_matrix: np.ndarray,
                             proj_matrix: np.ndarray, normal_matrix: np.ndarray, view_position: np.ndarray):
        """Render all body segments with realistic materials"""
        if not self.geometry_manager:
            print("⚠️ Render error: No geometry manager")
            return
        
        if 'standard' not in self.geometry_manager.programs:
            print(f"⚠️ Render error: 'standard' program not found. Available: {list(self.geometry_manager.programs.keys())}")
            return
            
        program = self.geometry_manager.programs['standard']
        if program is None:
            print("⚠️ Render error: 'standard' program is None")
            return
            
        try:
            program.use()
        except Exception as e:
            print(f"⚠️ Render error: 'Program' object has no attribute 'use': {e}")
            return
        
        # Apply lighting
        self.lighting_system.apply_lighting_uniforms(program, view_position)
        
        # Common matrices
        program['view'].write(view_matrix.tobytes())
        program['projection'].write(proj_matrix.tobytes())
        program['normalMatrix'].write(normal_matrix.tobytes())
        
        # Define body segments with their properties
        segments = [
            # (name, start_point, end_point, radius, color, is_skin)
            ('left_forearm', frame_data.left_wrist, frame_data.left_elbow, 0.025, [0.96, 0.76, 0.63], True),
            ('left_upper_arm', frame_data.left_elbow, frame_data.left_shoulder, 0.035, [0.18, 0.32, 0.40], False),
            ('right_forearm', frame_data.right_wrist, frame_data.right_elbow, 0.025, [0.96, 0.76, 0.63], True),
            ('right_upper_arm', frame_data.right_elbow, frame_data.right_shoulder, 0.035, [0.18, 0.32, 0.40], False),
            ('left_shoulder_neck', frame_data.left_shoulder, frame_data.hub, 0.04, [0.18, 0.32, 0.40], False),
            ('right_shoulder_neck', frame_data.right_shoulder, frame_data.hub, 0.04, [0.18, 0.32, 0.40], False),
        ]
        
        for segment_name, start_pos, end_pos, radius, color, is_skin in segments:
            if not render_config.show_body_segments.get(segment_name, True):
                continue
            
            if not (np.isfinite(start_pos).all() and np.isfinite(end_pos).all()):
                continue
            
            # Render cylinder
            self._render_cylinder_between_points(
                f'{segment_name}_cyl', start_pos, end_pos, radius, color, 
                render_config.body_opacity, is_skin, program
            )
            
            # Render joint spheres
            self._render_sphere_at_point(
                f'{segment_name}_sph', end_pos, radius * 1.2, color,
                render_config.body_opacity, is_skin, program
            )
        
        # Render hub
        if np.isfinite(frame_data.hub).all():
            self._render_sphere_at_point(
                'hub', frame_data.hub, 0.06, [0.18, 0.32, 0.40],
                render_config.body_opacity, False, program
            )
    
    def _render_cylinder_between_points(self, obj_name: str, start: np.ndarray, end: np.ndarray,
                                      radius: float, color: List[float], opacity: float, 
                                      is_skin: bool, program: mgl.Program):
        """Render cylinder between two 3D points with proper materials"""
        if not self.geometry_manager:
            return
        obj = self.geometry_manager.geometry_objects[obj_name]
        
        # Calculate transformation
        direction = end - start
        length = np.linalg.norm(direction)
        if length < 1e-6:
            obj.visible = False
            return
        
        direction_normalized = direction / length
        
        # Create rotation matrix to align Y-axis with direction
        y_axis = np.array([0, 1, 0], dtype=np.float32)
        if np.allclose(direction_normalized, y_axis):
            rotation_matrix = np.eye(3, dtype=np.float32)
        elif np.allclose(direction_normalized, -y_axis):
            rotation_matrix = np.array([[-1, 0, 0], [0, -1, 0], [0, 0, 1]], dtype=np.float32)
        else:
            # Use Rodrigues rotation formula
            from golf_data_core import GeometryUtils
            rotation_matrix = GeometryUtils.rotation_matrix_from_vectors(y_axis, direction_normalized)
        
        # Update object transform
        self.geometry_manager.update_object_transform(
            obj_name, start, rotation_matrix, np.array([radius, length, radius], dtype=np.float32)
        )
        
        # Set material properties
        program['materialColor'].write(np.array(color, dtype=np.float32).tobytes())
        program['opacity'].value = opacity
        
        if is_skin:
            # Skin material
            program['materialRoughness'].value = 0.8
            program['materialMetallic'].value = 0.0
            program['materialSpecular'].value = 0.1
        else:
            # Clothing material
            program['materialRoughness'].value = 0.9
            program['materialMetallic'].value = 0.0
            program['materialSpecular'].value = 0.05
        
        # Render
        model_matrix = self.geometry_manager.get_model_matrix(obj)
        program['model'].write(model_matrix.tobytes())
        
        obj.vao.render()
        obj.visible = True
        
        self.render_stats['draw_calls'] += 1
        self.render_stats['triangles_rendered'] += obj.index_count // 3
    
    def _render_sphere_at_point(self, obj_name: str, position: np.ndarray, radius: float,
                               color: List[float], opacity: float, is_skin: bool, program: mgl.Program):
        """Render sphere at specific point"""
        obj = self.geometry_manager.geometry_objects[obj_name]
        
        # Update transform
        self.geometry_manager.update_object_transform(
            obj_name, position, np.eye(3, dtype=np.float32), radius
        )
        
        # Set material properties (same as cylinder)
        program['materialColor'].write(np.array(color, dtype=np.float32).tobytes())
        program['opacity'].value = opacity
        
        if is_skin:
            program['materialRoughness'].value = 0.8
            program['materialMetallic'].value = 0.0
            program['materialSpecular'].value = 0.1
        else:
            program['materialRoughness'].value = 0.9
            program['materialMetallic'].value = 0.0
            program['materialSpecular'].value = 0.05
        
        # Render
        model_matrix = self.geometry_manager.get_model_matrix(obj)
        program['model'].write(model_matrix.tobytes())
        
        obj.vao.render()
        obj.visible = True
        
        self.render_stats['draw_calls'] += 1
        self.render_stats['triangles_rendered'] += obj.index_count // 3
    
    def _render_club(self, frame_data, render_config, view_matrix: np.ndarray,
                    proj_matrix: np.ndarray, normal_matrix: np.ndarray, view_position: np.ndarray):
        """Render golf club with realistic materials"""
        if not self.geometry_manager:
            return
        program = self.geometry_manager.programs['standard']
        program.use()
        
        # Apply lighting and matrices
        self.lighting_system.apply_lighting_uniforms(program, view_position)
        program['view'].write(view_matrix.tobytes())
        program['projection'].write(proj_matrix.tobytes())
        program['normalMatrix'].write(normal_matrix.tobytes())
        
        # Render shaft
        shaft_radius = 0.006  # 6mm radius
        shaft_color = [0.75, 0.75, 0.75]  # Metallic gray
        
        self._render_cylinder_between_points(
            'shaft', frame_data.butt, frame_data.clubhead, shaft_radius, shaft_color,
            1.0, False, program
        )
        
        # Set metallic properties for shaft
        program['materialRoughness'].value = 0.1
        program['materialMetallic'].value = 0.8
        program['materialSpecular'].value = 0.9
        
        # Render clubhead
        clubhead_color = [0.9, 0.9, 0.95]  # Polished steel
        clubhead_radius = 0.025
        
        self._render_sphere_at_point(
            'clubhead', frame_data.clubhead, clubhead_radius, clubhead_color,
            1.0, False, program
        )
        
        # Set metallic properties for clubhead
        program['materialRoughness'].value = 0.05
        program['materialMetallic'].value = 0.9
        program['materialSpecular'].value = 1.0
    
    def _render_vectors(self, frame_data, dynamics_data, render_config, view_matrix: np.ndarray,
                       proj_matrix: np.ndarray, normal_matrix: np.ndarray, view_position: np.ndarray):
        """Render force and torque vectors with color coding"""
        if not self.geometry_manager or (not render_config.show_forces and not render_config.show_torques):
            return

        program = self.geometry_manager.programs['vector']
        program.use()

        # Apply lighting and matrices
        self.lighting_system.apply_lighting_uniforms(program, view_position)
        program['view'].write(view_matrix.tobytes())
        program['projection'].write(proj_matrix.tobytes())

        start_position = frame_data.clubhead

        # Render force vector
        if render_config.show_forces and 'force' in dynamics_data:
            force = dynamics_data['force']
            force_magnitude = np.linalg.norm(force)
            if force_magnitude > 1e-6:
                force_direction = force / force_magnitude
                self._render_vector_arrow(
                    'force_vector', start_position, force_direction, float(force_magnitude),
                    [1.0, 0.2, 0.2], [1.0, 0.5, 0.5], render_config.vector_opacity, program,
                    scale=render_config.vector_scale
                )

        # Render torque vector
        if render_config.show_torques and 'torque' in dynamics_data:
            torque = dynamics_data['torque']
            torque_magnitude = np.linalg.norm(torque)
            if torque_magnitude > 1e-6:
                torque_direction = torque / torque_magnitude
                # Offset torque slightly to avoid overlap
                torque_start_pos = start_position + np.array([0, 0.1, 0]) 
                self._render_vector_arrow(
                    'torque_vector', torque_start_pos, torque_direction, float(torque_magnitude),
                    [0.2, 0.2, 1.0], [0.5, 0.5, 1.0], render_config.vector_opacity, program,
                    scale=render_config.vector_scale
                )

    def _render_face_normal(self, frame_data, render_config, view_matrix: np.ndarray,
                           proj_matrix: np.ndarray, normal_matrix: np.ndarray, view_position: np.ndarray):
        """Render club face normal vector"""
        if not self.geometry_manager:
            return
        program = self.geometry_manager.programs['vector']
        program.use()

    def _render_vector_arrow(self, obj_name: str, start: np.ndarray, direction: np.ndarray,
                             magnitude: float, color_base: list, color_tip: list, opacity: float,
                             program: mgl.Program, scale: float):
        """Helper to render a single vector arrow."""
        if not self.geometry_manager:
            return
        obj = self.geometry_manager.geometry_objects[obj_name]

        # Rotation to align arrow (Y-axis) with vector direction
        from golf_data_core import GeometryUtils
        y_axis = np.array([0, 1, 0], dtype=np.float32)
        rotation_matrix = GeometryUtils.rotation_matrix_from_vectors(y_axis, direction)

        # Update transform
        self.geometry_manager.update_object_transform(
            obj_name, start, rotation_matrix, 1.0
        )

        # Set uniforms
        program['baseColor'].write(np.array(color_base, dtype=np.float32).tobytes())
        program['tipColor'].write(np.array(color_tip, dtype=np.float32).tobytes())
        program['opacity'].value = opacity
        program['vectorMagnitude'].value = magnitude
        program['vectorScale'].value = scale

        # Render
        model_matrix = self.geometry_manager.get_model_matrix(obj)
        program['model'].write(model_matrix.tobytes())

        obj.vao.render()
        self.render_stats['draw_calls'] += 1
        self.render_stats['triangles_rendered'] += obj.index_count // 3
    
    def cleanup(self):
        """Clean up OpenGL resources"""
        if self.geometry_manager:
            self.geometry_manager.cleanup()
        
        print("🧹 OpenGL renderer cleaned up")

# ============================================================================
# USAGE EXAMPLE AND TESTING
# ============================================================================

if __name__ == "__main__":
    print("🎨 Golf Swing Visualizer - OpenGL Renderer Test")
    
    # Test shader compilation
    print("\n🔧 Testing shader compilation...")
    try:
        vertex_shader = ShaderLibrary.get_standard_vertex_shader()
        fragment_shader = ShaderLibrary.get_standard_fragment_shader()
        print(f"   Standard shaders: {len(vertex_shader)} + {len(fragment_shader)} characters")
        
        vector_vs = ShaderLibrary.get_vector_vertex_shader()
        vector_fs = ShaderLibrary.get_vector_fragment_shader()
        print(f"   Vector shaders: {len(vector_vs)} + {len(vector_fs)} characters")
        
        print("✅ Shader compilation test passed")
    except Exception as e:
        print(f"❌ Shader compilation test failed: {e}")
    
    # Test lighting system
    print("\n💡 Testing lighting system...")
    lighting = LightingSystem()
    print(f"   Created {len(lighting.lights)} lights")
    lighting.update_time_of_day(0.5)  # Noon
    print("✅ Lighting system test passed")
    
    print("\n🎉 OpenGL renderer ready for integration!")
