' This program copies raw data from one EViews workfile, changes it 
' and stores it in a second workfile.  The first workfile is called
' bkdrw.wf1, while the second is called bkdo1.wf1.  The raw data is downloaded
' from IHS Markit (Global Insight) database (e.g., US) without alteration
' by running dld1.prg.  The changes introduced here include renaming series, changing
' units, and interpolating frequencies.

' NOTE: In November and December, if updating monthly BLS data,
'       one should first run edbls.prg or its latest version.

'                             ALSO

'      If after 2010, Employer tax rates need to be updated.

exec .\setup2

setmaxerrs (500)

wfopen bkl.wf1
wfopen bkdr1.wf1
wfopen bkdrw.wf1

wfopen bkdo1.wf1

wfselect work
pageselect vars

' download lists - wefa and ssa series names, respectively
copy bkl::vars\dl*wefa work::vars\dl*wefa
copy bkl::vars\dl*ssa  work::vars\dl*ssa

' Quarterly Series
%wefa_q = dl2wefa + " " + dl7wefa + " " + dl10wefa
%ssa_q = dl2ssa + " " + dl7ssa + " " + dl10ssa
%x = @winterleave(%wefa_q, %ssa_q)
for %x1 %x2 {%x}
   copy bkdrw::q\{%x1} bkdo1::q\{%x2}
next

' Monthly Series
%wefa_m = dl1wefa + " " + dl3wefa + " " + dl4wefa + " " + dl5wefa
%ssa_m = dl1ssa + " " + dl3ssa + " " + dl4ssa + " " + dl5ssa
%x = @winterleave(%wefa_m, %ssa_m)
for %x1 %x2 {%x}
   copy bkdrw::m\{%x1} bkdo1::m\{%x2}
next

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

' Changes the magnitude for some series
pageselect vars
%z = @wdrop(dl1ssa,"r* R*")
%z = %z + " " + @wkeep(dl3ssa,"e* E*")
%dl4ssa = dl4ssa
wfselect work
pageselect m
smpl 1901 2025
for %x {%z}
   genr temp = bkdo1.wf1::m\{%x} / 1000
   copy temp bkdo1::m\{%x}
   delete temp
next
for %x {%dl4ssa}
  genr temp = bkdo1.wf1::m\{%x} / 100
  copy temp bkdo1::m\{%x}
  delete temp
next

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

' This section corrects for errors in Global Insight (GI) Data over the period from 1990 to 1993.
' It appears that for some disaggregated series,  GI has correct values for LC and RU,  but not for E or U. 
pageselect m
smpl 1990M1 1992M12

series em2529_u
em2529_u.fill(o="1990M1") _
   9.093, 9.130, 9.100, 9.192, 9.299, 9.329, 9.189, 9.192, 9.168, 9.201, 9.115, 8.857,  _
   8.665, 8.656, 8.640, 8.760, 8.847, 8.857, 8.808, 8.781, 8.849, 8.746, 8.673, 8.622,  _
   8.411, 8.334, 8.340, 8.422, 8.516, 8.518, 8.565, 8.514, 8.483, 8.369, 8.347, 8.284,  _
   8.177, 8.179, 8.216, 8.319, 8.346, 8.395, 8.411, 8.304, 8.325, 8.310, 8.244, 8.257

series em3034_u
em3034_u.fill(o="1990m1") _
   9.557, 9.506, 9.615, 9.596, 9.615, 9.642, 9.654, 9.697, 9.685, 9.674, 9.630, 9.615, _
   9.425, 9.404, 9.371, 9.380, 9.510, 9.589, 9.584, 9.627, 9.626, 9.713, 9.585, 9.465, _
   9.345, 9.421, 9.479, 9.516, 9.572, 9.609, 9.540, 9.548, 9.651, 9.699, 9.553, 9.555, _
   9.431, 9.363, 9.522, 9.614, 9.658, 9.621, 9.616, 9.646, 9.654, 9.641, 9.639, 9.630

series em3539_u
em3539_u.fill(o="1990m1") _
   8.715, 8.807, 8.835, 8.868, 8.950, 8.927, 8.935, 8.903, 8.978, 8.982, 8.889, 8.889, _
   8.790, 8.758, 8.866, 8.880, 8.892, 8.900, 8.957, 8.986, 9.074, 9.027, 9.001, 9.006, _
   8.887, 8.873, 8.948, 8.989, 9.142, 9.137, 9.180, 9.179, 9.223, 9.176, 9.173, 9.117, _
   9.032, 9.102, 9.128, 9.244, 9.374, 9.382, 9.455, 9.458, 9.435, 9.457, 9.444, 9.401

series em4044_u
em4044_u.fill(o="1990m1") _
   7.648, 7.718, 7.739, 7.821, 7.879, 7.878, 7.851, 7.907, 7.968, 8.039, 8.095, 8.027, _
   7.987, 8.033, 8.015, 8.136, 8.184, 8.222, 8.242, 8.240, 8.255, 8.241, 8.263, 8.078, _
   7.974, 7.916, 8.032, 8.115, 8.148, 8.207, 8.233, 8.225, 8.204, 8.250, 8.217, 8.208, _
   8.138, 8.121, 8.223, 8.265, 8.361, 8.391, 8.374, 8.441, 8.472, 8.438, 8.473, 8.365

series em4549_u
em4549_u.fill(o="1990m1") _
   5.900, 5.935, 5.936, 5.916, 5.934, 5.997, 6.022, 6.072, 6.143, 6.156, 6.087, 6.037, _
   5.998, 5.986, 6.069, 6.093, 6.023, 6.037, 6.074, 6.080, 6.202, 6.301, 6.296, 6.369, _
   6.310, 6.269, 6.354, 6.388, 6.433, 6.480, 6.523, 6.609, 6.698, 6.751, 6.705, 6.680, _
   6.626, 6.628, 6.606, 6.672, 6.770, 6.775, 6.811, 6.834, 6.967, 7.007, 7.043, 7.006

series em5054_u
em5054_u.fill(o="1990m1") _
   4.610, 4.641, 4.651, 4.642, 4.728, 4.726, 4.713, 4.715, 4.704, 4.707, 4.644, 4.660, _
   4.587, 4.607, 4.629, 4.733, 4.708, 4.775, 4.721, 4.733, 4.752, 4.660, 4.649, 4.669, _
   4.616, 4.709, 4.760, 4.887, 4.853, 4.895, 4.878, 4.886, 4.908, 4.921, 4.899, 4.964, _
   4.876, 4.936, 4.925, 4.981, 5.070, 5.125, 5.162, 5.220, 5.200, 5.259, 5.292, 5.328

series em5559_u
em5559_u.fill(o="1990m1") _
   3.720, 3.722, 3.730, 3.716, 3.723, 3.755, 3.772, 3.817, 3.847, 3.835, 3.819, 3.838, _
   3.767, 3.693, 3.682, 3.702, 3.652, 3.669, 3.701, 3.667, 3.678, 3.721, 3.699, 3.680, _
   3.648, 3.658, 3.692, 3.756, 3.762, 3.692, 3.725, 3.718, 3.729, 3.674, 3.662, 3.678, _
   3.656, 3.741, 3.738, 3.779, 3.787, 3.826, 3.737, 3.755, 3.717, 3.712, 3.703, 3.701

series em6064_u
em6064_u.fill(o="1990m1") _
   2.546, 2.533, 2.534, 2.575, 2.609, 2.650, 2.630, 2.621, 2.634, 2.640, 2.632, 2.634, _
   2.481, 2.520, 2.545, 2.554, 2.583, 2.600, 2.559, 2.538, 2.613, 2.553, 2.558, 2.526, _
   2.494, 2.514, 2.504, 2.518, 2.536, 2.523, 2.489, 2.396, 2.409, 2.427, 2.429, 2.440, _
   2.416, 2.495, 2.499, 2.502, 2.473, 2.443, 2.343, 2.365, 2.365, 2.446, 2.392, 2.406

series em6569_u
em6569_u.fill(o="1990m1") _
   1.119, 1.136, 1.168, 1.134, 1.181, 1.141, 1.120, 1.093, 1.103, 1.068, 1.046, 1.045, _
   0.985, 1.025, 1.125, 1.164, 1.173, 1.123, 1.076, 1.032, 1.028, 1.022, 1.018, 0.972, _
   1.035, 1.073, 1.145, 1.115, 1.137, 1.096, 1.046, 1.060, 1.084, 1.121, 1.163, 1.121, _
   1.106, 1.059, 1.024, 1.029, 1.123, 1.063, 1.079, 1.081, 1.085, 1.151, 1.077, 1.093

