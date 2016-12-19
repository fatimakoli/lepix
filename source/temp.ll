; ModuleID = 'Lepix'

@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"

declare i32 @printf(i8*, ...)

define i32 @main() {
entry:
  %a = alloca float
  %b = alloca float
  store float 5.000000e+00, float* %a
  %a1 = load float* %a
  %tmp = fsub float %a1, 4.000000e+00
  store float %tmp, float* %b
  ret i32 0
}

