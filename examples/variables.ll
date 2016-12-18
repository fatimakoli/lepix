; ModuleID = 'variables.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@main.c = private unnamed_addr constant [3 x i32] [i32 10, i32 20, i32 30], align 4
@main.d = private unnamed_addr constant [3 x [3 x i32]] [[3 x i32] [i32 1, i32 2, i32 3], [3 x i32] [i32 4, i32 5, i32 6], [3 x i32] [i32 7, i32 8, i32 9]], align 16

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %a = alloca i32, align 4
  %b = alloca i32, align 4
  %c = alloca [3 x i32], align 4
  %d = alloca [3 x [3 x i32]], align 16
  store i32 0, i32* %1, align 4
  store i32 49, i32* %a, align 4
  %2 = load i32, i32* %a, align 4
  %3 = srem i32 %2, 8
  store i32 %3, i32* %b, align 4
  %4 = load i32, i32* %a, align 4
  store i32 %4, i32* %b, align 4
  %5 = bitcast [3 x i32]* %c to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %5, i8* bitcast ([3 x i32]* @main.c to i8*), i64 12, i32 4, i1 false)
  %6 = getelementptr inbounds [3 x i32], [3 x i32]* %c, i64 0, i64 2
  %7 = load i32, i32* %6, align 4
  %8 = add nsw i32 %7, 10
  store i32 %8, i32* %a, align 4
  %9 = bitcast [3 x [3 x i32]]* %d to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %9, i8* bitcast ([3 x [3 x i32]]* @main.d to i8*), i64 36, i32 16, i1 false)
  %10 = getelementptr inbounds [3 x [3 x i32]], [3 x [3 x i32]]* %d, i64 0, i64 0
  %11 = getelementptr inbounds [3 x i32], [3 x i32]* %10, i64 0, i64 0
  %12 = load i32, i32* %11, align 16
  %13 = getelementptr inbounds [3 x [3 x i32]], [3 x [3 x i32]]* %d, i64 0, i64 1
  %14 = getelementptr inbounds [3 x i32], [3 x i32]* %13, i64 0, i64 1
  %15 = load i32, i32* %14, align 4
  %16 = add nsw i32 %12, %15
  store i32 %16, i32* %b, align 4
  %17 = load i32, i32* %b, align 4
  %18 = getelementptr inbounds [3 x i32], [3 x i32]* %c, i64 0, i64 2
  store i32 %17, i32* %18, align 4
  ret i32 0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i32, i1) #1

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.8.0-2ubuntu4 (tags/RELEASE_380/final)"}
