/*
I will refer to Wannabe cubes (n by n+1 by n+2) as cubes or Wannabe cubes interchangeable.

This program finds a subset of Wannabe cubes smaller than n that may be able
to dissect a Wannabe cube with the shortest side equal to `targetCubeSize`.

The subsets found by the program fulfil the following restrictions:
1. the total volume of all the cubes in the subset is equal to the volume of
   the target cube (subset sum part)
2. the two largest cubes fit side by side
3. the 9 largest cubes probably fit (*upper bound)
4. the 10 largest cubes probably fit (*upper bound)
5. the 11 largest cubes probably fit (*upper bound)

*The program will only prune a subset that certainly cannot fit

Can these constraints be generalised? Yes, but their size will explode.
Is there a different way to express something stronger? Yes, try packing
the pruned subsets produced with this program as normal cubes (n by n by n)
into a target Wannabe cube. This is a stronger condition than constraints
2-5 (and any following ones). See file `CubeDissection.mzn` for this.

You may choose between finding a solution, all solutions, or some 'good' solution
according to certain metrics.

Please use the OR Tools CP-SAT solver. It is the fastest (and other solvers may raise exceptions).
Also set the number of threads to at least 8 (even if you don't have that many! OR Tools will then
apply some optimisations that improve the speed).

Results:
Constraints 1 and 2 prune all solutions lower than 41 (except 5, which is dissectable).
Adding constraint 3 prunes solutions lower than 49
Adding constraint 4 prunes solutions lower than 59
And finally adding constraint 5 prunes solutions lower than 75.
*/

int: targetCubeSize = 75; % Target cube size, e.g., 5, 41 or 100.

% Calculates the volume of a cube
function int: cubeVolume(int: cubeSize) = cubeSize * (cubeSize + 1) * (cubeSize + 2);

% Finds the nth largest cube in a set
function var int: nthLargestCube(var set of int: cubes, int: n) =
    if(n == 1) then max(cubes) else nthLargestCube(cubes diff {max(cubes)}, n-1) endif;

% Our decision variable is the set of cubes
var set of 1..targetCubeSize-1: cubeSizes;

% Choice of cubes sums to correct volume
constraint sum(s in cubeSizes) (cubeVolume(s)) = cubeVolume(targetCubeSize);

% The 1st and 2nd largest cubes fit next to each other
constraint nthLargestCube(cubeSizes, 2)
         + nthLargestCube(cubeSizes, 1) <= targetCubeSize + 2;

% The 7th, 8th, and 9th largest cubes fit next to each other (got this idea when typing the above constraint)
constraint card(cubeSizes) < 9 \/ nthLargestCube(cubeSizes, 9)
         + nthLargestCube(cubeSizes, 8)
         + nthLargestCube(cubeSizes, 7) <= targetCubeSize + 2;

% Does the 10th largest cube fit? Feel free to convince yourself that cubes 9 and 6 give a valid lower bound
constraint card(cubeSizes) < 10 \/ nthLargestCube(cubeSizes, 10)
         + nthLargestCube(cubeSizes, 9)
         + nthLargestCube(cubeSizes, 6) <= targetCubeSize + 2;

% And the 11th? This one is probably more fun to derive/verify. Good luck ;)
% E.g., try to place these 11 cubes: {18,19,20,21,22,24,28,29,30,31,32}
% inside the 61st cube (part of a valid subset without this constraint)
constraint card(cubeSizes) < 11 \/ (
         (nthLargestCube(cubeSizes, 10)
         + nthLargestCube(cubeSizes, 9)
         + nthLargestCube(cubeSizes, 6) <= targetCubeSize + 2
         /\ nthLargestCube(cubeSizes, 11)
         + nthLargestCube(cubeSizes, 8)
         + nthLargestCube(cubeSizes, 5) <= targetCubeSize + 2)
         \/
         (nthLargestCube(cubeSizes, 10)
         + nthLargestCube(cubeSizes, 9)
         + nthLargestCube(cubeSizes, 5) <= targetCubeSize + 2
         /\ nthLargestCube(cubeSizes, 11)
         + nthLargestCube(cubeSizes, 8)
         + nthLargestCube(cubeSizes, 6) <= targetCubeSize + 2)
         \/
         (nthLargestCube(cubeSizes, 10)
         + nthLargestCube(cubeSizes, 8)
         + nthLargestCube(cubeSizes, 6) <= targetCubeSize + 2
         /\ nthLargestCube(cubeSizes, 11)
         + nthLargestCube(cubeSizes, 9)
         + nthLargestCube(cubeSizes, 5) <= targetCubeSize + 2)
         );


%solve satisfy; % slower but allows for exhaustive search (first solutions are found for n=75, takes about 1 min to find all)

solve maximize sum([s | s in cubeSizes]); % heuristic for finding the 'best' subset (too many to explore exhaustively)

%solve maximize card(cubeSizes); % another heuristic: larger subsets are more likely to be dissectable

%solve minimize card(cubeSizes); % smaller subsets are faster to process for cube dissection (but less likely to be dissectable)

/*
Further results:
n=75
[1,4,6,7,8,10,11,12,13,14,15,16,17,18,19,20,21,22,23,32,33,35,36,37,38,39]; % unsatisfiable (proved with `CubeDissection`)
[1,2,4,5,6,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,32,33,35,36,37,38,39]; % unsatisfiable (proved with `CubeDissection`)
n=76 no solutions
n=77 some subsets exist, haven't tested with CubeDissection
n=78 no solutions
n=79 some subsets exist, haven't tested with CubeDissection
n=80 no solutions
n > 80 subsets exists, haven't tested with CubeDissection
*/