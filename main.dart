import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

class BazRetTy {
    int ret;
    int i;
    BazRetTy(this.ret, this.i);
}

class Foo2RetTy {
    int ret;
    List<int> arr;
    Foo2RetTy(this.ret, this.arr);
}

typedef CallbackTy = Int32 Function(Int32);

class CallbackHandlerStatic {
    static CallbackHandlerBase? handler_obj = null;
    CallbackHandlerStatic(h_obj) {
        handler_obj = h_obj;
    }
    static int CallbackHandlerStaticImpl(int i) {
        return handler_obj!.CallbackHandler(i);
    }
    Pointer<NativeFunction<CallbackTy>> getFuncPtr() {
        return Pointer.fromFunction<CallbackTy>(CallbackHandlerStaticImpl, 0);
    }
}

abstract class CallbackHandlerBase {
    static late CallbackHandlerStatic static_handler;
    int CallbackHandler(int i);
    Pointer<NativeFunction<CallbackTy>> getFuncPtr() {
        return static_handler.getFuncPtr();
    }
    CallbackHandlerBase() {
        static_handler = CallbackHandlerStatic(this);
    }
}

class CallbackHandlerImpl extends CallbackHandlerBase {
    List<int> vals = [];
    int CallbackHandler(int i) {
        vals.add(i * i);
        return i * i;
    }
}

class FooInterface {
    final DynamicLibrary fooLib = DynamicLibrary.open("native/libfoo.so");

    late int Function() foo_native;
    late int Function(int) bar_native;
    late int Function(Pointer<Int32>) baz_native;
    late int Function(Pointer<Int32>) foo2_native;
    late int Function(int, Pointer<NativeFunction<CallbackTy>>) bar2_native;
    late void Function(Pointer<Uint8>) baz2_native;

    int foo() {
        final ret = foo_native();
        return ret;
    }

    int bar(int i) {
        final ret = bar_native(i);
        return ret;
    }

    BazRetTy baz(int i) {
        final p = malloc<Int32>();
        p.value = i;
        final ret = baz_native(p);
        i = p.value;
        malloc.free(p);
        return BazRetTy(ret, i);
    }

    Foo2RetTy foo2(List<int> arr) {
        final p = malloc<Int32>(arr.length);
        p.asTypedList(arr.length).setAll(0, arr);
        final ret = foo2_native(p);
        arr = p.asTypedList(arr.length).toList();
        malloc.free(p);
        return Foo2RetTy(ret, arr);
    }

    int bar2(int i, Pointer<NativeFunction<CallbackTy>> callback) {
        return bar2_native(i, callback);
    }

    void baz2(String str) {
        final c_str = str.toNativeUtf8().cast<Uint8>();
        return baz2_native(c_str);
    }

    FooInterface() {
        foo_native = fooLib.lookup<NativeFunction<Int32 Function()>>("foo").asFunction();
        bar_native = fooLib.lookup<NativeFunction<Int32 Function(Int32)>>("bar").asFunction();
        baz_native = fooLib.lookup<NativeFunction<Int32 Function(Pointer<Int32>)>>("baz").asFunction();
        foo2_native = fooLib.lookup<NativeFunction<Int32 Function(Pointer<Int32>)>>("foo2").asFunction();
        bar2_native = fooLib.lookup<NativeFunction<Int32 Function(Int32, Pointer<NativeFunction<CallbackTy>>)>>("bar2").asFunction();
        baz2_native = fooLib.lookup<NativeFunction<Void Function(Pointer<Uint8>)>>("baz2").asFunction();
    }
}

void main() {
    var lib = FooInterface();

    print("foo() = ${lib.foo()}");
    print("bar(1) = ${lib.bar(1)}");

    var baz_ret = lib.baz(1);
    print("baz(1) = ${baz_ret.i}");

    var foo2_ret = lib.foo2([0,1,2,3,4,5,6,7,8,9]);
    print("foo2 = ${foo2_ret.arr}");

    var callback_handler = CallbackHandlerImpl();
    var bar2_ret = lib.bar2(3, callback_handler.getFuncPtr());
    print("bar2 = ${bar2_ret}");
    bar2_ret = lib.bar2(4, callback_handler.getFuncPtr());
    print("bar2 = ${bar2_ret}");
    bar2_ret = lib.bar2(5, callback_handler.getFuncPtr());
    print("bar2 = ${bar2_ret}");
    print(callback_handler.vals);

    lib.baz2("my string");
}
