# Im2mesh (2D image to finite element mesh)



**Im2mesh** is a MATLAB/Octave package for generating finite element mesh based on 2D segmented multi-phase image. It provides a robust workflow capable of processing various input images, such as microstructure images of engineering materials. Due to its generalized framework, Im2mesh can handle segmented image with more than 10 phases.  Im2mesh is originally released on [MathWorks File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/71772-im2mesh-2d-image-to-finite-element-mesh) in 2019.

<p align="center">
  <img src = "https://github.com/mjx888/im2mesh/blob/main/example_kumamon.png" height="100"> &nbsp
  <img src = "https://github.com/mjx888/im2mesh/blob/main/example_shape.png" height="100"> &nbsp
  <img src = "https://github.com/mjx888/im2mesh/blob/main/example_concrete.png" height="100"> 
</p>


**News:**

​    Version 2.1.5 fixed bugs for quadratic elements.

​    Version 2.1.0 is a huge update. Im2mesh package can run on GNU Octave now! 

**Features:**

- Accurately preserve the contact details between different phases.
- Incorporates polyline smoothing and simplification
- Able to avoid sharp corners when simplifying polylines.
- Support phase selection before meshing.
- Two mesh generators are available for selection: [MESH2D](https://github.com/dengwirda/mesh2d), and [generateMesh](https://www.mathworks.com/help/pde/ug/pde.pdemodel.generatemesh.html).
- Generated mesh can be exported as `inp` file (Abaqus) and `bdf` file (Nastran bulk data, compatible with COMSOL).
- Graphical user interface (GUI) version is available as a MATLAB app.

## How to start

After downloading Im2mesh package ([releases](https://github.com/mjx888/im2mesh/releases)), I suggest you start with [Im2mesh_GUI app](https://github.com/mjx888/im2mesh/tree/main/Im2mesh_GUI%20app) in the folder, which will help you understand the workflow and parameters of Im2mesh. A detailed tutorial is provided in [Im2mesh_GUI Tutorial.pdf](https://github.com/mjx888/im2mesh/blob/main/Im2mesh_GUI%20Tutorial.pdf). 

Then, you can learn to use Im2mesh package in the folder "Im2mesh_Matlab" or "Im2mesh_Octave". 11 examples are provided.  If you're using MATLAB ,  examples are live script `mlx` files (`demo1.mlx` ~ `demo11.mlx`). If you're using Octave,  examples are `m` files (`demo1.m` ~ `demo10.m`).  Examples are also available as `html` files in the folder "demo_html".

**Examples:**

- [demo01](https://mjx888.github.io/im2mesh_demo_html/demo01.html) - Demonstrate function `im2mesh`, which use MESH2D as mesh generator.
- [demo02](https://mjx888.github.io/im2mesh_demo_html/demo02.html) - Demonstrate function `im2meshBuiltIn`, which use MATLAB built-in function `generateMesh` as mesh generator.
- [demo03](https://mjx888.github.io/im2mesh_demo_html/demo03.html) - Demonstrate how to export mesh as `inp`, `bdf`, and `node`/`ele` file
- [demo04](https://mjx888.github.io/im2mesh_demo_html/demo04.html) - Demonstrate what is inside function `im2mesh`.
- [demo05](https://mjx888.github.io/im2mesh_demo_html/demo05.html) - Demonstrate parameter `tf_avoid_sharp_corner`
- [demo06](https://mjx888.github.io/im2mesh_demo_html/demo06.html) - Demonstrate thresholds in polyline smoothing
- [demo07](https://mjx888.github.io/im2mesh_demo_html/demo07.html) - Demonstrate parameter `grad_limit` for mesh generation
- [demo08](https://mjx888.github.io/im2mesh_demo_html/demo08.html) - Demonstrate parameter `hmax` for mesh generation
- [demo09](https://mjx888.github.io/im2mesh_demo_html/demo09.html) - Demonstrate how to select phases for meshing
- [demo10](https://mjx888.github.io/im2mesh_demo_html/demo10.html) - Demonstrate different polyline smoothing techniques
- [demo11](https://mjx888.github.io/im2mesh_demo_html/demo11.html) - Demonstrate how to find node sets at the interface and boundary

## Other related projects

- [pixelMesh (pixel-based mesh)](https://www.mathworks.com/matlabcentral/fileexchange/104715-pixelmesh-pixel-based-mesh?s_tid=srchtitle)
- [voxelMesh (voxel-based mesh)](https://www.mathworks.com/matlabcentral/fileexchange/104720-voxelmesh-voxel-based-mesh)

## Cite as

You can cite this work as follows for now. I will probably put a DOI here in March.

Jiexian Ma (2025). Im2mesh (2D image to finite element mesh) (https://www.mathworks.com/matlabcentral/fileexchange/71772-im2mesh-2d-image-to-finite-element-mesh), MATLAB Central File Exchange. Retrieved February 3, 2025.

## Acknowledgments

Great thanks Dr. Yang Lu providing valuable advice on Im2mesh. 