series em7074_u
em7074_u.fill(o="1990m1") _
   0.476, 0.480, 0.506, 0.541, 0.494, 0.504, 0.496, 0.504, 0.529, 0.477, 0.487, 0.480, _
   0.482, 0.461, 0.467, 0.494, 0.454, 0.509, 0.484, 0.480, 0.517, 0.535, 0.517, 0.504, _
   0.490, 0.520, 0.541, 0.520, 0.509, 0.540, 0.511, 0.507, 0.554, 0.514, 0.545, 0.519, _
   0.522, 0.525, 0.522, 0.496, 0.521, 0.518, 0.528, 0.540, 0.565, 0.530, 0.548, 0.510

series em75o_u
em75o_u.fill(o="1990m1") _
   0.294, 0.276, 0.299, 0.279, 0.313, 0.310, 0.315, 0.305, 0.288, 0.299, 0.281, 0.317, _
   0.276, 0.308, 0.294, 0.308, 0.306, 0.329, 0.313, 0.309, 0.332, 0.294, 0.298, 0.307, _
   0.299, 0.319, 0.321, 0.336, 0.356, 0.338, 0.337, 0.345, 0.324, 0.284, 0.315, 0.277, _
   0.244, 0.292, 0.304, 0.300, 0.312, 0.351, 0.332, 0.309, 0.325, 0.306, 0.308, 0.314

series ef2529_u
ef2529_u.fill(o="1990m1") _
   7.612, 7.548, 7.597, 7.569, 7.553, 7.512, 7.363, 7.393, 7.355, 7.377, 7.353, 7.349, _
   7.174, 7.245, 7.278, 7.415, 7.277, 7.166, 7.122, 6.952, 6.961, 7.003, 7.074, 7.120, _
   7.040, 7.086, 7.030, 7.134, 7.146, 7.038, 6.925, 6.878, 6.911, 6.923, 6.977, 7.032, _
   6.857, 6.815, 6.814, 6.825, 6.864, 6.820, 6.778, 6.703, 6.710, 6.821, 6.892, 6.893

series ef3034_u
ef3034_u.fill(o="1990m1") _
   7.727, 7.715, 7.660, 7.691, 7.753, 7.659, 7.624, 7.589, 7.655, 7.712, 7.722, 7.776, _
   7.615, 7.656, 7.584, 7.639, 7.654, 7.596, 7.569, 7.607, 7.645, 7.761, 7.759, 7.678, _
   7.690, 7.684, 7.659, 7.698, 7.769, 7.658, 7.662, 7.627, 7.707, 7.723, 7.726, 7.693, _
   7.702, 7.733, 7.718, 7.649, 7.692, 7.596, 7.639, 7.665, 7.742, 7.779, 7.680, 7.709

series ef3539_u
ef3539_u.fill(o="1990m1") _
   7.229, 7.292, 7.279, 7.269, 7.406, 7.267, 7.248, 7.220, 7.327, 7.388, 7.360, 7.287, _
   7.230, 7.250, 7.373, 7.439, 7.439, 7.459, 7.391, 7.367, 7.558, 7.622, 7.615, 7.692, _
   7.579, 7.591, 7.595, 7.561, 7.605, 7.563, 7.532, 7.457, 7.562, 7.652, 7.634, 7.580, _
   7.573, 7.656, 7.722, 7.712, 7.774, 7.738, 7.751, 7.685, 7.814, 7.827, 7.863, 7.890

series ef4044_u
ef4044_u.fill(o="1990m1") _
   6.606, 6.672, 6.688, 6.728, 6.735, 6.617, 6.656, 6.682, 6.801, 6.962, 6.902, 6.933, _
   6.979, 7.077, 6.989, 7.039, 7.090, 7.029, 6.977, 6.967, 7.142, 7.165, 7.131, 7.064, _
   7.087, 7.086, 7.125, 7.116, 7.075, 7.015, 6.955, 6.992, 7.155, 7.263, 7.292, 7.247, _
   7.170, 7.191, 7.222, 7.194, 7.213, 7.203, 7.142, 7.223, 7.322, 7.356, 7.361, 7.420

series ef4549_u
ef4549_u.fill(o="1990m1") _
   5.030, 5.018, 5.065, 5.086, 5.116, 5.095, 5.035, 5.030, 5.167, 5.179, 5.232, 5.184, _
   5.175, 5.127, 5.144, 5.225, 5.205, 5.208, 5.217, 5.232, 5.275, 5.324, 5.356, 5.388, _
   5.449, 5.499, 5.495, 5.599, 5.650, 5.661, 5.621, 5.668, 5.697, 5.750, 5.800, 5.799, _
   5.748, 5.805, 5.858, 5.910, 5.919, 5.914, 5.812, 5.848, 5.947, 6.113, 6.198, 6.191

series ef5054_u
ef5054_u.fill(o="1990m1") _
   3.643, 3.645, 3.693, 3.740, 3.782, 3.760, 3.764, 3.720, 3.762, 3.780, 3.757, 3.743, _
   3.730, 3.778, 3.774, 3.767, 3.891, 3.840, 3.811, 3.808, 3.864, 3.923, 3.905, 3.866, _
   3.822, 3.856, 3.924, 3.992, 4.013, 4.035, 4.015, 4.038, 4.053, 4.124, 4.143, 4.182, _
   4.141, 4.198, 4.286, 4.213, 4.310, 4.211, 4.201, 4.278, 4.361, 4.436, 4.529, 4.550

series ef5559_u
ef5559_u.fill(o="1990m1") _
   2.868, 2.870, 2.889, 2.891, 2.872, 2.827, 2.832, 2.879, 2.919, 2.938, 2.917, 2.933, _
   2.868, 2.853, 2.865, 2.871, 2.841, 2.906, 2.923, 2.893, 2.960, 2.853, 2.874, 2.883, _
   2.867, 2.874, 2.918, 2.884, 2.896, 2.934, 2.943, 2.944, 2.983, 2.943, 2.960, 2.943, _
   2.934, 2.991, 2.987, 2.990, 2.962, 2.965, 2.906, 2.958, 3.012, 3.029, 3.099, 3.168

series ef6064_u
ef6064_u.fill(o="1990m1") _
   1.958, 1.928, 1.946, 1.897, 1.988, 1.913, 1.888, 1.890, 1.911, 1.925, 1.903, 1.951, _
   1.885, 1.820, 1.876, 1.864, 1.851, 1.847, 1.819, 1.827, 1.933, 1.969, 1.880, 1.904, _
   1.908, 1.878, 1.942, 1.915, 1.866, 1.903, 1.870, 1.839, 1.935, 1.933, 1.907, 1.915, _
   1.857, 1.887, 1.903, 1.893, 1.954, 1.951, 1.841, 1.893, 1.902, 1.875, 1.900, 1.842

series ef6569_u
ef6569_u.fill(o="1990m1") _
   0.828, 0.842, 0.910, 0.943, 0.926, 0.929, 0.873, 0.886, 0.939, 0.932, 0.909, 0.835, _
   0.848, 0.891, 0.923, 0.930, 0.887, 0.852, 0.850, 0.852, 0.909, 0.921, 0.915, 0.867, _
   0.842, 0.813, 0.842, 0.842, 0.803, 0.792, 0.781, 0.801, 0.817, 0.855, 0.892, 0.888, _
   0.802, 0.812, 0.826, 0.819, 0.801, 0.834, 0.823, 0.851, 0.839, 0.899, 0.890, 0.887

series ef7074_u
ef7074_u.fill(o="1990m1") _
   0.353, 0.349, 0.344, 0.366, 0.341, 0.359, 0.327, 0.328, 0.368, 0.353, 0.356, 0.384, _
   0.343, 0.342, 0.357, 0.356, 0.346, 0.367, 0.352, 0.337, 0.383, 0.352, 0.324, 0.343, _
   0.361, 0.341, 0.375, 0.387, 0.358, 0.382, 0.383, 0.351, 0.363, 0.350, 0.357, 0.337, _
   0.320, 0.343, 0.381, 0.373, 0.388, 0.377, 0.371, 0.365, 0.359, 0.347, 0.386, 0.357

