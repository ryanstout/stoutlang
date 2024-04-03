# Why WebAssembly

WebAssembly is a low-level, binary instruction format for a stack-based virtual machine, designed as a portable compilation target for high-level languages. It enables the execution of code as fast as running native machine code, aiming to improve the performance and security of web applications.

## Static compilation and standard API.

Docker was a solution to a problem that shouldn't exist. In a perfect world the binary file for any program would be able to run on any machine, accesss compatiable system API's from any OS, and be able to be sandboxed by a single command from the operating system.

Docker was built because none of these were possible, so instead containers were invented. Over the past 10 years, WebAssembly (and partly libriaries like musl) have solved these issues.


### Static Linking

Part of docker's job was to build all of the things you need to run your code. (The dependencies) These dependencies are loaded in at run time via dynamic linking. In order for dynamic linking to work, you needed to have the correct libraries installed. This pushes the work of preparing the dependencies onto the user of the program. (Or the Dockerfile) maintainer.

Static linking solves this issue. Just stick all of the dependencies into the binary. In the 80's, the few extra megabytes might matter, but today the complexity isn't worth the trade-off.

### Platform Independence

Traditionally, each operating system (and sometimes operating system version) required changes to your code to support different system API's. (reading/writing files, making socket connections, etc...). WASI is a project that creates a standard API layer for WebAssembly programs to call into the system. This achieves similar goals to the JVM, but in a much ligher way. (Through a light code translation layer instead of a VM)

### Sandboxing

Traditionally containers achieve isolation of processes (sandboxing) via kernel level tools like cgroups and namespaces. WebAssembly can achieve the same results with better performance at the code translation layer. This also allows for more fine grained security.

### Edge Servers

Hosting services on the edge provides lower latency, but isn't typically cost effective if the service has to be spun up all of the time. Edge services have relied on using the JavaScript VM to handle requests. Any language/platform with slower startup time isn't a viable option for the edge. WebAssembly has near instant start up and native run time performance. Edge services also require very low memory use, something WebAssembly delivers.