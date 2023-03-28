import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

class BazRetTy {
    int ret;
    int i;
    BazRetTy(this.ret, this.i);
}

class FooInterface {
    DynamicLibrary fooLib = DynamicLibrary.open("native/libfoo.so");

    late int Function() foo_native;
    late int Function(int) bar_native;
    late int Function(Pointer<Int32>) baz_native;


    int foo() {
        return foo_native();
    }

    int bar(int i) {
        return bar_native(i);
    }

    BazRetTy baz(int i) {
        final p = malloc<Int32>();
        p.value = i;
        final ret = baz_native(p);
        i = p.value;
        malloc.free(p);
        return BazRetTy(ret, i);
    }

    FooInterface() {
        foo_native = fooLib.lookup<NativeFunction<Int32 Function()>>("foo").asFunction();
        bar_native = fooLib.lookup<NativeFunction<Int32 Function(Int32)>>("bar").asFunction();
        baz_native = fooLib.lookup<NativeFunction<Int32 Function(Pointer<Int32>)>>("baz").asFunction();
    }
}

void main() {
    var lib = FooInterface();
    print("foo() = ${lib.foo()}");
    print("bar(1) = ${lib.bar(1)}");
    var baz_ret = lib.baz(1);
    print("baz(1) = ${baz_ret.i}");
}