series ef75o_u
ef75o_u.fill(o="1990m1") _
   0.170, 0.176, 0.185, 0.193, 0.190, 0.204, 0.183, 0.176, 0.211, 0.188, 0.197, 0.195, _
   0.182, 0.225, 0.230, 0.230, 0.204, 0.210, 0.192, 0.180, 0.196, 0.199, 0.188, 0.199, _
   0.191, 0.198, 0.220, 0.209, 0.195, 0.193, 0.189, 0.187, 0.224, 0.256, 0.201, 0.199, _
   0.190, 0.180, 0.169, 0.181, 0.191, 0.198, 0.220, 0.232, 0.242, 0.257, 0.233, 0.232

copy(m) e*_u bkdo1::m\e*_u ' option (m) to merge results with existing series
delete e*_u

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

' This section creates additional monthly series
pageselect m
smpl @all

genr u16o_u = bkdo1.wf1::m\l16o_u - bkdo1.wf1::m\e16o_u

for %s m f
   for %a 16o 1619 1617 1819 2024 2534 2529 3034 3544 3539 4044 4554 4549 5054 5564 5559 6064 65o 6569 7074 75o
      genr u{%s}{%a}_u = bkdo1.wf1::m\l{%s}{%a}_u - bkdo1.wf1::m\e{%s}{%a}_u
   next
next

copy(m) u*_u bkdo1::m\u*_u ' option (m) to merge results with existing series
delete u*_u

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

for %s m f
   for %x l e u
      genr {%x}{%s}55o_u = bkdo1.wf1::m\{%x}{%s}5559_u + bkdo1.wf1::m\{%x}{%s}6064_u + bkdo1.wf1::m\{%x}{%s}65o_u
   next
   genr r{%s}55o_u = u{%s}55o_u / l{%s}55o_u * 100
next

copy(m) *_u bkdo1::m\*_u ' option (m) to merge results with existing series
delete *_u

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

for %s "" m f ' first element is an empty string for overall total group 
   for %x lc e u ru ' set group totals for each series equal to 16o group total
      if (%x = "lc") then
         genr {%x}{%s} = bkdo1.wf1::m\l{%s}16o ' workaround for series l16o,lm16o,lf16o instead of lc16o,lcm16o,lcf16o
         genr {%x}{%s}_u = bkdo1.wf1::m\l{%s}16o_u
      else
         if (%x = "ru") then
            genr {%x}{%s} = bkdo1.wf1::m\r{%s}16o ' workaround for series r16o,rm16o,rf16o instead of ru16o,rum16o,ruf16o
            genr {%x}{%s}_u = bkdo1.wf1::m\r{%s}16o_u
         else
            genr {%x}{%s} = bkdo1.wf1::m\{%x}{%s}16o
            genr {%x}{%s}_u = bkdo1.wf1::m\{%x}{%s}16o_u
         endif
      endif
   next
next

for %s f m
   for %a 1617 1819
      genr l{%s}{%a} = bkdo1.wf1::m\e{%s}{%a} + bkdo1.wf1::m\u{%s}{%a}
   next
   for %a1 %a2 %a3 2529 3034 2534 3539 4044 3544 4549 5054 4554 ' break the 10-year age groups into 5-year age groups
      for %x l e u
        genr {%x}{%s}{%a1} = bkdo1.wf1::m\{%x}{%s}{%a1}_u * bkdo1.wf1::m\{%x}{%s}{%a3} / bkdo1.wf1::m\{%x}{%s}{%a3}_u
        genr {%x}{%s}{%a2} = bkdo1.wf1::m\{%x}{%s}{%a3} - {%x}{%s}{%a1}
      next
      genr r{%s}{%a1} = u{%s}{%a1} / l{%s}{%a1} * 100
      genr r{%s}{%a2} = u{%s}{%a2} / l{%s}{%a2} * 100
   next
next

' The computation for female and male age groups 55 and over is different

' Female age groups
for %a 55o 5564 65o 5559 6064 6569 7074 75o
   for %x l e u r
      genr {%x}f{%a} = bkdo1.wf1::m\{%x}f{%a}_u
   next
next

for %x l e u
   genr {%x}f70o = {%x}f7074 + {%x}f75o
next
genr rf70o = uf70o / lf70o * 100
genr nf70o = bkdo1.wf1::m\nf7074 + bkdo1.wf1::m\nf75o

' Male age groups
genr lm55o = bkdo1.wf1::m\em55o + bkdo1.wf1::m\um55o

genr lm5564 = bkdo1.wf1::m\lm5564_u * lm55o / (bkdo1.wf1::m\lm5564_u + bkdo1.wf1::m\lm65o_u)
genr em5564 = bkdo1.wf1::m\em5564_u * bkdo1.wf1::m\em55o / (bkdo1.wf1::m\em5564_u + bkdo1.wf1::m\em65o_u)
genr um5564 = bkdo1.wf1::m\um5564_u * bkdo1.wf1::m\um55o / (bkdo1.wf1::m\um5564_u + bkdo1.wf1::m\um65o_u)
genr rm5564 = um5564   / lm5564 * 100

genr lm65o  =  lm55o - lm5564
genr em65o  =  bkdo1.wf1::m\em55o - em5564
genr um65o  =  lm65o - em65o
genr rm65o  =  um65o / lm65o * 100

genr lm5559 = bkdo1.wf1::m\lm5559_u * lm55o / (bkdo1.wf1::m\lm5564_u + bkdo1.wf1::m\lm65o_u)
genr em5559 = bkdo1.wf1::m\em5559_u * bkdo1.wf1::m\em55o / (bkdo1.wf1::m\em5564_u + bkdo1.wf1::m\em65o_u)
genr um5559 = bkdo1.wf1::m\um5559_u * bkdo1.wf1::m\um55o / (bkdo1.wf1::m\um5564_u + bkdo1.wf1::m\um65o_u)
genr rm5559 = um5559   / lm5559 * 100

genr lm6064 = lm5564 - lm5559
genr em6064 = em5564 - em5559
genr um6064 = um5564 - um5559
genr rm6064 = um6064 /lm6064 * 100

genr lm6569 = bkdo1.wf1::m\lm6569_u * lm65o / bkdo1.wf1::m\lm65o_u
genr em6569 = bkdo1.wf1::m\em6569_u * em65o / bkdo1.wf1::m\em65o_u
genr um6569 = bkdo1.wf1::m\um6569_u * um65o / bkdo1.wf1::m\um65o_u
genr rm6569 = um6569   / lm6569 * 100

genr lm7074 = bkdo1.wf1::m\lm7074_u * lm65o / bkdo1.wf1::m\lm65o_u
genr em7074 = bkdo1.wf1::m\em7074_u * em65o / bkdo1.wf1::m\em65o_u
genr um7074 = bkdo1.wf1::m\um7074_u * um65o / bkdo1.wf1::m\um65o_u
genr rm7074 = um7074   / lm7074 * 100

genr lm75o = lm65o - (lm6569 + lm7074)
genr em75o = em65o - (em6569 + em7074)
genr um75o = um65o - (um6569 + um7074)
genr rm75o = um75o / lm75o * 100

for %x l e u
   genr {%x}m70o = {%x}m7074 + {%x}m75o
next
genr rm70o = um70o / lm70o * 100
genr nm70o = bkdo1.wf1::m\nm7074 + bkdo1.wf1::m\nm75o

' Note: Do not convert wsdp.m to a quarterly series
genr wsdp = bkdo1.wf1::m\wsd - bkdo1.wf1::m\wsdgge

genr egfc = bkdo1.wf1::m\eggefc - bkdo1.wf1::m\egefcps
genr nlcuw_u = bkdo1.wf1::m\nlcmuw_u + bkdo1.wf1::m\nlcfuw_u

genr em_est = bkdo1.wf1::m\e_est - bkdo1.wf1::m\ef_est
genr em_est_u = bkdo1.wf1::m\e_est_u - bkdo1.wf1::m\ef_est_u
genr emp_est = bkdo1.wf1::m\ep_est - bkdo1.wf1::m\efp_est
genr emp_est_u = bkdo1.wf1::m\ep_est_u - bkdo1.wf1::m\efp_est_u
genr epsup_est = bkdo1.wf1::m\ep_est - bkdo1.wf1::m\epprod_est
genr epsup_est_u = bkdo1.wf1::m\ep_est_u - bkdo1.wf1::m\epprod_est_u

' Note: 8/25/03 Following 4 series are estimated because data is no longer available
'              for 2000:1 forward due to NAICS revisions.
smpl 2000m1 2100m12
genr eau = bkdo1.wf1::m\ea - bkdo1.wf1::m\eaw - bkdo1.wf1::m\eas
genr enau = bkdo1.wf1::m\ena - bkdo1.wf1::m\enaw - bkdo1.wf1::m\enas
genr enawph = bkdo1.wf1::m\enaw - bkdo1.wf1::m\enawo - bkdo1.wf1::m\enawg

