# Im2mesh (2D image to finite element mesh)



**Im2mesh** is a MATLAB/Octave package for generating finite element mesh based on 2D segmented multi-phase image. It provides a robust workflow capable of processing various input images, such as microstructure images of engineering materials. Due to its generalized framework, Im2mesh can handle segmented image with more than 10 phases.  Im2mesh is originally released on [MathWorks File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/71772-im2mesh-2d-image-to-finite-element-mesh) in 2019.

<p align="center">
  <img src = "https://github.com/mjx888/im2mesh/blob/main/example_kumamon.png" height="100"> &nbsp
  <img src = "https://github.com/mjx888/im2mesh/blob/main/example_shape.png" height="100"> &nbsp
  <img src = "https://github.com/mjx888/im2mesh/blob/main/example_concrete.png" height="100"> 
</p>


**News:**

- **Version 2.2.0 can use Gmsh as mesh generator (unstructured quadrilateral mesh) !**
- Version 2.1.6 updates the DOI. Im2mesh is now citable.
- Version 2.1.5 fixes bugs for quadratic elements.
- Version 2.1.0 is a huge update. Im2mesh package can run on GNU Octave.

**Features:**

- Accurately preserve the contact details between different phases.
- Incorporates polyline smoothing and simplification
- Able to avoid sharp corners when simplifying polylines.
- Support phase selection before meshing.
- 3 mesh generators are available for selection: [MESH2D](https://github.com/dengwirda/mesh2d), [generateMesh](https://www.mathworks.com/help/pde/ug/pde.pdemodel.generatemesh.html), and [Gmsh](https://gmsh.info/).
- Generated mesh can be exported as `inp` file (Abaqus) and `bdf` file (Nastran bulk data, compatible with COMSOL). Mesh can be exported as many formats via Gmsh.
- Graphical user interface (GUI) version is available as a MATLAB app.

<p align="center">
  <img src = "https://github.com/mjx888/im2mesh/blob/main/GUI.png" height="300"> 
</p>

## How to start

After downloading Im2mesh package ([releases](https://github.com/mjx888/im2mesh/releases)), I suggest you start with [Im2mesh_GUI app](https://github.com/mjx888/im2mesh/tree/main/Im2mesh_GUI%20app) in the folder, which will help you understand the workflow and parameters of Im2mesh. A detailed tutorial is provided in [Im2mesh_GUI Tutorial.pdf](https://github.com/mjx888/im2mesh/blob/main/Im2mesh_GUI%20Tutorial.pdf). 

Then, you can learn to use Im2mesh package in the folder "Im2mesh_Matlab" or "Im2mesh_Octave". 11 examples are provided.  If you're using MATLAB ,  examples are live script `mlx` files (`demo1.mlx` ~ `demo12.mlx`). If you're using Octave,  examples are `m` files (`demo1.m` ~ `demo10.m`).  Examples are also available as `html` files in the folder "demo_html".

**Examples:**

- [demo01](https://mjx888.github.io/im2mesh_demo_html/demo01.html) - Demonstrate function `im2mesh`, which use MESH2D as mesh generator.
- [demo02](https://mjx888.github.io/im2mesh_demo_html/demo02.html) - Demonstrate function `im2meshBuiltIn`, which use MATLAB built-in function `generateMesh` as mesh generator.
- [demo03](https://mjx888.github.io/im2mesh_demo_html/demo03.html) - How to export mesh as `inp`, `bdf`, and `node`/`ele` file
- [demo04](https://mjx888.github.io/im2mesh_demo_html/demo04.html) - What is inside function `im2mesh`.
- [demo05](https://mjx888.github.io/im2mesh_demo_html/demo05.html) - Parameter `tf_avoid_sharp_corner`
- [demo06](https://mjx888.github.io/im2mesh_demo_html/demo06.html) - Thresholds in polyline smoothing
- [demo07](https://mjx888.github.io/im2mesh_demo_html/demo07.html) - Parameter `grad_limit` for mesh generation
- [demo08](https://mjx888.github.io/im2mesh_demo_html/demo08.html) - Parameter `hmax` for mesh generation
- [demo09](https://mjx888.github.io/im2mesh_demo_html/demo09.html) - How to select phases for meshing
- [demo10](https://mjx888.github.io/im2mesh_demo_html/demo10.html) - Different polyline smoothing techniques
- [demo11](https://mjx888.github.io/im2mesh_demo_html/demo11.html) - How to find node sets at the interface and boundary
- [demo12](https://mjx888.github.io/im2mesh_demo_html/demo12.html) - Demonstrate function `pixelMesh` (pixel-based quadrilateral mesh)
- [demo13](https://mjx888.github.io/im2mesh_demo_html/demo13.html) - How to use Gmsh as mesh generator

## Cite as

Ma, J., & Li, Y. (2025). Im2mesh: A MATLAB/Octave package for generating finite element mesh based on 2D multi-phase image (2.1.5). Zenodo. https://doi.org/10.5281/zenodo.14847059

## Acknowledgments

Great thanks Dr. Yang Lu providing valuable advice on Im2mesh. 

## Other related projects

- [pixelMesh (pixel-based mesh)](https://www.mathworks.com/matlabcentral/fileexchange/104715-pixelmesh-pixel-based-mesh?s_tid=srchtitle)
- [voxelMesh (voxel-based mesh)](https://www.mathworks.com/matlabcentral/fileexchange/104720-voxelmesh-voxel-based-mesh)