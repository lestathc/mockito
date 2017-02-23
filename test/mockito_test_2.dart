// Copyright 2016 Dart Mockito authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:mockito/mockito.dart';
import 'package:mockito/src/mock.dart'
    show resetMockitoState, throwOnMissingStub;
import 'package:test/test.dart';

expectFail(String expectedMessage, expectedToFail()) {
  try {
    expectedToFail();
    fail("It was expected to fail!");
  } catch (e) {
    if (!(e is TestFailure)) {
      throw e;
    } else {
      if (expectedMessage != e.message) {
        throw new TestFailure("Failed, but with wrong message: ${e.message}");
      }
    }
  }
}

typedef void UnaryFunction();

class HasCallback {
  final UnaryFunction _fooCallback;
  final UnaryFunction _barCallback;

  HasCallback(this._fooCallback, this._barCallback);

  void foo() {
    // Do something
    _fooCallback();
  }

  void bar() {
    // Do something
    _barCallback();
  }
}

class FunctionProvider {
  void abc() {
    print('abc is called');
  }
  void xyz() {
    print('xyz is called');
  }
}

HasCallback toBeTested(FunctionProvider funcProvider) {
  // Do something
  return new HasCallback(funcProvider.abc, funcProvider.xyz);
}

class UnaryFunctionClass {
  void call() {}
}

class MockFunctionProvider extends Mock implements FunctionProvider {}

class MockUnaryFunctionClass extends Mock implements UnaryFunctionClass {}

void main() {
  tearDown(() {
    // In some of the tests that expect an Error to be thrown, Mockito's
    // global state can become invalid. Reset it.
    resetMockitoState();
  });

  test('obj.foo is not equal to obj.foo()', () {
    var funcProvider = new MockFunctionProvider();
    expect(funcProvider.foo, null);
    verify(funcProvider.foo);

    funcProvider.foo();
    verify(funcProvider.foo());
  });

  test('using obj.foo as first class citizen is not possible now', () {
    expectFail('The method \'call\' was called on null', () {
      try {
        var funcProvider = new MockFunctionProvider();
        var hasCallback = toBeTested(funcProvider);
        hasCallback.foo();
        verify(funcProvider.abc());
        hasCallback.bar();
        verify(funcProvider.xyz());
      } catch (_) {
        throw new TestFailure('The method \'call\' was called on null');
      }
    });
  });

  test('to test member function as fisrt class citizen, '
      'need to write more code',
      () {
    var funcProvider = new MockFunctionProvider();
    var abc = new MockUnaryFunctionClass();
    var xyz = new MockUnaryFunctionClass();
    when(funcProvider.abc).thenReturn(abc);
    when(funcProvider.xyz).thenReturn(xyz);
    var hasCallback = toBeTested(funcProvider);
    hasCallback.foo();
    verify(abc.call());
    hasCallback.bar();
    verify(xyz.call());
  });
}