smpl @all

genr edmil_nus = bkdo1.wf1::m\n_t - bkdo1.wf1::m\n_r
genr edmil_us = bkdo1.wf1::m\edmil - edmil_nus

genr eggesl = bkdo1.wf1::m\egges + bkdo1.wf1::m\eggel
genr eggesl_u = bkdo1.wf1::m\egges_u + bkdo1.wf1::m\eggel_u

copy bkdo1::m\ephs_ss_est ephs_ss_est
genr ephs_est = ephs_ss_est - bkdo1.wf1::m\epss_est
delete ephs_ss_est

group g * not resid
%all = g.@members
delete g
for %x {%all}
  copy(m) {%x} bkdo1::m\{%x} ' option (m) to merge results with existing series
  delete {%x}
next

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

' This section converts monthly data to quarterly data

%l1 = "u16o_u " + _
   "um16o_u um1619_u um1617_u um1819_u um2024_u um2534_u um2529_u um3034_u um3544_u um3539_u um4044_u um4554_u " + _
   "um4549_u um5054_u um5564_u um5559_u um6064_u um65o_u um6569_u um7074_u um75o_u " + _
   "uf16o_u uf1619_u uf1617_u uf1819_u uf2024_u uf2534_u uf2529_u uf3034_u uf3544_u uf3539_u uf4044_u uf4554_u " + _
   "uf4549_u uf5054_u uf5564_u uf5559_u uf6064_u uf65o_u uf6569_u uf7074_u uf75o_u " + _
   "lm55o_u em55o_u um55o_u rm55o_u " + _
   "lf55o_u ef55o_u uf55o_u rf55o_u " + _
   "lcm lcf lc em ef e um ef u rum ruf ru "+ _
   "lcm_u lcf_u lc_u em_u ef_u e_u um_u ef_u u_u rum_u ruf_u ru_u " + _
   "lf1617 lf1819 " + _
   "lf2529 ef2529 uf2529 rf2529 " + _
   "lf3034 ef3034 uf3034 rf3034 " + _
   "lf3539 ef3539 uf3539 rf3539 " + _
   "lf4044 ef4044 uf4044 rf4044 " + _
   "lf4549 ef4549 uf4549 rf4549 " + _
   "lf5054 ef5054 uf5054 rf5054 " + _
   "lf55o ef55o uf55o rf55o " + _
   "lf5564 ef5564 uf5564 rf5564 " + _
   "lf65o ef65o uf65o rf65o " + _
   "lf5559 ef5559 uf5559 rf5559 " + _
   "lf6064 ef6064 uf6064 rf6064 " + _
   "lf6569 ef6569 uf6569 rf6569 " + _
   "lf7074 ef7074 uf7074 rf7074 " + _
   "lf75o ef75o uf75o rf75o lf70o ef70o uf70o rf70o nf70o " + _
   "lm1617 lm1819 " + _
   "lm2529 em2529 um2529 rm2529 " + _
   "lm3034 em3034 um3034 rm3034 " + _
   "lm3539 em3539 um3539 rm3539 " + _
   "lm4044 em4044 um4044 rm4044 " + _
   "lm4549 em4549 um4549 rm4549 " + _
   "lm5054 em5054 um5054 rm5054 " + _
   "lm55o " + _
   "lm5564 em5564 um5564 rm5564 " + _
   "lm65o em65o um65o rm65o " + _
   "lm5559 em5559 um5559 rm5559 " + _
   "lm6064 em6064 um6064 rm6064 " + _
   "lm6569 em6569 um6569 rm6569 " + _
   "lm7074 em7074 um7074 rm7074 " + _
   "lm75o em75o um75o rm75o lm70o em70o um70o rm70o nm70o " + _
   "egfc nlcuw_u " + _
   "em_est em_est_u emp_est emp_est_u epsup_est epsup_est_u " + _
   "eau enau enawph " + _
   "edmil_nus edmil_us " + _
   "eggesl eggesl_u ephs_est"

pageselect vars
%l1m = %l1 + " " + dl1ssa + " " + dl3ssa + " " + dl4ssa

pageselect m
smpl @all

for %x {%l1m}
   pageselect m
   copy bkdo1::m\{%x} {%x}
   pageselect q
   copy(c="an") m\{%x} q\{%x}
   copy(m) q\{%x} bkdo1::q\{%x}
   delete q\{%x} m\{%x}
next
for %x pgdp
   pageselect q
   copy bkdo1::q\{%x} {%x}
   {%x} = {%x} / 100
   copy {%x} bkdo1::q\{%x}
   delete {%x}
next

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

' This section calculates additional quarterly employment - related series

pageselect q
smpl @all

genr nm1619m = bkdr1.wf1::q\nm1617m + bkdr1.wf1::q\nm1819m
genr nm2534m = bkdr1.wf1::q\nm2529m + bkdr1.wf1::q\nm3034m
genr nm3544m = bkdr1.wf1::q\nm3539m + bkdr1.wf1::q\nm4044m
genr nm4554m = bkdr1.wf1::q\nm4549m + bkdr1.wf1::q\nm5054m
genr nm5564m = bkdr1.wf1::q\nm5559m
genr nm16om  = nm1619m + bkdr1.wf1::q\nm2024m + nm2534m + nm3544m + nm4554m + nm5564m

genr nf1619m = bkdr1.wf1::q\nf1617m + bkdr1.wf1::q\nf1819m
genr nf2534m = bkdr1.wf1::q\nf2529m + bkdr1.wf1::q\nf3034m
genr nf3544m = bkdr1.wf1::q\nf3539m + bkdr1.wf1::q\nf4044m
genr nf4554m = bkdr1.wf1::q\nf4549m + bkdr1.wf1::q\nf5054m
genr nf5564m = bkdr1.wf1::q\nf5559m
genr nf16om  = nf1619m + bkdr1.wf1::q\nf2024m + nf2534m + nf3544m + nf4554m + nf5564m

genr n16om   = nm16om  + nf16om

genr ep = bkdo1.wf1::q\e - bkdo1.wf1::q\eas - bkdo1.wf1::q\enas - bkdo1.wf1::q\eggefc - bkdo1.wf1::q\eggesl

copy n*m bkdo1::q\n*m
copy ep bkdo1::q\ep
delete n*m ep

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

' This section calculates annual and quarterly coast guard compensation (wssgfmcg), and other
' values used to estimate quarterly compensation-related data in the general government and 
' government enterprise sectors.

'  Annual values (Note: It is assumed that wssgfmcg (list r below) will grow
'                       at their average annual difference over the last five years.)

pageselect a
smpl @all

smpl 1970 1971
genr wssgfmcg = 0.4
smpl 1972 2100 
wssgfmcg = bkdrw.wf1::a\compdgfggmil - bkdrw.wf1::a\gfmlcwssml
smpl @all
copy bkdrw::a\compdgfggmil a\temp
%endcg = @otod(@ilast(temp))
%endcgp1 = @otod(@ilast(temp)+1)
%endcgp2 = @otod(@ilast(temp)+2)
delete temp
smpl {%endcgp1} {%endcgp2}
wssgfmcg = wssgfmcg(-1) + (wssgfmcg(-1) - wssgfmcg(-6)) / 5
smpl @all

' BKDO1 is temporarily demoted from primary at this point in the original command file
genr r_wsgfc  = bkdrw.wf1::a\wsadgfggciv / bkdrw.wf1::a\compdgfggciv
genr r_wsgfm  = bkdrw.wf1::a\wsadgfggmil / bkdrw.wf1::a\compdgfggmil
genr r_wsgsl  = bkdrw.wf1::a\wsadgslgg   / bkdrw.wf1::a\compdgslgg
genr r_wsgefc = bkdrw.wf1::a\wsadgfge    / bkdrw.wf1::a\compdgfge
genr r_wsgesl = bkdrw.wf1::a\wsadgslge   / bkdrw.wf1::a\compdgslge

genr rr_wsgefc =  bkdrw.wf1::a\wsadgfge / (bkdrw.wf1::a\wsadgfge + bkdrw.wf1::a\wsadgslge)
genr rr_cfcgefc = bkdrw.wf1::a\ckfgegf  / (bkdrw.wf1::a\ckfgegf  + bkdrw.wf1::a\ckfgegsl)

