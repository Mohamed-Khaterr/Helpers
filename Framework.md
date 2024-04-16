# Framework

### Build Settings
- `Mach-O Type`
    1. **Executable** - compiled machine targeted program ready to be run in binary format (it like an actual application).
    2. **Dynamic Library** - are linked during runtime -- a program with references to a dynamic library will load and link with the library when it starts up (or on demand).
    3. Static Library - files are linked at build time. code is copied into the executable. Code in the library that isn't referenced by your program is removed. A program with only static libraries doesn't have any dependencies during runtime.

- `Embded`
    1. Embd & Sign
    2. Embd Without Sign
    3. Do Not Embd

- `Defines Modules` set to `NO` means Objective-C code will be not valid in the framework and you can delete Header file.

- `SKIP_INSTALL` set to `NO` to make framework copied in Archive.

- `Build Libraries for Distribution` set to `YES` Ensures that your libraries are built for distribution, And it will generate a binary interface for you. This step is to make sure your framework compatible with different compiler version of Xcode versions.

> **Binary Frameworks**: A binary framework is already compiled source code with resources with a defined interface that you can use in your apps. It comes in two flavors: a static library and a dynamic framework.

> **XCFrameworks** is a new supported way to distribute binary frameworks, available from Xcode 11.

> **Dynamic Frameworks** must be **Embd** into Target otherwise it will crash. In other hand the **Static Frameworks** not need to **Embd** into Target if it doesn't contain resources like images, nibs, storyboards and etc.

### Swift Package Manager - SPM
By default you don't have to declare the linking type of library (Static, Dynamic) explicitly.
> Package library is Static by default means that library is linked at *Compile time*

### Library Versions (Semantic Versioning)
- **Major Version Numbe**r: Breaking changes, to the API so this is any thing that cause the client to have to update the library example of rename a method or remove a method etc. and it represent in the first number `2.0.0`

- **Minor Version Number**: Compatible additions, like functionality is added without break existing clint and the client doesn't need to update the code, and it represent in the second number `2.3.0`

- **Batch Version Number**: Bug fixes, that not have any semantic changes, and it represent in the third number `2.3.5`