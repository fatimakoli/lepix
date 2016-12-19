; ModuleID = 'Lepix'

@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"

declare i32 @printf(i8*, ...)

define i32 @main() {
entry:
  %x = alloca [5 x i32]
  store [5 x i32] [i32 11, i32 22, i32 44, i32 66, i32 88], [5 x i32]* %x
  %tmp = getelementptr [5 x i32], [5 x i32]* %x, i32 0, i32 3
  %x1 = load i32, i32* %tmp
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt, i32 0, i32 0), i32 %x1)
  ret i32 0
}