%r = "r_wsgfc r_wsgfm r_wsgsl r_wsgefc r_wsgesl rr_wsgefc rr_cfcgefc"

for %v {%r}
  smpl @all
  %endyr = @otod(@ilast({%v}))
  %endyrp1 = @otod(@ilast({%v})+1)
  %endyrp2 = @otod(@ilast({%v})+2)
  smpl {%endyrp1} {%endyrp2}
  {%v} = {%v}(-1) + ({%v}(-1) - {%v}(-6))/5
next
smpl @all

' Quarterly values   

'    NOTE: September 14, 2005
'          As a possible improvement to the section below, we could interpolate using a spline function (instead of 'repeat') and
'          control results to annual values (when available). This would "smooth" the intra-year pattern of quarterly values
'          of high values in the 1st qtr followed by falling values that are presently occurring in WSGEFC and WSGESL

pageselect q
for %v wssgfmcg {%r}
   copy(c="r") a\{%v} q\{%v}
   copy q\{%v} bkdo1::q\{%v}
next

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

' This section calculates additional quarterly earnings-related series

pageselect q
smpl @all

genr wssgfm   = bkdo1.wf1::q\wssgfmxcg + bkdo1.wf1::q\wssgfmcg
genr wssgfc   = bkdo1.wf1::q\wssgf - wssgfm

genr wsgfc    = r_wsgfc * wssgfc
genr wsgfm    = r_wsgfm * wssgfm
genr wsgsl    = r_wsgsl * bkdo1.wf1::q\wssgsl
genr wsgf     = wsgfc + wsgfm
genr wsg      = wsgf + wsgsl
genr wsge     = bkdo1.wf1::q\wsgge - wsg
genr wsgefc   = rr_wsgefc * wsge
genr wsgesl   = wsge - wsgefc
genr wsggefc  = wsgfc + wsgefc
genr wsggesl  = wsgsl + wsgesl
genr wsggef   = wsggefc + wsgfm

genr wssg     = bkdo1.wf1::q\wssgf + bkdo1.wf1::q\wssgsl
genr wssgefc  = wsgefc / r_wsgefc
genr wssgesl  = wsgesl / r_wsgesl
genr wssge    = wssgefc + wssgesl
genr wssgge   = wssg + wssge
genr wssggefc = wssgfc + wssgefc
genr wssggef  = wssggefc + wssgfm
genr wssggesl = bkdo1.wf1::q\wssgsl + wssgesl

genr cfcg     = bkdo1.wf1::q\cfcgf + bkdo1.wf1::q\cfcgsl
genr cfcgfc   = bkdo1.wf1::q\cfcgf - bkdo1.wf1::q\cfcgfm
genr cfcgefc  = rr_cfcgefc * bkdo1.wf1::q\cfcge
genr cfcgesl  = bkdo1.wf1::q\cfcge - cfcgefc
genr cfcgge   = cfcg + bkdo1.wf1::q\cfcge
genr cfcggef  = bkdo1.wf1::q\cfcgf + cfcgefc
genr cfcggefc = cfcgfc + cfcgefc
genr cfcggesl = bkdo1.wf1::q\cfcgsl + cfcgesl

genr gdpg     = wssg + cfcg
genr gdpgf    = bkdo1.wf1::q\wssgf+ bkdo1.wf1::q\cfcgf
genr gdpgfc   = wssgfc + cfcgfc
genr gdpgfm   = wssgfm + bkdo1.wf1::q\cfcgfm
genr gdpgsl   = bkdo1.wf1::q\wssgsl + bkdo1.wf1::q\cfcgsl
genr gdpge    = wssge + bkdo1.wf1::q\cfcge
genr gdpgefc  = wssgefc + cfcgefc
genr gdpgesl  = wssgesl + cfcgesl
genr gdpgge   = wssgge + cfcgge
genr gdpggef  = wssggef + cfcggef
genr gdpggefc = wssggefc + cfcggefc
genr gdpggesl = wssggesl + cfcggesl

%gge = "wsgfc wsgfm wsgf wsgsl wsg wsgefc wsgesl wsge wsggefc wsgfm wsggef wsggesl wsgge " + _
   "wssgfc wssgfm wssgf wssgsl wssg wssgefc wssgesl wssge wssggefc wssgfm wssggef wssggesl wssgge " + _
   "cfcgfc cfcgfm cfcgf cfcgsl cfcg cfcgefc cfcgesl cfcge cfcggefc cfcgfm cfcggef cfcggesl cfcgge " + _
   "gdpgfc gdpgfm gdpgf gdpgsl gdpg gdpgefc gdpgesl gdpge gdpggefc gdpgfm gdpggef gdpggesl gdpgge"

genr wsdp = bkdo1.wf1::q\wsd - bkdo1.wf1::q\wsdgge
genr wssp = bkdo1.wf1::q\wss - wssgge


genr y = bkdo1.wf1::q\yf + bkdo1.wf1::q\ynf
genr yx = bkdo1.wf1::q\yfx + bkdo1.wf1::q\ynfx

genr socoli_fm = wssgfm - wsgfm

genr cfcp = bkdo1.wf1::q\ccallp - bkdo1.wf1::q\ccadjp

genr gdppb = bkdo1.wf1::q\gdp - gdpgf - gdpgsl - bkdo1.wf1::q\gdpph - bkdo1.wf1::q\gdppni
genr gdppbnf = gdppb - bkdo1.wf1::q\gdppf
genr gdppbnfxge = gdppbnf - (wssgefc + wssgesl + cfcgefc + cfcgesl)

genr gdpbxge = bkdo1.wf1::q\gdp - (gdpgge + bkdo1.wf1::q\gdpph + bkdo1.wf1::q\gdppni)
genr gdp_oth = gdpbxge - bkdo1.wf1::q\gdp_corp
genr wsspbxge = bkdo1.wf1::q\wss - (wssgge + bkdo1.wf1::q\wssph + bkdo1.wf1::q\wsspni)
genr wss_oth = wsspbxge - bkdo1.wf1::q\wss_corp

' Next section estimates quarterly values for wsspf. Quarterly values for a particular CY are set equal to the annual value
' for that year. For quarters beyond the latest annual value, the quarterly value is set to the latest annual value.

pageselect a
smpl @all
copy bkdrw::a\compdpnrm11frm a\temp
%per1 = @otod(@ilast(temp))
%per1p1 = @otod(@ilast(temp)+1)
copy(c="r") a\temp q\wsspf
delete temp
pageselect q
smpl @all
copy bkdo1::q\yf q\temp
%per2 = @otod(@ilast(temp))
delete temp
smpl {%per1p1} {%per2}
wsspf = @elem(wsspf,%per1)
smpl @all

genr wsspb = bkdo1.wf1::q\wss - bkdo1.wf1::q\wssgf - bkdo1.wf1::q\wssgsl - bkdo1.wf1::q\wssph - bkdo1.wf1::q\wsspni
genr wsspbnf = wsspb - wsspf
genr wsspbnfxge = wsspbnf - wssgefc - wssgesl
genr rwsspbnfxge =  wsspbnfxge / (gdppbnfxge - bkdo1.wf1::q\ynf)
genr awsggefc = wsggefc / bkdo1.wf1::q\eggefc
genr awsgfc = wsgfc / (bkdo1.wf1::q\eggefc - bkdo1.wf1::q\egefcps)
genr awsgefc = wsgefc / bkdo1.wf1::q\egefcps
genr awsggesl = wsggesl / bkdo1.wf1::q\eggesl
genr awsgfm = wsgfm / (bkdo1.wf1::q\edmil + bkdr1.wf1::q\edmil_r)
genr awsp = bkdo1.wf1::q\wsp / (bkdo1.wf1::q\e - bkdo1.wf1::q\eggefc - bkdo1.wf1::q\eggesl - bkdo1.wf1::q\eas - bkdo1.wf1::q\enas)

genr s1 = @movav(bkdr1.wf1::q\craz1,4)
genr s2 = (awsp(-1) / awsp(-5))^.25 - 1
series craz2
call min(craz2,s1,s2)
delete s1 s2
genr rtp = bkdo1.wf1::q\gdp17 / bkdr1.wf1::q\kgdp17
'copy bkdrw::q\rtp q\rtp

