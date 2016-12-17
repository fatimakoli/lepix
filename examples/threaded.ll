; ModuleID = 'threaded.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%union.pthread_mutex_t = type { %struct.__pthread_mutex_s }
%struct.__pthread_mutex_s = type { i32, i32, i32, i32, i32, i16, i16, %struct.__pthread_internal_list }
%struct.__pthread_internal_list = type { %struct.__pthread_internal_list*, %struct.__pthread_internal_list* }
%union.pthread_mutexattr_t = type { i32 }
%union.pthread_attr_t = type { i64, [48 x i8] }

@sum = global i32 0, align 4
@.str = private unnamed_addr constant [37 x i8] c"Thread %d doing iterations %d to %d\0A\00", align 1
@arr = common global [100 x i32] zeroinitializer, align 16
@sum_mutex = common global %union.pthread_mutex_t zeroinitializer, align 8
@.str.1 = private unnamed_addr constant [25 x i8] c"Threaded array sum = %d\0A\00", align 1
@.str.2 = private unnamed_addr constant [21 x i8] c"Loop array sum = %d\0A\00", align 1

; Function Attrs: nounwind uwtable
define i8* @do_work(i8* %num) #0 {
  %1 = alloca i8*, align 8
  %2 = alloca i8*, align 8
  %i = alloca i32, align 4
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
  %7 = mul nsw i32 %6, 100
  %8 = sdiv i32 %7, 4
  store i32 %8, i32* %start, align 4
  %9 = load i32, i32* %start, align 4
  %10 = add nsw i32 %9, 25
  store i32 %10, i32* %end, align 4
  %11 = load i32*, i32** %int_num, align 8
  %12 = load i32, i32* %11, align 4
  %13 = load i32, i32* %start, align 4
  %14 = load i32, i32* %end, align 4
  %15 = sub nsw i32 %14, 1
  %16 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([37 x i8], [37 x i8]* @.str, i32 0, i32 0), i32 %12, i32 %13, i32 %15)
  %17 = load i32, i32* %start, align 4
  store i32 %17, i32* %i, align 4
  br label %18

; <label>:18                                      ; preds = %29, %0
  %19 = load i32, i32* %i, align 4
  %20 = load i32, i32* %end, align 4
  %21 = icmp slt i32 %19, %20
  br i1 %21, label %22, label %32

; <label>:22                                      ; preds = %18
  %23 = load i32, i32* %i, align 4
  %24 = sext i32 %23 to i64
  %25 = getelementptr inbounds [100 x i32], [100 x i32]* @arr, i64 0, i64 %24
  %26 = load i32, i32* %25, align 4
  %27 = load i32, i32* %local_sum, align 4
  %28 = add nsw i32 %27, %26
  store i32 %28, i32* %local_sum, align 4
  br label %29

; <label>:29                                      ; preds = %22
  %30 = load i32, i32* %i, align 4
  %31 = add nsw i32 %30, 1
  store i32 %31, i32* %i, align 4
  br label %18

; <label>:32                                      ; preds = %18
  %33 = call i32 @pthread_mutex_lock(%union.pthread_mutex_t* @sum_mutex) #4
  %34 = load i32, i32* @sum, align 4
  %35 = load i32, i32* %local_sum, align 4
  %36 = add nsw i32 %34, %35
  store i32 %36, i32* @sum, align 4
  %37 = call i32 @pthread_mutex_unlock(%union.pthread_mutex_t* @sum_mutex) #4
  call void @pthread_exit(i8* null) #5
  unreachable
                                                  ; No predecessors!
  %39 = load i8*, i8** %1, align 8
  ret i8* %39
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
  %start = alloca i32, align 4
  %thread_nums = alloca [4 x i32], align 16
  %threads = alloca [4 x i64], align 16
  store i32 0, i32* %1, align 4
  store i32 %argc, i32* %2, align 4
  store i8** %argv, i8*** %3, align 8
  store i32 0, i32* %i, align 4
  br label %4

; <label>:4                                       ; preds = %12, %0
  %5 = load i32, i32* %i, align 4
  %6 = icmp slt i32 %5, 100
  br i1 %6, label %7, label %15

; <label>:7                                       ; preds = %4
  %8 = load i32, i32* %i, align 4
  %9 = load i32, i32* %i, align 4
  %10 = sext i32 %9 to i64
  %11 = getelementptr inbounds [100 x i32], [100 x i32]* @arr, i64 0, i64 %10
  store i32 %8, i32* %11, align 4
  br label %12

