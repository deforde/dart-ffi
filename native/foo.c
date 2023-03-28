int foo() {
    return 42;
}

int bar(int i) {
    return i + 1;
}

int baz(int *i) {
    (*i)+=2;
    return 0;
}

int foo2(int arr[10]) {
    for (int i = 0; i < 10; i++) {
        arr[i] += 1;
    }
    return 0;
}