genr gdpp = bkdo1.wf1::q\gdp - gdpgge
genr rwssqp = wssp / gdpp
genr rcwssl = wssggesl / wsggesl
genr rcwsf = wssggefc / wsggefc
genr rcwsm = wssgfm / wsgfm
genr rcwsp = wssp / bkdo1.wf1::q\wsp
genr pgdpi = bkdo1.wf1::q\gdp / bkdo1.wf1::q\gdp17
genr pgdpaf = bkdo1.wf1::q\gdppf / bkdo1.wf1::q\gdppf17
genr prod = bkdo1.wf1::q\gdp17 / bkdr1.wf1::q\tothrs
genr ahrs = bkdr1.wf1::q\tothrs * 1000   /  ((bkdo1.wf1::q\e  +  bkdo1.wf1::q\edmil) * 52)

group g * not resid
%all = g.@members
delete g
for %x {%all}
  copy(m) {%x} bkdo1::q\{%x} ' option (m) to merge results with existing series
  delete {%x}
next
copy a\wssgfmcg bkdo1::a\wssgfmcg
delete a\*

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

' This section converts quarterly data to annual data

%l2 = "rm5564 rm65o rf5564 rf65o " + _
   "nm1619m nm2534m nm3544m nm4554m nm5564m nm16om " + _
   "nf1619m nf2534m nf3544m nf4554m nf5564m nf16om " + _
   "eau enau enawph enawph_u ep " + _
   "wsdp wssp cfcp gdpp awsp " + _
   "awsggefc awsgfc awsgefc awsggesl awsgfm " + _
   "rwssqp rcwssl rcwsf rcwsm rcwsp " + _
   "pgdpi pgdpaf " + _
   "gdppb gdppbnf wsspb wsspbnf rwsspbnfxge"

pageselect vars
%l1q = %l2 + " " + %l1m + " " + dl7ssa
%s = %l1q + " " + dl2ssa
for %x {%s}
   pageselect q
   smpl @all
   copy bkdo1::q\{%x} {%x}
   copy(c="an") {%x} a\{%x}
   if (@lower(%x) <> "wsgge") then
     copy(m) a\{%x} bkdo1::a\{%x} ' option (m) to merge results with existing series
   endif
   delete {%x} a\{%x}
next

' This section copies and renames annual series

pageselect vars
%x = @winterleave(dl8wefa, dl8ssa)
for %x1 %x2 {%x}
   if (@lower(%x2) <> "wsgge") then
      copy bkdrw::a\{%x1} bkdo1::a\{%x2}
   endif
next

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

'   - this section is necessary to temporarily include variables that are now obsolete due to 
'     the NAICS revision

%dl8wefa_x = "AWA80 AWA82 AWA83 AWB80 AWB82 AWB83 AEMFTE80 AEMFTE82 AEMFTE83"
%dl8ssa_x  = "WSPHS_SIC WSPES_SIC WSPSS_SIC WSSPHS_SIC WSSPES_SIC WSSPSS_SIC EPHS_SIC EPES_SIC EPSS_SIC"

%x = @winterleave(%dl8wefa_x,%dl8ssa_x)
for %x1 %x2 {%x}
   copy bkdrw::a\{%x1} bkdo1::a\{%x2}
next

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

pageselect a
smpl @all

genr epes_sic = bkdo1.wf1::a\epes_sic / 1000
genr ephs_sic = bkdo1.wf1::a\ephs_sic / 1000
genr epss_sic = bkdo1.wf1::a\epss_sic / 1000

genr egf_fte = bkdo1.wf1::a\egf_fte / 1000
egf_fte.setattr(remarks) "emp Fed. govt. only, full-time equiv."

genr egfc_fte = bkdo1.wf1::a\egfc_fte / 1000
egfc_fte.setattr(remarks) "emp Fed. govt. only,civilian, full-time equiv."

genr egfm_fte = bkdo1.wf1::a\egfm_fte / 1000
egfm_fte.setattr(remarks) "emp Fed. govt. only,military, full-time equiv."

genr egsl_fte = bkdo1.wf1::a\egsl_fte / 1000
egsl_fte.setattr(remarks) "emp S&L govt. only, full-time equiv."

genr eg_fte = egf_fte + egsl_fte
eg_fte.setattr(remarks) "emp govt. only, full-time equiv."

copy(o) a\e* bkdo1::a\e*
delete a\e*

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

pageselect vars
%x = @winterleave(dl9wefa,dl9ssa)
pageselect a
smpl @all
for %x1 %x2 {%x}
  genr {%x2} = bkdrw.wf1::a\{%x1} / 1000
  copy(m) a\{%x2} bkdo1::a\{%x2}
  delete {%x2}
next

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

%x100 = "PGDP PGDP_C PGDP_CD PGDP_CN PGDP_CS PGDP_EX PGDP_EXG PGDP_EXS " + _
   "PGDP_G PGDP_GF PGDP_GFC PGDP_GFM PGDP_GSL PGDP_I PGDP_IF PGDP_IFN PGDP_IFNCS " + _
   "PGDP_IFNP PGDP_IFNPC PGDP_IFNS PGDP_IFR PGDP_IM PGDP_IMG PGDP_IMS"

pageselect a
smpl @all
for %x1 {%x100}
  genr {%x1} = bkdo1.wf1::a\{%x1} / 100
  copy a\{%x1} bkdo1::a\{%x1}
  delete a\{%x1}
next

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

' This section calculates additional Annual dataseries
' Note: Values below entered 5/1/09 from BLS

pageselect a
smpl 1967 1980

series nm7074
nm7074.fill(o="1967") 2.226, 2.151, 2.140, 2.154, 2.181, 2.277, 2.313, 2.334, 2.370, 2.426, 2.525, 2.611, 2.698, 2.803 

series nf7074
nf7074.fill(o="1967") 2.927, 2.863, 2.879, 2.913, 2.961, 3.169, 3.241, 3.203, 3.254, 3.331, 3.464, 3.595, 3.731, 3.867

genr nm75o = bkdo1.wf1::a\nm70o - nm7074
genr nf75o = bkdo1.wf1::a\nf70o - nf7074

smpl @all
copy(m) a\n* bkdo1::a\n*
delete a\n*

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

pageselect a
smpl @all

genr wsgf = bkdo1.wf1::a\wsgfc + bkdo1.wf1::a\wsgfm
genr wsg  = wsgf + bkdo1.wf1::a\wsgsl
genr wsge = bkdo1.wf1::a\wsgefc + bkdo1.wf1::a\wsgesl
smpl 1948 2100
genr wsgge  = wsg + wsge
smpl @all
genr wsggef = wsgf + bkdo1.wf1::a\wsgefc
genr wsggefc = bkdo1.wf1::a\wsgfc + bkdo1.wf1::a\wsgefc
genr wsggesl = bkdo1.wf1::a\wsgsl + bkdo1.wf1::a\wsgesl
'smpl 1948 2100 ' Workaround for issue with years 1929-1947 getting overwritten
genr wsssgf = bkdo1::wssgfc + bkdo1::wssgfm
'smpl @all
genr wssg = bkdo1.wf1::a\wssgf + bkdo1.wf1::a\wssgsl
genr wssge  = bkdo1.wf1::a\wssgefc + bkdo1.wf1::a\wssgesl
genr wssgge = wssg + wssge
genr wssggef = bkdo1.wf1::a\wssgf + bkdo1.wf1::a\wssgefc
genr wssggefc = bkdo1.wf1::a\wssgfc + bkdo1.wf1::a\wssgefc
genr wssggesl = bkdo1.wf1::a\wssgsl + bkdo1.wf1::a\wssgesl
genr cfcg = bkdo1.wf1::a\cfcgf + bkdo1.wf1::a\cfcgsl
genr cfcgfc = bkdo1.wf1::a\cfcgf - bkdo1.wf1::a\cfcgfm
genr cfcge  = bkdo1.wf1::a\cfcgefc + bkdo1.wf1::a\cfcgesl
genr cfcgge = cfcg + cfcge
genr cfcggef = bkdo1.wf1::a\cfcgf + bkdo1.wf1::a\cfcgefc
genr cfcggefc = cfcgfc + bkdo1.wf1::a\cfcgefc
genr cfcggesl = bkdo1.wf1::a\cfcgsl + bkdo1.wf1::a\cfcgesl
genr gdpgfc = bkdo1.wf1::a\wssgfc + cfcgfc
genr gdpgfm = bkdo1.wf1::a\wssgfm + bkdo1.wf1::a\cfcgfm
genr gdpge  = wssge + cfcge
genr gdpgefc = bkdo1.wf1::a\wssgefc + bkdo1.wf1::a\cfcgefc
genr gdpgesl = bkdo1.wf1::a\wssgesl + bkdo1.wf1::a\cfcgesl
genr gdpgge = bkdo1.wf1::a\gdpg + gdpge
genr gdpggef = bkdo1.wf1::a\gdpgf + gdpgefc
genr gdpggefc = gdpgfc + gdpgefc
genr gdpggesl = bkdo1.wf1::a\gdpgsl + gdpgesl

