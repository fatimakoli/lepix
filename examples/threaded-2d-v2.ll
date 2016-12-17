; ModuleID = 'threaded-2d-v2.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%union.pthread_mutex_t = type { %struct.__pthread_mutex_s }
%struct.__pthread_mutex_s = type { i32, i32, i32, i32, i32, i16, i16, %struct.__pthread_internal_list }
%struct.__pthread_internal_list = type { %struct.__pthread_internal_list*, %struct.__pthread_internal_list* }
%union.pthread_mutexattr_t = type { i32 }
%union.pthread_attr_t = type { i64, [48 x i8] }

@sum = global i32 0, align 4
@.str = private unnamed_addr constant [71 x i8] c"Thread %d summing columns [%d] through [%d] from indices [%d] to [%d]\0A\00", align 1
@arr = common global [8 x [100 x i32]] zeroinitializer, align 16
@sum_mutex = common global %union.pthread_mutex_t zeroinitializer, align 8
@.str.1 = private unnamed_addr constant [25 x i8] c"Threaded array sum = %d\0A\00", align 1
@.str.2 = private unnamed_addr constant [21 x i8] c"Loop array sum = %d\0A\00", align 1

; Function Attrs: nounwind uwtable
define i8* @do_work(i8* %num) #0 {
  %1 = alloca i8*, align 8
  %2 = alloca i8*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %cols_start = alloca i32, align 4
  %cols_end = alloca i32, align 4
  %int_num = alloca i32*, align 8
  %local_sum = alloca i32, align 4
  store i8* %num, i8** %2, align 8
  store i32 0, i32* %local_sum, align 4
  %3 = load i8*, i8** %2, align 8
  %4 = bitcast i8* %3 to i32*
  store i32* %4, i32** %int_num, align 8
  %5 = load i32*, i32** %int_num, align 8
  %6 = load i32, i32* %5, align 4
  %7 = mul nsw i32 %6, 100
  %8 = sdiv i32 %7, 4
  store i32 %8, i32* %cols_start, align 4
  %9 = load i32, i32* %cols_start, align 4
  %10 = add nsw i32 %9, 25
  store i32 %10, i32* %cols_end, align 4
  %11 = load i32*, i32** %int_num, align 8
  %12 = load i32, i32* %11, align 4
  %13 = load i32, i32* %cols_start, align 4
  %14 = load i32, i32* %cols_end, align 4
  %15 = sub nsw i32 %14, 1
  %16 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([71 x i8], [71 x i8]* @.str, i32 0, i32 0), i32 %12, i32 0, i32 7, i32 %13, i32 %15)
  store i32 0, i32* %i, align 4
  br label %17

; <label>:17                                      ; preds = %40, %0
  %18 = load i32, i32* %i, align 4
  %19 = icmp slt i32 %18, 8
  br i1 %19, label %20, label %43

; <label>:20                                      ; preds = %17
  %21 = load i32, i32* %cols_start, align 4
  store i32 %21, i32* %j, align 4
  br label %22

; <label>:22                                      ; preds = %36, %20
  %23 = load i32, i32* %j, align 4
  %24 = load i32, i32* %cols_end, align 4
  %25 = icmp slt i32 %23, %24
  br i1 %25, label %26, label %39

; <label>:26                                      ; preds = %22
  %27 = load i32, i32* %j, align 4
  %28 = sext i32 %27 to i64
  %29 = load i32, i32* %i, align 4
  %30 = sext i32 %29 to i64
  %31 = getelementptr inbounds [8 x [100 x i32]], [8 x [100 x i32]]* @arr, i64 0, i64 %30
  %32 = getelementptr inbounds [100 x i32], [100 x i32]* %31, i64 0, i64 %28
  %33 = load i32, i32* %32, align 4
  %34 = load i32, i32* %local_sum, align 4
  %35 = add nsw i32 %34, %33
  store i32 %35, i32* %local_sum, align 4
  br label %36

; <label>:36                                      ; preds = %26
  %37 = load i32, i32* %j, align 4
  %38 = add nsw i32 %37, 1
  store i32 %38, i32* %j, align 4
  br label %22

; <label>:39                                      ; preds = %22
  br label %40

