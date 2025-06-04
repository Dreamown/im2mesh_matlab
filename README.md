# Im2mesh (2D image to finite element mesh)



**Im2mesh** is an open-source MATLAB/Octave package for generating finite element mesh based on 2D segmented multi-phase image. It provides a robust workflow capable of processing various input images, such as microstructure images of engineering materials. Due to its generalized framework, Im2mesh can handle segmented image with more than 10 phases.  Im2mesh was originally released on [MathWorks File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/71772-im2mesh-2d-image-to-finite-element-mesh) in 2019. 

Im2mesh can also be used as a mesh generation interface for MATLAB 2D multi-part geometry, aka multi-domain or multi-phase geometry (see demo14-17).

<p align="center">
  <img src = "https://mjx888.github.io/im2mesh_demo_html/example_tree.jpg" height="100"> &nbsp
  <img src = "https://mjx888.github.io/im2mesh_demo_html/example_shape.jpg" height="100"> &nbsp
  <img src = "https://mjx888.github.io/im2mesh_demo_html/example_concrete.jpg" height="100"> 
</p>


**News:**

- Version 2.45 can export polygonal boundaries as `dxf` file.
- Function `plotMeshes` become more powerful, providing a few plot style settings (see demo 08).
- Version 2.2.0 can use Gmsh as mesh generator (unstructured quadrilateral mesh).
- Version 2.1.6 updates the DOI. Im2mesh is now citable.

**Features:**

