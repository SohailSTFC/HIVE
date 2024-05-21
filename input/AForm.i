!include Parameters.i

[Mesh]
  type = FileMesh
  file = ../mesh/vac_oval_coil_solid_target_coarse.e
  second_order = true
[]

[Variables]
  [A]
    family = NEDELEC_ONE
    order = FIRST
  []
[]

[AuxVariables]
  [V]
    family = LAGRANGE
    order = FIRST
  []
  [P]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[Kernels]
  [curlcurlA_coil_target]
    type = CurlCurlField
    variable = A
    coeff = ${copper_reluctivity}
    block = 'coil target'
  []
  [curlcurlA_vacuum]
    type = CurlCurlField
    variable = A
    coeff = ${vacuum_reluctivity}
    block = vacuum_region
  []
  [dAdt_target]
    type = CoefVectorTimeDerivative
    variable = A
    coeff = ${copper_econductivity}
    block = target
  []
  [dAdt_coil_vacuum]
    type = CoefVectorTimeDerivative
    variable = A
    coeff = ${vacuum_econductivity}
    block = 'coil vacuum_region'
  []
  [gradV]
    type = CoupledGrad
    variable = A
    coupled_scalar_variable = V
    function = ${copper_econductivity}*${voltage_amplitude}*sin(${voltage_wfrequency}*t)
    block = coil
  []
[]

[AuxKernels]
  [P]
    type = JouleHeatingAux
    variable = P
    vector_potential = A
    sigma = ${copper_econductivity}
    block = target
    execute_on = timestep_end
  []
[]

[BCs]
  [plane]
    type = VectorCurlPenaltyDirichletBC
    variable = A
    boundary = 'coil_in coil_out terminal_plane'
    penalty = 1e14
  []
[]

[Executioner]
  type = Transient
  solve_type = LINEAR
petsc_options_iname = '-pc_type -pc_asm_overlap -sub_pc_type  -ksp_type -ksp_max_it ksp_gmres_modifiedgramschmidt'
petsc_options_value = 'asm 2 ilu gmres 100 "" '
  num_steps = 1
[]

[MultiApps]
  [VLaplace]
    type = FullSolveMultiApp
    input_files = VLaplace.i
    execute_on = initial
  []
[]

[Transfers]
  [pull_potential]
    type = MultiAppCopyTransfer
    from_multi_app = VLaplace
    source_variable = V
    variable = V
  []
[]
