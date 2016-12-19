; ModuleID = 'Lepix'

@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt1 = private unnamed_addr constant [4 x i8] c"%f\0A\00"

declare i32 @printf(i8*, ...)

define i32 @main() {
entry:
  %a = alloca float
  %printf = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([4 x i8]* @fmt1, i32 0, i32 0), float 0.000000e+00)
  ret i32 0
}