pageselect a
smpl @all
group g * not resid
%all = g.@members
delete g
for %x {%all}
  copy(m) {%x} bkdo1::a\{%x} ' option (m) to merge results with existing series
  delete {%x}
next

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

' Next section appends annual data with (if available) the annual averages of quarterly data 
pageselect q
smpl @all
copy bkdo1::q\wsgfc q\wsgfc
copy(c="an") wsgfc a\wsgfc_ann
delete wsgfc
pageselect a
smpl @all
copy bkdo1::a\wsgfc a\wsgfc
!a2 = @ilast(wsgfc)
!a1 = @ilast(wsgfc_ann)
copy wsgfc_ann bkdo1::a\wsgfc_ann
delete wsgfc_ann wsgfc
if (!a1 > !a2) then
   %per1 = @otod(!a2 + 1)
   %per2 = @otod(!a1)
   smpl {%per1} {%per2}
   pageselect q
   %per1 = @otod(4 * (!a2 + 1))
   %per2 = @otod(4 * !a1 + 3)
   smpl {%per1} {%per2}
   for %v {%gge}
      pageselect q
      genr {%v} = bkdo1.wf1::q\{%v}
      pageselect a
      copy(c="an") q\{%v} a\{%v}
      copy(m) {%v} bkdo1::a\{%v}
      delete {%v} q\{%v}
   next
endif

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

pageselect a
smpl @all

genr y = bkdo1.wf1::a\yf + bkdo1.wf1::a\ynf
genr yx = bkdo1.wf1::a\yfx + bkdo1.wf1::a\ynfx

genr rtp = bkdo1.wf1::a\gdp17 / bkdr1.wf1::a\kgdp17
' copy bkdrw::a\rtp a\rtp

genr awsph = bkdo1.wf1::a\wsph / bkdo1.wf1::a\enawph
genr awsprr = bkdo1.wf1::a\wsprr / bkdo1.wf1::a\eprr
genr awspf = bkdo1.wf1::a\wspf / bkdo1.wf1::a\eaw

genr gdppbnf = bkdo1.wf1::a\gdp - (bkdo1.wf1::a\gdpg + bkdo1.wf1::a\gdppni + bkdo1.wf1::a\gdpph + bkdo1.wf1::a\gdppf)
genr wsspbnf = bkdo1.wf1::a\wss - (bkdo1.wf1::a\wssg + bkdo1.wf1::a\wsspni + bkdo1.wf1::a\wssph + bkdo1.wf1::a\wsspf)
genr gdppbnfxge = bkdo1.wf1::a\gdp - (bkdo1.wf1::a\gdpgge + bkdo1.wf1::a\gdppni + bkdo1.wf1::a\gdpph + bkdo1.wf1::a\gdppf)
genr wsspbnfxge = bkdo1.wf1::a\wss - (bkdo1.wf1::a\wssgge + bkdo1.wf1::a\wsspni + bkdo1.wf1::a\wssph + bkdo1.wf1::a\wsspf)
genr rwsspbnfxge  =  wsspbnfxge   / (gdppbnfxge - bkdo1.wf1::a\ynf)

genr gdpbxge = bkdo1.wf1::a\gdp - (bkdo1.wf1::a\gdpgge + bkdo1.wf1::a\gdpph + bkdo1.wf1::a\gdppni)
genr gdp_oth = gdpbxge - bkdo1.wf1::a\gdp_corp
smpl 2008 2100
genr wsspbxge = bkdo1.wf1::a\wss - (bkdo1.wf1::a\wssgge + bkdo1.wf1::a\wssph + bkdo1.wf1::a\wsspni)
genr wss_oth = wsspbxge - bkdo1.wf1::a\wss_corp
smpl @all

' Following genr are BEA NAICS-based data
genr epes = bkdo1.wf1::a\epes /1000
copy bkdo1::a\ephs_ss ephs_ss
ephs_ss = ephs_ss / 1000
genr epss = bkdo1.wf1::a\epss / 1000

copy bkdo1::a\wssphs_ss wssphs_ss
genr wssphs = wssphs_ss - bkdo1.wf1::a\wsspss
copy bkdo1::a\wsphs_ss wsphs_ss
genr wsphs = wsphs_ss - bkdo1.wf1::a\wspss
genr ephs = ephs_ss - epss

genr awssphs = wssphs / ephs
genr awsspes = bkdo1.wf1::a\wsspes / epes
genr awsspss = bkdo1.wf1::a\wsspss / epss

genr awsphs = wsphs / ephs
genr awspes = bkdo1.wf1::a\wspes / epes
genr awspss = bkdo1.wf1::a\wspss / epss

' Following genr are BEA SIC-based data

genr awssphs_sic = bkdo1.wf1::a\wssphs_sic / bkdo1.wf1::a\ephs_sic
genr awsspes_sic = bkdo1.wf1::a\wsspes_sic / bkdo1.wf1::a\epes_sic
genr awsspss_sic = bkdo1.wf1::a\wsspss_sic / bkdo1.wf1::a\epss_sic

genr awsphs_sic = bkdo1.wf1::a\wsphs_sic / bkdo1.wf1::a\ephs_sic
genr awspes_sic = bkdo1.wf1::a\wspes_sic / bkdo1.wf1::a\epes_sic
genr awspss_sic = bkdo1.wf1::a\wspss_sic / bkdo1.wf1::a\epss_sic

' Following genr are BLS CES NAICS-based data

genr awssphs_est = wssphs / bkdo1.wf1::a\ephs_est
genr awsspes_est = bkdo1.wf1::a\wsspes / bkdo1.wf1::a\epes_est
genr awsspss_est = bkdo1.wf1::a\wsspss / bkdo1.wf1::a\epss_est

genr awsphs_est = wsphs / bkdo1.wf1::a\ephs_est
genr awspes_est = bkdo1.wf1::a\wspes / bkdo1.wf1::a\epes_est
genr awspss_est = bkdo1.wf1::a\wspss / bkdo1.wf1::a\epss_est

' The following series estimated using proxy weight 

series enawpbxge

smpl 1947 1989
enawpbxge = bkdo1.wf1::a\enaw - (bkdo1.wf1::a\enawph + bkdo1.wf1::a\eggefc + bkdo1.wf1::a\eggesl + (bkdo1.wf1::a\ephs_sic + bkdo1.wf1::a\epes_sic + bkdo1.wf1::a\epss_sic) * bkdo1.wf1::a\wsspni / (bkdo1.wf1::a\wssphs_sic + bkdo1.wf1::a\wsspes_sic + bkdo1.wf1::a\wsspss_sic))

smpl 1990 2000
enawpbxge = bkdo1.wf1::a\enaw - (bkdo1.wf1::a\enawph + bkdo1.wf1::a\eggefc + bkdo1.wf1::a\eggesl + (bkdo1.wf1::a\ephs_est + bkdo1.wf1::a\epes_est + bkdo1.wf1::a\epss_est) * bkdo1.wf1::a\wsspni / (bkdo1.wf1::a\wssphs_sic + bkdo1.wf1::a\wsspes_sic + bkdo1.wf1::a\wsspss_sic))

smpl 2001 2100
enawpbxge = bkdo1.wf1::a\enaw - (bkdo1.wf1::a\enawph + bkdo1.wf1::a\eggefc + bkdo1.wf1::a\eggesl + (bkdo1.wf1::a\ephs_est + bkdo1.wf1::a\epes_est + bkdo1.wf1::a\epss_est) * bkdo1.wf1::a\wsspni / (wssphs + bkdo1.wf1::a\wsspes + bkdo1.wf1::a\wsspss))

smpl @all
genr awssnawpbxge = wsspbnfxge / enawpbxge


' The following section calculates a quarterly enawpbxge

series rwsspni

smpl 1947 2000
rwsspni = bkdo1.wf1::a\wsspni / (bkdo1.wf1::a\wssphs_sic + bkdo1.wf1::a\wsspes_sic + bkdo1.wf1::a\wsspss_sic)

smpl 2001 2100
rwsspni = bkdo1.wf1::a\wsspni / (wssphs + bkdo1.wf1::a\wsspes + bkdo1.wf1::a\wsspss)

