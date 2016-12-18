; ModuleID = 'Lepix'

@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"

declare i32 @printf(i8*, ...)

define i32 @main() {
entry:
  %a = alloca i32
  store i32 4, i32* %a
  store i32 3, i32* %a
  br label %cond

loop:                                             ; preds = %cond
  %printf = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([4 x i8]* @fmt, i32 0, i32 0), i32 42)
  br label %inc

inc:                                              ; preds = %loop
  %a1 = load i32* %a
  %tmp = add i32 %a1, 1
  store i32 %tmp, i32* %a
  br label %cond

cond:                                             ; preds = %inc, %entry
  %a2 = load i32* %a
  %tmp3 = icmp slt i32 %a2, 5
  br i1 %tmp3, label %loop, label %afterloop

afterloop:                                        ; preds = %cond
  ret i32 0
}