; <label>:12                                      ; preds = %7
  %13 = load i32, i32* %i, align 4
  %14 = add nsw i32 %13, 1
  store i32 %14, i32* %i, align 4
  br label %4

; <label>:15                                      ; preds = %4
  %16 = call i32 @pthread_mutex_init(%union.pthread_mutex_t* @sum_mutex, %union.pthread_mutexattr_t* null) #4
  store i32 0, i32* %i, align 4
  br label %17

; <label>:17                                      ; preds = %33, %15
  %18 = load i32, i32* %i, align 4
  %19 = icmp slt i32 %18, 4
  br i1 %19, label %20, label %36

; <label>:20                                      ; preds = %17
  %21 = load i32, i32* %i, align 4
  %22 = load i32, i32* %i, align 4
  %23 = sext i32 %22 to i64
  %24 = getelementptr inbounds [4 x i32], [4 x i32]* %thread_nums, i64 0, i64 %23
  store i32 %21, i32* %24, align 4
  %25 = load i32, i32* %i, align 4
  %26 = sext i32 %25 to i64
  %27 = getelementptr inbounds [4 x i64], [4 x i64]* %threads, i64 0, i64 %26
  %28 = load i32, i32* %i, align 4
  %29 = sext i32 %28 to i64
  %30 = getelementptr inbounds [4 x i32], [4 x i32]* %thread_nums, i64 0, i64 %29
  %31 = bitcast i32* %30 to i8*
  %32 = call i32 @pthread_create(i64* %27, %union.pthread_attr_t* null, i8* (i8*)* @do_work, i8* %31) #4
  br label %33

; <label>:33                                      ; preds = %20
  %34 = load i32, i32* %i, align 4
  %35 = add nsw i32 %34, 1
  store i32 %35, i32* %i, align 4
  br label %17

; <label>:36                                      ; preds = %17
  store i32 0, i32* %i, align 4
  br label %37

; <label>:37                                      ; preds = %46, %36
  %38 = load i32, i32* %i, align 4
  %39 = icmp slt i32 %38, 4
  br i1 %39, label %40, label %49

; <label>:40                                      ; preds = %37
  %41 = load i32, i32* %i, align 4
  %42 = sext i32 %41 to i64
  %43 = getelementptr inbounds [4 x i64], [4 x i64]* %threads, i64 0, i64 %42
  %44 = load i64, i64* %43, align 8
  %45 = call i32 @pthread_join(i64 %44, i8** null)
  br label %46

; <label>:46                                      ; preds = %40
  %47 = load i32, i32* %i, align 4
  %48 = add nsw i32 %47, 1
  store i32 %48, i32* %i, align 4
  br label %37

; <label>:49                                      ; preds = %37
  %50 = load i32, i32* @sum, align 4
  %51 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str.1, i32 0, i32 0), i32 %50)
  store i32 0, i32* @sum, align 4
  store i32 0, i32* %i, align 4
  br label %52

; <label>:52                                      ; preds = %62, %49
  %53 = load i32, i32* %i, align 4
  %54 = icmp slt i32 %53, 100
  br i1 %54, label %55, label %65

; <label>:55                                      ; preds = %52
  %56 = load i32, i32* %i, align 4
  %57 = sext i32 %56 to i64
  %58 = getelementptr inbounds [100 x i32], [100 x i32]* @arr, i64 0, i64 %57
  %59 = load i32, i32* %58, align 4
  %60 = load i32, i32* @sum, align 4
  %61 = add nsw i32 %60, %59
  store i32 %61, i32* @sum, align 4
  br label %62

; <label>:62                                      ; preds = %55
  %63 = load i32, i32* %i, align 4
  %64 = add nsw i32 %63, 1
  store i32 %64, i32* %i, align 4
  br label %52

; <label>:65                                      ; preds = %52
  %66 = load i32, i32* @sum, align 4
  %67 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([21 x i8], [21 x i8]* @.str.2, i32 0, i32 0), i32 %66)
  %68 = call i32 @pthread_mutex_destroy(%union.pthread_mutex_t* @sum_mutex) #4
  call void @pthread_exit(i8* null) #5
  unreachable
                                                  ; No predecessors!
  %70 = load i32, i32* %1, align 4
  ret i32 %70
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
