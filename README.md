:tomato: tomato - math::geometry 3D library
================
`tomato math::geometry` is an geometry 3D library with basics functions for working in 3D space...
This [Tcl](https://www.tcl.tk) package is inspired , copied (as best I could) from this great library written in .Net [Math.NET Spatial](https://spatial.mathdotnet.com/#Math-NET-Spatial). Some features for this class `Quaternion` are inspired by this python library [pyquaternion](http://kieranwynn.github.io/pyquaternion/).

#### Currently geometries supported are :
| Class | Description |
| ------ | ------ |
| Vector | A Class representing a Vector in 3D space |
| Ray | A Class representing a Ray in 3D space |
| Point | A Class representing a Point in 3D space  |
| Plane | A Class representing a Plane in 3D space |
| Matrix3d | Helper class for working with 3D matrixes |
| Basic Matrix | Defines the base class for Matrix classes (basic matrixes for `CoordinateSystem`, `Matrix3d` and `Vector`)|
| Line | A Class representing a Line in 3D space|
| Coordinate System | A Class representing a Coordinate System |
| Quaternion | A Class representing a Quaternion |
| Triangle | A Class representing a Triangle in 3D space |

License :
-------------------------
**tomato math::geometry** is covered under the terms of the [MIT](LICENSE) license.

Examples :
-------------------------
See **[Start page Documentation](http://htmlpreview.github.io/?https://github.com/nico-robert/tomato/blob/master/documentation/tomato.html)**

Release :
-------------------------
*  **26-02-2021** : 1.0
    - Initial release.
*  **21-03-2021** : 1.1
    - Add Quaternion Class.
*  **26-09-2021** : 1.2
    -  Add Triangle Class.
*  **16-10-2021** : 1.2.1
    - Bug fixes.
    - Tolerance geom and equal by default.
    - Generate a machine-readable error with *throw* command.
    - Helper.tcl : Add tcl::mathfunc : *Pi() + Inv()*.
    - Helper.tcl : Add *L2Norm* command.
    - Matrix.tcl : Add *==* and *!=* operators.
    - Matrix.tcl : Add *IsOrthogonal* command.
    - Matrix.tcl : Check if matrix is *singular*.
    - Ray3d.tcl  : Add *IntersectionRayWithPlane* command.
    - Triangle3d.tcl : Add *GetType* command.
*  **26-02-2022** : 1.2.2 
    - Vector3d.tcl : Correction 'lerp' command + cosmetic changes.
    - CoordinateSystem.tcl : Cosmetic changes.
    - Line3d.tcl : Cosmetic changes.
    - Matrix.tcl : Cosmetic changes.
    - Plane.tcl  : IntersectionWithRay + IntersectionWithLine calculation without projection
                + cosmetic changes.
    - Point3d.tcl : Cosmetic changes + tolerance documentation for 'IsCollinearPoints' command.
    - Quaternion.tcl : Cosmetic changes.
    - Triangle3d.tcl : Cosmetic changes.