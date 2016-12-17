; ModuleID = 'threaded-2d.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%union.pthread_mutex_t = type { %struct.__pthread_mutex_s }
%struct.__pthread_mutex_s = type { i32, i32, i32, i32, i32, i16, i16, %struct.__pthread_internal_list }
%struct.__pthread_internal_list = type { %struct.__pthread_internal_list*, %struct.__pthread_internal_list* }
%union.pthread_attr_t = type { i64, [48 x i8] }
%union.pthread_mutexattr_t = type { i32 }

@sum = global i32 0, align 4
@.str = private unnamed_addr constant [51 x i8] c"Thread %d summing arr[%d][%d] through arr[%d][%d]\0A\00", align 1
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
  %start = alloca i32, align 4
  %end = alloca i32, align 4
  %int_num = alloca i32*, align 8
  %local_sum = alloca i32, align 4
  store i8* %num, i8** %2, align 8
  store i32 0, i32* %local_sum, align 4
  %3 = load i8*, i8** %2, align 8
  %4 = bitcast i8* %3 to i32*
  store i32* %4, i32** %int_num, align 8
  %5 = load i32*, i32** %int_num, align 8
  %6 = load i32, i32* %5, align 4
  %7 = mul nsw i32 %6, 8
  %8 = sdiv i32 %7, 4
  store i32 %8, i32* %start, align 4
  %9 = load i32, i32* %start, align 4
  %10 = add nsw i32 %9, 2
  store i32 %10, i32* %end, align 4
  %11 = load i32*, i32** %int_num, align 8
  %12 = load i32, i32* %11, align 4
  %13 = load i32, i32* %start, align 4
  %14 = load i32, i32* %end, align 4
  %15 = sub nsw i32 %14, 1
  %16 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([51 x i8], [51 x i8]* @.str, i32 0, i32 0), i32 %12, i32 %13, i32 100, i32 %15, i32 100)
  %17 = load i32, i32* %start, align 4
  store i32 %17, i32* %i, align 4
  br label %18

; <label>:18                                      ; preds = %40, %0
  %19 = load i32, i32* %i, align 4
  %20 = load i32, i32* %end, align 4
  %21 = icmp slt i32 %19, %20
  br i1 %21, label %22, label %43

; <label>:22                                      ; preds = %18
  store i32 0, i32* %j, align 4
  br label %23

; <label>:23                                      ; preds = %36, %22
  %24 = load i32, i32* %j, align 4
  %25 = icmp slt i32 %24, 100
  br i1 %25, label %26, label %39

; <label>:26                                      ; preds = %23
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
  br label %23

; <label>:39                                      ; preds = %23
  br label %40

; <label>:40                                      ; preds = %39
  %41 = load i32, i32* %i, align 4
  %42 = add nsw i32 %41, 1
  store i32 %42, i32* %i, align 4
  br label %18

; <label>:43                                      ; preds = %18
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
  %attr = alloca %union.pthread_attr_t, align 8
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
  %31 = call i32 @pthread_attr_init(%union.pthread_attr_t* %attr) #4
  %32 = call i32 @pthread_attr_setdetachstate(%union.pthread_attr_t* %attr, i32 0) #4
  store i32 0, i32* %i, align 4
  br label %33

; <label>:33                                      ; preds = %49, %29
  %34 = load i32, i32* %i, align 4
  %35 = icmp slt i32 %34, 4
  br i1 %35, label %36, label %52

; <label>:36                                      ; preds = %33
  %37 = load i32, i32* %i, align 4
  %38 = load i32, i32* %i, align 4
  %39 = sext i32 %38 to i64
  %40 = getelementptr inbounds [4 x i32], [4 x i32]* %thread_nums, i64 0, i64 %39
  store i32 %37, i32* %40, align 4
  %41 = load i32, i32* %i, align 4
  %42 = sext i32 %41 to i64
  %43 = getelementptr inbounds [4 x i64], [4 x i64]* %threads, i64 0, i64 %42
  %44 = load i32, i32* %i, align 4
  %45 = sext i32 %44 to i64
  %46 = getelementptr inbounds [4 x i32], [4 x i32]* %thread_nums, i64 0, i64 %45
  %47 = bitcast i32* %46 to i8*
  %48 = call i32 @pthread_create(i64* %43, %union.pthread_attr_t* %attr, i8* (i8*)* @do_work, i8* %47) #4
  br label %49

