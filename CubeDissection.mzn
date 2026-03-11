/*
MIT License

Copyright (c) 2026 Sandro Karhula

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/*
In the following program, cubes are considered to be n by n by n (i.e., not Wannabe cubes).
The program tests whether a set of cubes (with side lengths `cubeSizes`) can be packed into
a Wannabe cube with the shortest side being targetCubeSize.

To use, please define the targetCubeSize, cubeSizes, and breakSymmtryIndex parameters.

Please use the OR Tools CP-SAT solver. It is the fastest (and other solvers may raise exceptions).
Also set the number of threads to at least 8 (even if you don't have that many! OR Tools will then
apply some optimisations that improve the speed).
*/

% Target Wannabe cube size
int: targetCubeSize = 100;

% Cubes used for filling the Wannabe cube
array[int] of int: cubeSizes = [2,3,5,6,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,45,46,50,52];

% The cube that is used to create some symmetry constraints
% I am lazy, so please set this by hand to the index of the largest cube such that
% (cubeSizes[breakSymmetryIndex] + targetCubeSize) mod 2 = 1
int: breakSymmetryIndex = length(cubeSizes);



include "alldifferent.mzn";

type Cube = var record(int: x, int: y, int: z, int: l);

array[1..length(cubeSizes)] of var Cube: cubes;

% Populate the cubes array with cubes from cubeSizes
constraint forall(i in index_set(cubes)) (cubes[i].l = cubeSizes[i]);

% Every cube is within the bounds of the target cube
constraint forall(c in cubes) (
  c.x >= 0 /\ c.y >=0 /\ c.z >= 0 /\
  c.x + c.l <= targetCubeSize /\
  c.y + c.l <= targetCubeSize + 1 /\
  c.z + c.l <= targetCubeSize + 2
);

% A predicate that returns true if cubes c1 and c2 do not overlap
predicate no_overlap(Cube: c1, Cube: c2) = 
  c1.x + c1.l <= c2.x \/
  c2.x + c2.l <= c1.x \/
  c1.y + c1.l <= c2.y \/
  c2.y + c2.l <= c1.y \/
  c1.z + c1.l <= c2.z \/
  c2.z + c2.l <= c1.z;

% Ensures cubes do not overlap
constraint forall(i, j in index_set(cubes) where i < j) (
  no_overlap(cubes[i], cubes[j])
);

% The target cube is dissected in a fixed orientation (breaks 7 of 8 symmetries)
constraint symmetry_breaking_constraint(
  2 * cubes[breakSymmetryIndex].x <= (targetCubeSize + 1 - cubes[breakSymmetryIndex].l) /\
  2 * cubes[breakSymmetryIndex].y <= (targetCubeSize + 1 - cubes[breakSymmetryIndex].l) /\
  2 * cubes[breakSymmetryIndex].z <= (targetCubeSize + 1 - cubes[breakSymmetryIndex].l)
);

% use this to find all solutions
solve satisfy; % for n=100, ~38 s

% use this to find whether a solution exists (counterintuitively, this searches in a better order)

%solve minimize sum([min(cubes[i].x, min(cubes[i].y, cubes[i].z)) * cubes[i].l | i in index_set(cubeSizes)]); % n=100, ~21 s
