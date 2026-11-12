# scd-painsleep

## Demo of the Pediatric Sickle Cell Pain Model

The scd_demo.m code will find an initial condition via Latin hypercube sampling then estimate parameter to fit the simulated data using either fmincon or simulated annealing. The necessary auxillary files are in the util folder:
- eval_objective_at_params.m
- fit_patient_params_via_*.m
- pain_sim_core.m
- plot_model_r01_talk.m

This work was supported by the National Heart, Lung, and Blood Institute (K01HL103155), and the National Institutes of Health Helping to End Addiction Long-term (HEAL) Initiative, the National Institute of Dental and Craniofacial Research and the National Institute of Neurological Disorders and Stroke (R21DE032583).
