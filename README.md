# scd-painsleep

## Demo of the Pediatric Sickle Cell Pain Model

The scd_demo.m code will find an initial condition via Latin hypercube sampling then estimate parameter to fit the simulated data using either fmincon or simulated annealing. The necessary auxillary files are in the util folder:
- eval_objective_at_params.m
- fit_patient_params_via_*.m
- pain_sim_core.m
- plot_model_r01_talk.m
