import 'dart:ffi'; // For FFI
import 'dart:io'; // For Platform.isX

class FooInterface {
    DynamicLibrary fooLib = DynamicLibrary.open("native/libfoo.so");
    late int Function() foo;

    FooInterface() {
        foo = fooLib
            .lookup<NativeFunction<Int32 Function()>>("foo")
            .asFunction();
    }
}

void main() {
    var lib = FooInterface();
    print("foo() = ${lib.foo()}");
}
