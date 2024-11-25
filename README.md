# Wannabe Cube Dissections
This repository contains some solvers for finding Wannabe Cube dissections. The problem was posed by Chris Wolird. See https://math.stackexchange.com/questions/4528483/other-solutions-to-cubing-the-cube-variation for more information.

A Wannabe Cube is a cuboid with dimensions n by n+1 by n+2. The goal is to determine whether there exists a dissection of a Wannabe Cube into smaller distinct Wannabe Cubes. There exists one trivial dissection for n=5. I have proven that no Wannabe Cube with n < 77 (apart from n=5) can be dissected.

# Files
The repository contains 3 files that can be used to prune possible solutions or prove in general that none exist for a particular value of n.

## SubsetSum.mzn
The main tool of interest is `SubsetSum.mzn`. It prunes subsets (a set of smaller distinct Wannabe Cubes) that could be used to dissect a larger Wannabe Cube. It finds no valid subset that can be arranged to form a larger Wannabe Cube when n < 75. There are a number of constraints used to prune subsets:
1. The total volume of all the Wannabe Cubes in the subset must add up to the volume of the target Wannabe Cube
2. The 2 largest Wannabe Cubes must fit next to one another
3. The 9 largest Wannabe Cubes can potentially fit next to one another (*an upper bound)
4. The 10 largest Wannabe Cubes can potentially fit next to one another (*an upper bound)
5. The 11 largest Wannabe Cubes can potentially fit next to one another (*an upper bound)

*The program will only prune a subset that certainly cannot fit

n = 75 is the first Wannabe Cube with subsets that satisfy all the constraints. However, both are proven unsatisfiable with `CubeDissections.mzn`.
n = 76, 78, 80 also have no valid subsets
n = 77 is too computationally expensive to check with `CubeDissections.mzn`

## CubeDissections.mzn
Uses a stronger condition than `SubsetSum.mzn` to prune remaining valid subsets. Each Wannabe Cube (except the one that is being dissected) is modelled as a normal cube using its shortest side length. The program then checks if it is possible to pack all these smaller and simpler cubes into the target Wannabe Cube. If not, the problem must be unsatisfiable also in the case of Wannabe Cubes.

n=75 is proven unsatisfiable with this technique. (Note, of course, for any n < 75, this could also be used.)

## WannabeCubeDissections.mzn
Same as the above program but for actual Wannabe Cubes. For example, it can be used to find that n=5 is dissectable. It could also find a dissection for any subset found by `SubsetSum.mzn`; however, this is quite unlikely. I believe no other solutions except n=5 exist. Perhaps I'll have time to prove it some day :)

# To Run
Install MiniZinc (a language used for constraint programming) and run the file of interest. See comments in files for further information.
