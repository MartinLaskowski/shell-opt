# shell-opt

## A deterministic model for the [Shell.ai Hackathon 2024](https://www.hackerearth.com/challenges/new/competitive/shellai-hackathon-2024/)

The 2024 Shell.ai Hackathon challenges teams to build a fleet de-carbonization optimization model.

The model solves for the optimal quantity, timing and variety of vehicle acquisition, use and disposal within a hypothetical fleet over a 15-year time horizon.

The fleet must:

- observe a gradually lowering yearly upper bound on carbon emissions
- satisfy demand for haulage of loads of various size and distance
- cost as little as possible to operate (objective: minimize costs)

See the official <a href="/docs/Problem Statement - Detailed_final 3f65d376.pdf" target="_blank">Problem Description</a> and <a href="/docs/Shell.ai Hackathon 2024 Competition rules  4a9e89ab.pdf" target="_blank">Competition Rules</a>.

### In this repo...

- a deterministic [model](/model.mod) implementing the sets, parameters, variables, objective and constraints specified in the <a href="https://uc.hackerearth.com/he-public-data/Problem%20Statement%20-%20Detailed_final%203f65d376.pdf" target="_blank">Problem Description</a>.
  
- an execution [script](/script.run) that:
  - sets up an environment to run the model (I chose <a href="https://ampl.com/" target="_blank">AMPL</a>)
  - selects and parameterizes a suitable solver (I chose <a href="https://www.gurobi.com/" target="_blank">Gurobi</a>)
  - imports the supplied [data](/data/) into the model session
  - runs the [model](/model.mod)
  - outputs the solution to a [submission file](/data/submission.csv) (for which I use a [second script](/print_submission.run))

### To deploy and run..

1. Download/clone this repo
2. Get and activate the AMPL Community Edition (whose downloadable bundle contains many solvers, including Gurobi)
3. Start an AMPL session with the `ampl` command in the terminal
4. In the AMPL sesison, run the main script with `include script.run` 

### A handy Formulation-to-Model-Entity whiteboard

I sketched a <a href="https://whimsical.com/shell-hackathon-2024-bHgXJ4oMZ2gmSPdVNcJDB" target="_blank">whiteboard</a> that relates the formulation entities named in the problem description to the model entities I implement in my model.

**Note**:
- ancillary and additional variables I implement in the model are not shown
- I imply but do not explicitly implement certain of the formulation's "accounting" variables, such as those named A, B, C, D, E, etc.


### How this model came to be

I was unaware of the competition when a friend and contestant asked me for conversation about their own formulation. While getting my head into the game I built the deterministic model included here.

However, that contestant (a Rockstar!) eventually built a solid model all of their own without my help, and also implemented the required stochastic component of the challenge, which I never did.

### Next steps (might have been)...

The bulk of the competitive scoring value of this challenge relies on the effectiveness of the stochastic methods used to model the uncertainty of vehicle fuel costs over time.

Given more time, I would first have attempted an extensive stochastic form, deployed to a high-mem machine, and if the sheer problem size made computation intractable I would have considered decomposition methods, starting with [Benders](https://en.wikipedia.org/wiki/Benders_decomposition).

### To all contestants, good luck!! ❤️