smpl @all
%ly_rwsspni = @otod(@ilast(rwsspni))
%ly_rwsspnip1 = @otod(@ilast(rwsspni)+1)
%ly_rwsspnip2 = @otod(@ilast(rwsspni)+2) ' Extending by 2 years (8 quarters)

pageselect q
smpl @all
copy(c="r") a\rwsspni q\rwsspni

smpl {%ly_rwsspnip1} {%ly_rwsspnip2}
rwsspni = rwsspni(-1)

series enawpbxge

smpl 1990 2000
enawpbxge = bkdo1.wf1::q\enaw - (bkdo1.wf1::q\enawph + bkdo1.wf1::q\eggefc + bkdo1.wf1::q\eggesl + (bkdo1.wf1::q\ephs_est + bkdo1.wf1::q\epes_est + bkdo1.wf1::q\epss_est) * rwsspni)

smpl 2001 2100
enawpbxge = bkdo1.wf1::q\enaw - (bkdo1.wf1::q\enawph + bkdo1.wf1::q\eggefc + bkdo1.wf1::q\eggesl + (bkdo1.wf1::q\ephs_est + bkdo1.wf1::q\epes_est + bkdo1.wf1::q\epss_est) * rwsspni)

smpl @all
genr awssnawpbxge = bkdo1.wf1::q\wsspbnfxge / enawpbxge

for %f q a
   pageselect {%f}
   group g * not resid
   %all = g.@members
   delete g
   for %x {%all}
     copy(m) {%x} bkdo1::{%f}\{%x} ' option (m) to merge results with existing series
     delete {%x}
   next
next

wfselect bkdo1
wfsave(2) bkdo1
wfselect work

pageselect a
smpl @all

genr oli_gge = bkdo1.wf1::a\oli - bkdo1.wf1::a\oli_p
genr soc_gge = bkdo1.wf1::a\soc - bkdo1.wf1::a\soc_p

genr socoli_sl = bkdo1.wf1::a\wssggesl - bkdo1.wf1::a\wsggesl
genr socoli_fc = bkdo1.wf1::a\wssggefc - bkdo1.wf1::a\wsggefc
genr socoli_fm = bkdo1.wf1::a\wssgfm - bkdo1.wf1::a\wsgfm

genr soc_fm = socoli_fm - bkdo1.wf1::a\oli_retfm
genr socf_uifm = soc_fm - (bkdr1.wf1::a\oasdifm_l + bkdr1.wf1::a\hifm_l + bkdo1.wf1::a\socf_mifm + bkdo1.wf1::a\socf_livet)

genr socf_uifc = bkdo1.wf1::a\socf_uifed - socf_uifm
genr soc_fc = bkdr1.wf1::a\oasdifc_l + bkdr1.wf1::a\hifc_l + socf_uifc + bkdo1.wf1::a\socf_wc

genr soc_sl = soc_gge - soc_fm - soc_fc
genr soc_wcsl = bkdo1.wf1::a\socsl_wc * bkdo1.wf1::a\wsggesl / (bkdo1.wf1::a\wsggesl + bkdo1.wf1::a\wsp)
genr soc_uisl = soc_sl - bkdr1.wf1::a\oasdisl_l - bkdr1.wf1::a\hisl_l - soc_wcsl

genr oli_fc = socoli_fc - soc_fc
genr oli_ghli_fc = oli_fc - bkdo1.wf1::a\oli_retfc

' Note: 8/17/04
' Next section disaggregate oli_ghli_fc to oli_ghi_fc and oli_gli_fc using model equation
' for oli_li_fc. This is necessary because model requires lagged starting value for oli_ghi_fc
genr oli_gli_fc = 2.0 * bkdo1.wf1::a\eggefc * ((bkdo1.wf1::a\wsggefc / bkdo1.wf1::a\eggefc) + 2.0) * .075 * 26 / 1000
genr oli_ghi_fc = oli_ghli_fc - oli_gli_fc

' Note: 1/09/06
' We extended following series through 2100 using 0 values in order to solve ModSol2. It is important to note, however, that 
' this series is irrelevant since the ratio of wsd / wss is given in Budget and TR projections.

smpl 1979 2080
genr olif_retfco = bkdr1.wf1::a\olif_csrs2 + bkdr1.wf1::a\olif_csrs3 + bkdr1.wf1::a\olif_csrs4 + bkdr1.wf1::a\olif_csrs5 + bkdr1.wf1::a\olif_fers2

smpl 2081 2100
olif_retfco = 0

smpl 1986 2079
genr oli_fersfc = bkdo1.wf1::a\oli_retfc - bkdr1.wf1::a\olif_csrs - bkdr1.wf1::a\olif_fers
oli_fersfc.setattr(remarks) "This series has upward bias because oli_retfc is CY while olif_csrs and olif_fers are FY"
                
smpl 1901 1985				
oli_fersfc = 0

smpl @all
genr oli_sl = socoli_sl - soc_sl
genr oli_wcsl = bkdo1.wf1::a\oli_wc * bkdo1.wf1::a\wsggesl / (bkdo1.wf1::a\wsggesl + bkdo1.wf1::a\wsp)
genr oli_ghli_sl = oli_sl - oli_wcsl - bkdo1.wf1::a\oli_retsl

' Note: 9/1/04
' Next section disaggregate oli_ghli_sl to oli_ghi_sl and oli_gli_sl using model equation
' for oli_li_sl. This is necessary because model requires lagged starting value for oli_ghi_sl
genr oli_gli_sl  =  2.0 * bkdo1.wf1::a\eggesl * ((bkdo1.wf1::a\wsggesl / bkdo1.wf1::a\eggesl) + 2.0) * .075 * 26 / 1000
genr oli_ghi_sl  =  oli_ghli_sl - oli_gli_sl

genr ruiws1 = bkdo1.wf1::a\socf_uis / (bkdo1.wf1::a\wsp - bkdo1.wf1::a\wsprr + bkdo1.wf1::a\wsggesl)
genr ruiws2 = bkdo1.wf1::a\socf_uif / (bkdo1.wf1::a\wsp - bkdo1.wf1::a\wsprr + bkdo1.wf1::a\wsggesl)
genr ruiws = ruiws1 + ruiws2
genr rwcws = (bkdo1.wf1::a\socsl_wc + bkdo1.wf1::a\oli_wc)/(bkdo1.wf1::a\wsp + bkdo1.wf1::a\wsggesl)
genr rsocsl_wc = bkdo1.wf1::a\socsl_wc / (bkdo1.wf1::a\socsl_wc + bkdo1.wf1::a\oli_wc)

genr soc_wcp = bkdo1.wf1::a\socsl_wc - soc_wcsl
genr soc_uip = bkdo1.wf1::a\socf_uis + bkdo1.wf1::a\socf_uif - soc_uisl
genr oli_wcp = bkdo1.wf1::a\oli_wc - oli_wcsl

genr oli_ppps = bkdo1.wf1::a\oli_pps - bkdo1.wf1::a\oli_retfc - bkdo1.wf1::a\oli_retfm - bkdo1.wf1::a\oli_retsl
genr oli_ghi_p = bkdo1.wf1::a\oli_ghi - oli_ghi_fc - oli_ghi_sl
genr oli_gli_p = bkdo1.wf1::a\oli_gli - oli_gli_fc - oli_gli_sl

genr roli_ppps = oli_ppps / bkdo1.wf1::a\wsp
genr rolipr = (bkdo1.wf1::a\oli_p - oli_ppps) / bkdo1.wf1::a\wsp

genr txrp = bkdr1.wf1::a\oasdip_tw / bkdo1.wf1::a\wspc
genr prod = bkdo1.wf1::a\gdp17 / bkdr1.wf1::a\tothrs
genr ahrs = bkdr1.wf1::a\tothrs * 1000  / ((bkdo1.wf1::a\e + bkdo1.wf1::a\edmil) * 52) 

pageselect q
smpl @all
copy(c="r") a\txrp q\txrp

for %f q a
   pageselect {%f}
   group g * not resid
   %all = g.@members
   delete g
   for %x {%all}
     copy(m) {%x} bkdo1::{%f}\{%x} ' option (m) to merge results with existing series
     delete {%x}
   next
next

pageselect vars
delete *

wfselect bkdo1
wfsave(2) bkdo1
wfclose bkdo1

wfclose bkl
wfclose bkdr1
wfclose bkdrw

' EViews appears not to have this functionality built in
subroutine min(series smin, series s1, series s2)
   ' Assign the minimum of each observation of the two series values series smin
   smin = (s1 <= s2) * s1 + (s1 > s2) * s2
endsub


