# The Collinear Mecanum Drive
## About
This is a large portion of the code developed during my research into the Collinear Mecanum Drive (CMD), a novel omnidirectional  dynamically stable mobile robot locomotion technology. The codebase has been tested in Matlab R2019b. I am not actively supporting this codebase, but will be happy to assist with queries from other students/researchers. To see the CMD prototype developed during my PhD in action please visit https://www.youtube.com/watch?v=EG2pka4Bczg.

## Quick usage:
- Set Matlab working directory to the top CMD directory, and add all subfolders to path.
- Run Differential_Flatness/polynomialTestingScript.m. This requires installations of nestedSortStruct, SeDuMi, matlab2Tikz. Can optionally use MOSEK to enable some more exotic polynomial optimisation methods.
- This should take around 30 minutes to run, and will first derive the CMD model, then output polynomial and state trajectories for a time-optimal path through the corners of a square.
- Open simulation.slx, open the 3dworld, and press run. You should see the robot doing a piroutte!
- Alternative controllers can be explored by changing the controller variant subsystem, and alternative approaches to the polynomial coefficient and segment duration optimisation can be explored in polynomialTestingScript.m.


## Code Organisation:
The code is largely split between three tasks - model derivation, controller derivation & planning, and closed-loop simulation.

Model derivation is performed by model_derivation.m, and can be switched between three and four-wheeled configurations. This function symbolically derives the full rigid body model of the CMD for the flat ground case, outputting a plethora of model data and analysis outputs in a single output structure. Derivation is performed first in the full generalised coordinates q, before reduction to a minimal set of coordinates p, and then transformation to global frame position coordinates p and local frame velocities v. These three models are grouped as structure members qdq (meaning a state vector formed by concatenating q and \dot{q}), pdp, and pv. This function also derives feedback linearisation functions, and performs analyses such as proving controllability and determining underactuation properties. The inverse kinematic mappings in various coordinate systems are also produced. The model is parameterised by the function substituteParameters; these substituions are the parameters for the experimental prototype I developed.

The folder 'Differential_Flatness' contains code specific to the derivaton of the CMD's differentially flat model, and various approaches to real-time polynomial optimisaton for velocity and acceleration constrained robots. The differentially flat model is derived by generateDifferentialFlatnessFunctions, which will output the functions necessary for mapping polynomial trajectories to dynamically feasible state trajectories. Generic polynomial optimisation is contained within the folder 'TrajectoryOptimisation'. A trajectory through n waypoints is defined by an instance of the trajectory class. This contains functions for performing coupled optimisations of trajectory parameters such as waypoint-to-waypoint durations. Each trajectory class contains three instances of the flatOutput class, which contains functions for the decoupled optimisation of polynomials in individual generalised coordinates. A handy script fit_polynomials_to_trajectory can be used to fit smoothly connected polynomials to a sampled shape, allowing the generation of state trajectories to track a predefined shape such as a logo.

The folder 'MPC' contains work from my T-MECH paper on a model predictive controller for the CMD, undertaken in 2017. This has not been worked on in a number of years, and so is provided as-is for sake of posterity. I would recommend using a differential flatness based approach instead.

Simulation is performed using the simulink simulation.slx. This simulates the full CMD model, and visualises the output using a simple 3D world block. A variant subsystem is used to switch between different controller implementations. Use 'simple LQR' for differential flatness based approaches. Feedback linearisation controllers currently use fixed setpoints, and so do not use the provided state and input trajectories.



## Citing this Work:
If using work from the model derivation or feedback linearisation sections please cite: 
> M. T. Watson, D. T. Gladwin and T. J. Prescott, "Collinear Mecanum Drive: Modeling, Analysis, Partial Feedback Linearization, and Nonlinear Control," in IEEE Transactions on Robotics, doi: 10.1109/TRO.2020.2977878.

If using work from the differential flatness based planner, please cite:
> M. T. Watson, D. T. Gladwin, T. J. Prescott and S. O. Conran, "Velocity Constrained Trajectory Generation for a Collinear Mecanum Wheeled Robot," 2019 International Conference on Robotics and Automation (ICRA), Montreal, QC, Canada, 2019, pp. 4444-4450, doi: 10.1109/ICRA.2019.8794019.

If using work from the MPC controller please cite:
> M. T. Watson, D. T. Gladwin, T. J. Prescott and S. O. Conran, "Dual-Mode Model Predictive Control of an Omnidirectional Wheeled Inverted Pendulum," in IEEE/ASME Transactions on Mechatronics, vol. 24, no. 6, pp. 2964-2975, Dec. 2019, doi: 10.1109/TMECH.2019.2943708.

