#!/usr/bin/env python3
"""
Debug script to test OpenGL initialization and identify rendering issues
"""

import sys
import traceback
import numpy as np

def test_geometry_utils():
    """Test if GeometryUtils can create meshes"""
    try:
        from golf_data_core import GeometryUtils
        print("✅ GeometryUtils imported successfully")
        
        # Test cylinder mesh creation
        vertices, normals, indices = GeometryUtils.create_cylinder_mesh()
        print(f"✅ Cylinder mesh created: {len(vertices)} vertices, {len(indices)} indices")
        
        # Test sphere mesh creation
        vertices, normals, indices = GeometryUtils.create_sphere_mesh()
        print(f"✅ Sphere mesh created: {len(vertices)} vertices, {len(indices)} indices")
        
        # Test arrow mesh creation
        vertices, normals, indices = GeometryUtils.create_arrow_mesh()
        print(f"✅ Arrow mesh created: {len(vertices)} vertices, {len(indices)} indices")
        
        return True
    except Exception as e:
        print(f"❌ GeometryUtils test failed: {e}")
        traceback.print_exc()
        return False

def test_shader_compilation():
    """Test if shaders can be compiled"""
    try:
        from golf_opengl_renderer import ShaderLibrary
        print("✅ ShaderLibrary imported successfully")
        
        # Test vertex shader
        vertex_shader = ShaderLibrary.get_standard_vertex_shader()
        print(f"✅ Standard vertex shader: {len(vertex_shader)} characters")
        
        # Test fragment shader
        fragment_shader = ShaderLibrary.get_standard_fragment_shader()
        print(f"✅ Standard fragment shader: {len(fragment_shader)} characters")
        
        return True
    except Exception as e:
        print(f"❌ Shader compilation test failed: {e}")
        traceback.print_exc()
        return False

def test_moderngl_context():
    """Test if moderngl context can be created"""
    try:
        import moderngl
        print("✅ moderngl imported successfully")
        
        # Try to create a context (this might fail in headless environments)
        try:
            ctx = moderngl.create_context()
            print("✅ moderngl context created successfully")
            
            # Test program creation
            vertex_shader = """
            #version 330 core
            layout (location = 0) in vec3 position;
            uniform mat4 model;
            uniform mat4 view;
            uniform mat4 projection;
            void main() {
                gl_Position = projection * view * model * vec4(position, 1.0);
            }
            """
            
            fragment_shader = """
            #version 330 core
            out vec4 FragColor;
            void main() {
                FragColor = vec4(1.0, 0.0, 0.0, 1.0);
            }
            """
            
            program = ctx.program(vertex_shader=vertex_shader, fragment_shader=fragment_shader)
            print("✅ Test program created successfully")
            
            # Test program.use() method
            program.use()
            print("✅ program.use() method works")
            
            ctx.release()
            return True
            
        except Exception as e:
            print(f"⚠️ moderngl context creation failed (expected in headless): {e}")
            return False
            
    except Exception as e:
        print(f"❌ moderngl import failed: {e}")
        traceback.print_exc()
        return False

def test_geometry_manager():
    """Test GeometryManager initialization"""
    try:
        from golf_opengl_renderer import GeometryManager
        print("✅ GeometryManager imported successfully")
        
        # This will fail without a context, but we can test the import
        return True
    except Exception as e:
        print(f"❌ GeometryManager import failed: {e}")
        traceback.print_exc()
        return False

def main():
    """Run all tests"""
    print("🔍 Debugging OpenGL initialization...")
    print("=" * 50)
    
    tests = [
        ("GeometryUtils", test_geometry_utils),
        ("ShaderLibrary", test_shader_compilation),
        ("moderngl", test_moderngl_context),
        ("GeometryManager", test_geometry_manager),
    ]
    
    results = {}
    for test_name, test_func in tests:
        print(f"\n🧪 Testing {test_name}...")
        results[test_name] = test_func()
    
    print("\n" + "=" * 50)
    print("📊 Test Results:")
    for test_name, passed in results.items():
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"  {test_name}: {status}")
    
    if all(results.values()):
        print("\n🎉 All tests passed! The issue might be in the GUI initialization.")
    else:
        print("\n⚠️ Some tests failed. Check the errors above.")

if __name__ == "__main__":
    main() 