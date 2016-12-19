; ModuleID = 'array_3d.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@main.x = private unnamed_addr constant [2 x [5 x [2 x i32]]] [[5 x [2 x i32]] [[2 x i32] [i32 1, i32 11], [2 x i32] [i32 2, i32 22], [2 x i32] [i32 3, i32 33], [2 x i32] [i32 4, i32 44], [2 x i32] [i32 5, i32 55]], [5 x [2 x i32]] [[2 x i32] [i32 6, i32 66], [2 x i32] [i32 7, i32 77], [2 x i32] [i32 8, i32 88], [2 x i32] [i32 9, i32 99], [2 x i32] [i32 11, i32 111]]], align 16

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %x = alloca [2 x [5 x [2 x i32]]], align 16
  store i32 0, i32* %1, align 4
  %2 = bitcast [2 x [5 x [2 x i32]]]* %x to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %2, i8* bitcast ([2 x [5 x [2 x i32]]]* @main.x to i8*), i64 80, i32 16, i1 false)
  %3 = getelementptr inbounds [2 x [5 x [2 x i32]]], [2 x [5 x [2 x i32]]]* %x, i64 0, i64 0
  %4 = getelementptr inbounds [5 x [2 x i32]], [5 x [2 x i32]]* %3, i64 0, i64 0
  %5 = getelementptr inbounds [2 x i32], [2 x i32]* %4, i64 0, i64 0
  store i32 7, i32* %5, align 16
  ret i32 0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i32, i1) #1

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.8.0-2ubuntu4 (tags/RELEASE_380/final)"}
