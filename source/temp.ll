; ModuleID = 'Lepix'

@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"

declare i32 @printf(i8*, ...)

define i32 @main() {
entry:
  %a = alloca i32
  store i32 4, i32* %a
  %a1 = load i32, i32* %a
  %tmp = icmp eq i32 %a1, 5
  br i1 %tmp, label %then, label %else

then:                                             ; preds = %entry
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt, i32 0, i32 0), i32 5)
  br label %ifcont

else:                                             ; preds = %entry
  %printf2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt, i32 0, i32 0), i32 4)
  br label %ifcont

ifcont:                                           ; preds = %else, %then
  ret i32 0
}

