# Im2mesh (2D image to finite element mesh)



**Im2mesh** is a MATLAB/Octave package for generating finite element mesh based on 2D segmented multi-phase image. Im2mesh provides a robust workflow to handle different kinds of input images, such as microstructure images of engineering materials. Due to its generalized framework, Im2mesh can handle segmented image with more than 10 phases. 

![four_examples](C:\Users\Jason\Downloads\GitHub\im2mesh\four_examples.png)

<img src="C:\Users\Jason\Downloads\GitHub\im2mesh\four_examples.png" width=500>

<img src="https://github.com/mjx888/im2mesh/blob/main/four_examples.png" height=220>

<p align="center">
  <img src = "https://github.com/mjx888/im2mesh/blob/main/example_kumamon.png" height="100"> &nbsp &nbsp &nbsp &nbsp
  <img src = "https://github.com/mjx888/im2mesh/blob/main/example_shape.png" height="100"> &nbsp &nbsp &nbsp &nbsp
  <img src = "https://github.com/mjx888/im2mesh/blob/main/example_concrete.png" height="100"> 
</p>

Features:

Exactly reserve the contact detail between different phases.
Incorporating polyline smoothing and simplification
Able to avoid sharp corners when simplifying polyline.
Support phase selection before meshing.
Two mesh generators are available for selection.
Generated mesh can be exported as inp file (Abaqus) and bdf file (Nastran bulk data, compatible with COMSOL).

Examples

demo01 - Demonstrate function im2mesh, which use MESH2D as mesh generator.
demo02 - Demonstrate function im2meshBuiltIn, which use matlab built-in function generateMesh as mesh generator.
demo03 - Demonstrate how to export mesh as inp, bdf, and .node/.ele file
demo04 - Demonstrate what is inside function im2mesh.
demo05 - Demonstrate parameter tf_avoid_sharp_corner
demo06 - Demonstrate thresholds in polyline smoothing
demo07 - Demonstrate parameter grad_limit for mesh generation
demo08 - Demonstrate parameter hmax for mesh generation
demo09 - Demonstrate how to select phases for meshing
demo10 - Demonstrate different polyline smoothing techniques
