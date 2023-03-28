import 'dart:ffi'; // For FFI
import 'dart:io'; // For Platform.isX

class FooInterface {
    DynamicLibrary fooLib = DynamicLibrary.open("native/libfoo.so");

    late int Function() foo;
    late int Function(int) bar;

    FooInterface() {
        foo = fooLib.lookup<NativeFunction<Int32 Function()>>("foo").asFunction();
        bar = fooLib.lookup<NativeFunction<Int32 Function(Int32)>>("bar").asFunction();
    }
}

void main() {
    var lib = FooInterface();
    print("foo() = ${lib.foo()}");
    print("bar(1) = ${lib.bar(1)}");
}