; <label>:40                                      ; preds = %39
  %41 = load i32, i32* %i, align 4
  %42 = add nsw i32 %41, 1
  store i32 %42, i32* %i, align 4
  br label %17

; <label>:43                                      ; preds = %17
  %44 = call i32 @pthread_mutex_lock(%union.pthread_mutex_t* @sum_mutex) #4
  %45 = load i32, i32* @sum, align 4
  %46 = load i32, i32* %local_sum, align 4
  %47 = add nsw i32 %45, %46
  store i32 %47, i32* @sum, align 4
  %48 = call i32 @pthread_mutex_unlock(%union.pthread_mutex_t* @sum_mutex) #4
  call void @pthread_exit(i8* null) #5
  unreachable
                                                  ; No predecessors!
  %50 = load i8*, i8** %1, align 8
  ret i8* %50
}

declare i32 @printf(i8*, ...) #1

; Function Attrs: nounwind
declare i32 @pthread_mutex_lock(%union.pthread_mutex_t*) #2

; Function Attrs: nounwind
declare i32 @pthread_mutex_unlock(%union.pthread_mutex_t*) #2

; Function Attrs: noreturn
declare void @pthread_exit(i8*) #3

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i8**, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %start = alloca i32, align 4
  %thread_nums = alloca [4 x i32], align 16
  %threads = alloca [4 x i64], align 16
  store i32 0, i32* %1, align 4
  store i32 %argc, i32* %2, align 4
  store i8** %argv, i8*** %3, align 8
  store i32 0, i32* %i, align 4
  br label %4

; <label>:4                                       ; preds = %26, %0
  %5 = load i32, i32* %i, align 4
  %6 = icmp slt i32 %5, 8
  br i1 %6, label %7, label %29

; <label>:7                                       ; preds = %4
  store i32 0, i32* %j, align 4
  br label %8

; <label>:8                                       ; preds = %22, %7
  %9 = load i32, i32* %j, align 4
  %10 = icmp slt i32 %9, 100
  br i1 %10, label %11, label %25

; <label>:11                                      ; preds = %8
  %12 = load i32, i32* %i, align 4
  %13 = mul nsw i32 %12, 100
  %14 = load i32, i32* %j, align 4
  %15 = add nsw i32 %13, %14
  %16 = load i32, i32* %j, align 4
  %17 = sext i32 %16 to i64
  %18 = load i32, i32* %i, align 4
  %19 = sext i32 %18 to i64
  %20 = getelementptr inbounds [8 x [100 x i32]], [8 x [100 x i32]]* @arr, i64 0, i64 %19
  %21 = getelementptr inbounds [100 x i32], [100 x i32]* %20, i64 0, i64 %17
  store i32 %15, i32* %21, align 4
  br label %22

; <label>:22                                      ; preds = %11
  %23 = load i32, i32* %j, align 4
  %24 = add nsw i32 %23, 1
  store i32 %24, i32* %j, align 4
  br label %8

; <label>:25                                      ; preds = %8
  br label %26

; <label>:26                                      ; preds = %25
  %27 = load i32, i32* %i, align 4
  %28 = add nsw i32 %27, 1
  store i32 %28, i32* %i, align 4
  br label %4

; <label>:29                                      ; preds = %4
  %30 = call i32 @pthread_mutex_init(%union.pthread_mutex_t* @sum_mutex, %union.pthread_mutexattr_t* null) #4
  store i32 0, i32* %i, align 4
  br label %31

; <label>:31                                      ; preds = %47, %29
  %32 = load i32, i32* %i, align 4
  %33 = icmp slt i32 %32, 4
  br i1 %33, label %34, label %50

; <label>:34                                      ; preds = %31
  %35 = load i32, i32* %i, align 4
  %36 = load i32, i32* %i, align 4
  %37 = sext i32 %36 to i64
  %38 = getelementptr inbounds [4 x i32], [4 x i32]* %thread_nums, i64 0, i64 %37
  store i32 %35, i32* %38, align 4
  %39 = load i32, i32* %i, align 4
  %40 = sext i32 %39 to i64
  %41 = getelementptr inbounds [4 x i64], [4 x i64]* %threads, i64 0, i64 %40
  %42 = load i32, i32* %i, align 4
  %43 = sext i32 %42 to i64
  %44 = getelementptr inbounds [4 x i32], [4 x i32]* %thread_nums, i64 0, i64 %43
  %45 = bitcast i32* %44 to i8*
  %46 = call i32 @pthread_create(i64* %41, %union.pthread_attr_t* null, i8* (i8*)* @do_work, i8* %45) #4
  br label %47

