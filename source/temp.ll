; ModuleID = 'Lepix'

@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"

declare i32 @printf(i8*, ...)

define i32 @main() {
entry:
  %a = alloca [5 x i32]
  store [5 x i32] [i32 1, i32 2, i32 3, i32 4, i32 5], [5 x i32]* %a
  %tmp = getelementptr [5 x i32]* %a, i32 3
  %a1 = load i32* %tmp
  %printf = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([4 x i8]* @fmt, i32 0, i32 0), [5 x i32] %a1)
  ret i32 0
}

