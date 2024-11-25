/*
In the following program, cubes are considered to be Wannabe cubes (n by n+1 by n+2).
The program tests whether a set of cubes (with side lengths `cubeSizes`) can be packed into
a Wannabe cube with the shortest side being targetCubeSize.

To use, please define the targetCubeSize and cubeSizes parameters.

Please use the OR Tools CP-SAT solver. It is the fastest (and other solvers may raise exceptions)
Also set the number of threads to at least 8 (even if you don't have that many! OR Tools will then
apply some optimisations that improve the speed).
*/

include "alldifferent.mzn";

% Target Wannabe cube size
int: targetCubeSize = 5;

% Cubes used for filling the Wannabe cube
set of int: cubeSizes = 1..4;

/* an example subset for n=1000 produced by `SubsetSum.mzn`
set of int: cubeSizes = 1,3,4,5,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,245,246,247,248,251,252,255];
*/

function var int: cube_size(Cube: cube) = min(cube.dx, min(cube.dy, cube.dz));

type Coord = var record(int: x, int: y, int: z);
type Dimensions = var record(int: dx, int: dy, int: dz);
type Cube = var Coord ++ var Dimensions;

array[1..length(cubeSizes)] of var Cube: cubes;

% Populate the cubes array with cubes from cubeSizes
constraint forall(i in index_set(cubes)) (cube_size(cubes[i]) = cubeSizes[i]);

% Every cube is s by s+1 by s+1 (but with any orientation)
constraint forall(c in cubes) (
  (c.dx = c.dy + 1 /\ c.dx = c.dz + 2) \/
  (c.dx = c.dz + 1 /\ c.dx = c.dy + 2) \/
  (c.dy = c.dx + 1 /\ c.dy = c.dz + 2) \/
  (c.dy = c.dz + 1 /\ c.dy = c.dx + 2) \/
  (c.dz = c.dy + 1 /\ c.dz = c.dx + 2) \/
  (c.dz = c.dx + 1 /\ c.dz = c.dy + 2)
);

% Every cube is within the bounds of the target cube
constraint forall(c in cubes) (
  c.x >= 0 /\ c.y >=0 /\ c.z >= 0 /\
  c.x + c.dx <= targetCubeSize /\
  c.y + c.dy <= targetCubeSize + 1 /\
  c.z + c.dz <= targetCubeSize + 2
);

% A predicate that returns true if cubes c1 and c2 do not overlap
predicate no_overlap(Cube: c1, Cube: c2) = 
  c1.x + c1.dx <= c2.x \/
  c2.x + c2.dx <= c1.x \/
  c1.y + c1.dy <= c2.y \/
  c2.y + c2.dy <= c1.y \/
  c1.z + c1.dz <= c2.z \/
  c2.z + c2.dz <= c1.z;

% Cubes do not overlap
constraint forall(i, j in index_set(cubes) where i < j) (
  no_overlap(cubes[i], cubes[j])
);

% Target cube is dissected in a fixed orientation (breaks 7 of 8 symmetries)
% Warning: works only when the first cube is n=1. Fix in the future :)
% MiniZinc has extremely poor support for records, which makes writing general
% code for this difficult :/
constraint symmetry_breaking_constraint(
  if(targetCubeSize mod 2 = 0) then 
    cubes[1].x < targetCubeSize / 2 /\
    cubes[1].y < (targetCubeSize + 1) / 2 /\
    cubes[1].z < (targetCubeSize + 2) / 2
  else
    cubes[1].x <= targetCubeSize / 2 /\
    cubes[1].y <= (targetCubeSize + 1) / 2 /\
    cubes[1].z <= (targetCubeSize + 2) / 2
  endif
);

solve satisfy;