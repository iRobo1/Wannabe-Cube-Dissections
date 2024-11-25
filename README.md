# Wannabe Cube Dissections
This repository contains some solvers for finding Wannabe Cube dissections. The problem was posed by Chris Wolird. See https://math.stackexchange.com/questions/4528483/other-solutions-to-cubing-the-cube-variation for more information.

A Wannabe Cube is a cuboid with dimensions n by n+1 by n+2. The goal is to determine whether there exists a dissection of a Wannabe Cube into smaller distinct Wannabe Cubes, except for the trivial case when n=5. I have proven that no Wannabe Cube with n < 77 (apart from n=5) can be dissected. As far as I'm aware, it is still an open question whether any other dissection exists at all. I believe it's rather unlikely that another dissection exists, and perhaps some day I'll have time to prove that :)

# A Short Proof for n=41
Before I introduce the tools I used to prove dissections do not exist for larger cases, let us consider n=41. It was posed by Chris Wolird as a sub-problem to the main challenge. This is the first Wannabe Cube for which there exists a set of smaller distinct Wannabe Cubes that add up to the correct volume and where the two largest Wannabe Cubes fit (constraints 1 and 2 in `SubsetSum.mzn`). I will shortly explain constraint 3 on one of the 5 subsets that fulfil constraints 1 and 2. The following is one such subset: {3,4,5,6,8,9,11,12,13,14,15,16,17,18,19,20,21,22}. Consider the 9 largest Wannabe Cubes {14,15,16,17,18,19,20,21,22}. Let us assume they are all normal cubes, that is, smaller than their Wannabe Cube version. If these 8 cubes do not fit into the 41 by 42 by 43 cuboid, then the cuboid cannot be dissected by the Wannabe Cubes either. The largest 8 cubes can be placed, e.g., in the corners of the 41st Wannabe Cube. The last Wannabe Cube (14) must fall between two other cubes. Let us pick the smallest ones, 15 and 16, and let us ensure all three are along the longest axis of the Wannabe Cube. Since 14+15+16 > 43, this cannot be done. The same logic can be applied to the other subsets and other values of n. This can also be extended easily for the 10th cube and with a little bit more difficulty for the 11th cube. With subsequent cubes, this becomes less powerful and the size of the boolean constraint explodes.

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

n=75 is proven unsatisfiable with this technique. The program is too slow to prove cases where n > 76.

## WannabeCubeDissections.mzn
Same as the above program but for actual Wannabe Cubes. For example, it can be used to find that n=5 is dissectable.

# To Run
Install MiniZinc (a language used for constraint programming) and run the file of interest. See comments in files for further information.