; <label>:49                                      ; preds = %36
  %50 = load i32, i32* %i, align 4
  %51 = add nsw i32 %50, 1
  store i32 %51, i32* %i, align 4
  br label %33

; <label>:52                                      ; preds = %33
  store i32 0, i32* %i, align 4
  br label %53

; <label>:53                                      ; preds = %62, %52
  %54 = load i32, i32* %i, align 4
  %55 = icmp slt i32 %54, 4
  br i1 %55, label %56, label %65

; <label>:56                                      ; preds = %53
  %57 = load i32, i32* %i, align 4
  %58 = sext i32 %57 to i64
  %59 = getelementptr inbounds [4 x i64], [4 x i64]* %threads, i64 0, i64 %58
  %60 = load i64, i64* %59, align 8
  %61 = call i32 @pthread_join(i64 %60, i8** null)
  br label %62

; <label>:62                                      ; preds = %56
  %63 = load i32, i32* %i, align 4
  %64 = add nsw i32 %63, 1
  store i32 %64, i32* %i, align 4
  br label %53

; <label>:65                                      ; preds = %53
  %66 = load i32, i32* @sum, align 4
  %67 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str.1, i32 0, i32 0), i32 %66)
  store i32 0, i32* @sum, align 4
  store i32 0, i32* %i, align 4
  br label %68

; <label>:68                                      ; preds = %89, %65
  %69 = load i32, i32* %i, align 4
  %70 = icmp slt i32 %69, 8
  br i1 %70, label %71, label %92

; <label>:71                                      ; preds = %68
  store i32 0, i32* %j, align 4
  br label %72

; <label>:72                                      ; preds = %85, %71
  %73 = load i32, i32* %j, align 4
  %74 = icmp slt i32 %73, 100
  br i1 %74, label %75, label %88

; <label>:75                                      ; preds = %72
  %76 = load i32, i32* %j, align 4
  %77 = sext i32 %76 to i64
  %78 = load i32, i32* %i, align 4
  %79 = sext i32 %78 to i64
  %80 = getelementptr inbounds [8 x [100 x i32]], [8 x [100 x i32]]* @arr, i64 0, i64 %79
  %81 = getelementptr inbounds [100 x i32], [100 x i32]* %80, i64 0, i64 %77
  %82 = load i32, i32* %81, align 4
  %83 = load i32, i32* @sum, align 4
  %84 = add nsw i32 %83, %82
  store i32 %84, i32* @sum, align 4
  br label %85

; <label>:85                                      ; preds = %75
  %86 = load i32, i32* %j, align 4
  %87 = add nsw i32 %86, 1
  store i32 %87, i32* %j, align 4
  br label %72

; <label>:88                                      ; preds = %72
  br label %89

; <label>:89                                      ; preds = %88
  %90 = load i32, i32* %i, align 4
  %91 = add nsw i32 %90, 1
  store i32 %91, i32* %i, align 4
  br label %68

; <label>:92                                      ; preds = %68
  %93 = load i32, i32* @sum, align 4
  %94 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([21 x i8], [21 x i8]* @.str.2, i32 0, i32 0), i32 %93)
  %95 = call i32 @pthread_attr_destroy(%union.pthread_attr_t* %attr) #4
  %96 = call i32 @pthread_mutex_destroy(%union.pthread_mutex_t* @sum_mutex) #4
  call void @pthread_exit(i8* null) #5
  unreachable
                                                  ; No predecessors!
  %98 = load i32, i32* %1, align 4
  ret i32 %98
}

; Function Attrs: nounwind
declare i32 @pthread_mutex_init(%union.pthread_mutex_t*, %union.pthread_mutexattr_t*) #2

; Function Attrs: nounwind
declare i32 @pthread_attr_init(%union.pthread_attr_t*) #2

; Function Attrs: nounwind
declare i32 @pthread_attr_setdetachstate(%union.pthread_attr_t*, i32) #2

; Function Attrs: nounwind
declare i32 @pthread_create(i64*, %union.pthread_attr_t*, i8* (i8*)*, i8*) #2

declare i32 @pthread_join(i64, i8**) #1

; Function Attrs: nounwind
declare i32 @pthread_attr_destroy(%union.pthread_attr_t*) #2

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