; <label>:47                                      ; preds = %34
  %48 = load i32, i32* %i, align 4
  %49 = add nsw i32 %48, 1
  store i32 %49, i32* %i, align 4
  br label %31

; <label>:50                                      ; preds = %31
  store i32 0, i32* %i, align 4
  br label %51

; <label>:51                                      ; preds = %60, %50
  %52 = load i32, i32* %i, align 4
  %53 = icmp slt i32 %52, 4
  br i1 %53, label %54, label %63

; <label>:54                                      ; preds = %51
  %55 = load i32, i32* %i, align 4
  %56 = sext i32 %55 to i64
  %57 = getelementptr inbounds [4 x i64], [4 x i64]* %threads, i64 0, i64 %56
  %58 = load i64, i64* %57, align 8
  %59 = call i32 @pthread_join(i64 %58, i8** null)
  br label %60

; <label>:60                                      ; preds = %54
  %61 = load i32, i32* %i, align 4
  %62 = add nsw i32 %61, 1
  store i32 %62, i32* %i, align 4
  br label %51

; <label>:63                                      ; preds = %51
  %64 = load i32, i32* @sum, align 4
  %65 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str.1, i32 0, i32 0), i32 %64)
  store i32 0, i32* @sum, align 4
  store i32 0, i32* %i, align 4
  br label %66

; <label>:66                                      ; preds = %87, %63
  %67 = load i32, i32* %i, align 4
  %68 = icmp slt i32 %67, 8
  br i1 %68, label %69, label %90

; <label>:69                                      ; preds = %66
  store i32 0, i32* %j, align 4
  br label %70

; <label>:70                                      ; preds = %83, %69
  %71 = load i32, i32* %j, align 4
  %72 = icmp slt i32 %71, 100
  br i1 %72, label %73, label %86

; <label>:73                                      ; preds = %70
  %74 = load i32, i32* %j, align 4
  %75 = sext i32 %74 to i64
  %76 = load i32, i32* %i, align 4
  %77 = sext i32 %76 to i64
  %78 = getelementptr inbounds [8 x [100 x i32]], [8 x [100 x i32]]* @arr, i64 0, i64 %77
  %79 = getelementptr inbounds [100 x i32], [100 x i32]* %78, i64 0, i64 %75
  %80 = load i32, i32* %79, align 4
  %81 = load i32, i32* @sum, align 4
  %82 = add nsw i32 %81, %80
  store i32 %82, i32* @sum, align 4
  br label %83

; <label>:83                                      ; preds = %73
  %84 = load i32, i32* %j, align 4
  %85 = add nsw i32 %84, 1
  store i32 %85, i32* %j, align 4
  br label %70

; <label>:86                                      ; preds = %70
  br label %87

; <label>:87                                      ; preds = %86
  %88 = load i32, i32* %i, align 4
  %89 = add nsw i32 %88, 1
  store i32 %89, i32* %i, align 4
  br label %66

; <label>:90                                      ; preds = %66
  %91 = load i32, i32* @sum, align 4
  %92 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([21 x i8], [21 x i8]* @.str.2, i32 0, i32 0), i32 %91)
  %93 = call i32 @pthread_mutex_destroy(%union.pthread_mutex_t* @sum_mutex) #4
  call void @pthread_exit(i8* null) #5
  unreachable
                                                  ; No predecessors!
  %95 = load i32, i32* %1, align 4
  ret i32 %95
}

; Function Attrs: nounwind
declare i32 @pthread_mutex_init(%union.pthread_mutex_t*, %union.pthread_mutexattr_t*) #2

; Function Attrs: nounwind
declare i32 @pthread_create(i64*, %union.pthread_attr_t*, i8* (i8*)*, i8*) #2

declare i32 @pthread_join(i64, i8**) #1

; Function Attrs: nounwind
declare i32 @pthread_mutex_destroy(%union.pthread_mutex_t*) #2

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noreturn "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }
attributes #5 = { noreturn }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.8.0-2ubuntu4 (tags/RELEASE_380/final)"}