- Accurately preserve the contact details between different phases. 
- Incorporates polyline smoothing and simplification
- Able to edit polygonal boundary before mesh generation.
- Support phase selection and local mesh refinement.
- 4 mesh generators are available for selection: [MESH2D](https://github.com/dengwirda/mesh2d), [generateMesh](https://www.mathworks.com/help/pde/ug/pde.pdemodel.generatemesh.html), [Gmsh](https://gmsh.info/), and pixelMesh.
- Graphical user interface (GUI) version is available as a MATLAB app and as a standalone desktop application.

<p align="center">
  <img src = "https://mjx888.github.io/im2mesh_demo_html/GUI.png" height="300"> 
</p>


**Generated mesh can be exported as:** 

- `inp` file with boundary node set (Abaqus)
- `bdf` file (Nastran bulk data, compatible with COMSOL), 
- `msh` file (Gmsh mesh format)
- MATLAB PDE model object
- For other formats (such as `stl` and `vtk`), you can import the generated `msh` file into software Gmsh and then export.

## Dependencies

- When using Im2mesh package or Im2mesh_GUI in MATLAB, you need to install MATLAB and the following MATLAB toolboxes: Image Processing Toolbox, Mapping Toolbox.
- When using Im2mesh_GUI as a standalone desktop application, there is no need to install MATLAB or any MATLAB toolboxes. You can download the installer for standalone desktop app from: [link](https://mjx888.github.io/others/Installer_Im2mesh_GUI.zip)

## Version compatibility

- Im2mesh_GUI: MATLAB R2017b or later; version higher than R2018b is preferred.
- Im2mesh package: MATLAB R2017b or later. GNU Octave 9.3.0 or later.
- Gmsh: tested with version 4.13.1.

## How to start

After downloading Im2mesh package ([releases](https://github.com/mjx888/im2mesh/releases)), I suggest you start with [Im2mesh_GUI app](https://github.com/mjx888/im2mesh/tree/main/Im2mesh_GUI%20app) in the folder, which will help you understand the workflow and parameters of Im2mesh. A detailed tutorial is provided in [Im2mesh_GUI Tutorial.pdf](https://github.com/mjx888/im2mesh/blob/main/Im2mesh_GUI%20Tutorial.pdf). 

Then, you can learn to use Im2mesh package in the folder "Im2mesh_Matlab" or "Im2mesh_Octave". 16 examples are provided. 

- If you're using MATLAB,  examples are live script `mlx` files (`demo01.mlx` ~ `demo18.mlx`). If you find some text in the `mlx` file is missing, please read the `html` file instead. Note that `demo02.mlx` requires MATLAB Partial Differential Equation (PDE) Toolbox. If you don't have PDE Toolbox, you can skip `demo02.mlx`.
- If you're using Octave,  examples are `m` files (`demo01.m` ~ `demo10.m`).
- Examples are also available as `html` files in the folder "demo_html".

**Examples:**

- [demo01](https://mjx888.github.io/im2mesh_demo_html/demo01.html) - Demonstrate function `im2mesh`, which use `MESH2D` as mesh generator.
- [demo02](https://mjx888.github.io/im2mesh_demo_html/demo02.html) - Demonstrate function `im2meshBuiltIn`, which use MATLAB built-in function `generateMesh` as mesh generator.
- [demo03](https://mjx888.github.io/im2mesh_demo_html/demo03.html) - Export: save mesh as `inp`, `bdf`, and `msh` file; save geometry as `dxf` file, `geo` file or PSLG data.
- [demo04](https://mjx888.github.io/im2mesh_demo_html/demo04.html) - What is inside function `im2mesh`
- [demo05](https://mjx888.github.io/im2mesh_demo_html/demo05.html) - Avoid sharp corner
- [demo06](https://mjx888.github.io/im2mesh_demo_html/demo06.html) - Thresholds in polyline smoothing
- [demo07](https://mjx888.github.io/im2mesh_demo_html/demo07.html) - Parameter `grad_limit` and `hmax` in mesh generation
- [demo08](https://mjx888.github.io/im2mesh_demo_html/demo08.html) - Function `plotMeshes`
- [demo09](https://mjx888.github.io/im2mesh_demo_html/demo09.html) - How to select phases for meshing
- [demo10](https://mjx888.github.io/im2mesh_demo_html/demo10.html) - Different polyline smoothing techniques
- [demo11](https://mjx888.github.io/im2mesh_demo_html/demo11.html) - Find node sets at the interface and boundary
- [demo12](https://mjx888.github.io/im2mesh_demo_html/demo12.html) - Demonstrate function `pixelMesh` (pixel-based quadrilateral mesh)
- [demo13](https://mjx888.github.io/im2mesh_demo_html/demo13.html) - How to use `Gmsh` as mesh generator
- [demo14](https://mjx888.github.io/im2mesh_demo_html/demo14.html) - Use polyshape to define geometry for mesh generation
- [demo15](https://mjx888.github.io/im2mesh_demo_html/demo15.html) - Edit polygonal boundaries before meshing
- [demo16](https://mjx888.github.io/im2mesh_demo_html/demo16.html) - Add mesh seeds/nodes
- [demo17](https://mjx888.github.io/im2mesh_demo_html/demo17.html) - Refine mesh
- [demo18](https://mjx888.github.io/im2mesh_demo_html/demo18.html) - Create tetrahedral mesh based on 2D image

## Cite as

If you use Im2mesh, please cite it as follows.

Ma, Jiexian, & Li, Yuanyuan (2025). Im2mesh: A MATLAB/Octave package for generating finite element mesh based on 2D multi-phase image (2.1.5). Zenodo. https://doi.org/10.5281/zenodo.14847059

Once my paper is published, I will update a new DOI here.

## Acknowledgments

Many thanks to Dr. Yang Lu for providing valuable suggestions and testing of export formats. 

This project incorporates code from the following open-source projects. I appreciate the contributions of the original authors. Each incorporated code retains its original copyright.

- [MESH2D](https://github.com/dengwirda/mesh2d) by Darren Engwirda
- [dpsimplify](https://www.mathworks.com/matlabcentral/fileexchange/21132-line-simplification) by Wolfgang Schwanghart
- [p_poly_dist](https://www.mathworks.com/matlabcentral/fileexchange/12744-distance-from-points-to-polyline-or-polygon) by Michael Yoshpe
- [MeshQualityQuads](https://www.mathworks.com/matlabcentral/fileexchange/33108-unstructured-quadrilateral-mesh-quality-assessment) by Allan Peter Engsig-Karup
- [ccma](https://github.com/UniBwTAS/ccma) by UniBwTAS



## Other related projects

- [voxelMesh (voxel-based finite element mesh)](https://www.mathworks.com/matlabcentral/fileexchange/104720-voxelmesh-voxel-based-mesh)
- [writeMesh (write mesh to inp, bdf, and msh files)](https://www.mathworks.com/matlabcentral/fileexchange/180415-writemesh-write-mesh-to-inp-bdf-and-msh-files)

