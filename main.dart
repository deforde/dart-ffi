import 'dart:ffi'; // For FFI
import 'dart:io'; // For Platform.isX

final DynamicLibrary fooLib = Platform.isLinux
    ? DynamicLibrary.open('native/libfoo.so')
    : DynamicLibrary.process();

final int Function() foo = fooLib
    .lookup<NativeFunction<Int32 Function()>>('foo')
    .asFunction();

void main() {
    print("foo() = ${foo()}");
}
