# Im2mesh (2D image to finite element mesh)



**Im2mesh** is a MATLAB/Octave package for generating finite element mesh based on 2D segmented multi-phase image. It provides a robust workflow capable of processing various input images, such as microstructure images of engineering materials. Due to its generalized framework, Im2mesh can handle segmented image with more than 10 phases.  Im2mesh is originally released on [MathWorks File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/71772-im2mesh-2d-image-to-finite-element-meshes) in 2019.

<p align="center">
  <img src = "https://github.com/mjx888/im2mesh/blob/main/example_kumamon.png" height="100"> &nbsp
  <img src = "https://github.com/mjx888/im2mesh/blob/main/example_shape.png" height="100"> &nbsp
  <img src = "https://github.com/mjx888/im2mesh/blob/main/example_concrete.png" height="100"> 
</p>


**Features**:

- Accurately preserve the contact details between different phases.
- Incorporates polyline smoothing and simplification
- Able to avoid sharp corners when simplifying polylines.
- Support phase selection before meshing.
- Two mesh generators are available for selection: [MESH2D](https://github.com/dengwirda/mesh2d), and [generateMesh](https://www.mathworks.com/help/pde/ug/pde.pdemodel.generatemesh.html).
- Generated mesh can be exported as `inp` file (Abaqus) and `bdf` file (Nastran bulk data, compatible with COMSOL).
- Graphical user interface (GUI) version is available as a MATLAB app.

## How to start

After downloading Im2mesh, I suggest you start with [Im2mesh_GUI app](https://github.com/mjx888/im2mesh/tree/main/Im2mesh_GUI%20app) in the folder, which will help you understand the workflow and parameters of Im2mesh. A detailed tutorial is provided in [Im2mesh_GUI Tutorial.pdf](https://github.com/mjx888/im2mesh/blob/main/Im2mesh_GUI%20Tutorial.pdf). 

Then, you can learn to use Im2mesh package in the folder "Im2mesh_Matlab" or "Im2mesh_Octave". 11 examples are provided.  If you're using MATLAB ,  examples are live script `mlx` files (`demo1.mlx` ~ `demo11.mlx`). If you're using Octave,  examples are `m` files (`demo1.m` ~ `demo10.m`).  Examples are also available as `html` files in the folder "demo_html".

Examples:

- demo01 - Demonstrate function `im2mesh`, which use MESH2D as mesh generator.
- demo02 - Demonstrate function `im2meshBuiltIn`, which use MATLAB built-in function `generateMesh` as mesh generator.
- demo03 - Demonstrate how to export mesh as `inp`, `bdf`, and `node`/`ele` file
- demo04 - Demonstrate what is inside function `im2mesh`.
- demo05 - Demonstrate parameter `tf_avoid_sharp_corner`
- demo06 - Demonstrate thresholds in polyline smoothing
- demo07 - Demonstrate parameter `grad_limit` for mesh generation
- demo08 - Demonstrate parameter `hmax` for mesh generation
- demo09 - Demonstrate how to select phases for meshing
- demo10 - Demonstrate different polyline smoothing techniques
- demo11 - Demonstrate how to find node sets at the interface and boundary

## Potential bugs

When the mesh with second order element are exported to Abaqus, the mesh may have error.

## Cite as

Jiexian Ma (2025). Im2mesh (2D image to finite element meshes) (https://www.mathworks.com/matlabcentral/fileexchange/71772-im2mesh-2d-image-to-finite-element-meshes), MATLAB Central File Exchange. Retrieved January 30, 2025.

## Acknowledgments

Great thanks Dr. Yang Lu (Boise State University) providing valuable advice on Im2mesh. 