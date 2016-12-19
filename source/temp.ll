; ModuleID = 'Lepix'

@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00"

declare i32 @printf(i8*, ...)

define i32 @main() {
entry:
  %x = alloca i32
  store i32 5, i32* %x
  %x1 = load i32* %x
  %tmp = icmp sge i32 %x1, 5
  br i1 %tmp, label %then, label %else

then:                                             ; preds = %entry
  %printf = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([4 x i8]* @fmt, i32 0, i32 0), i32 42)
  br label %ifcont

else:                                             ; preds = %entry
  %printf2 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([4 x i8]* @fmt, i32 0, i32 0), i32 17)
  br label %ifcont

ifcont:                                           ; preds = %else, %then
  ret i32 0
}

