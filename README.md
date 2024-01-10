# Spring Boot REST Client Using GraalVM

### Overview

Spring Framework 6.1 introduced the RestClient, a new synchronous HTTP client. As the name suggests, RestClient offers the fluent API of WebClient with the infrastructure of RestTemplate. 

### Credits

This example is based on a [video/blog](https://www.danvega.dev/blog/rest-client-first-look) from Java Champion Dan Vega.

### Prerequisites

Java 21 is used for this example, specifically GraalVM for JDK 21. 

Download GraalVM for JDK 21 [here](https://www.oracle.com/java/technologies/downloads/#graalvmjava21) or use SDKMAN to install GraalVM.

You also have the option of using [script-friendly URLs](https://www.oracle.com/java/technologies/jdk-script-friendly-urls/) (including containers) to automate downloads.

Spring Boot 3.2.1 with native support is used and requires GraalVM 23.0.

Oracle Linux 8/9 `(x86_64)` was used as the underlying OS as some features are only available on `x86_64` platforms.

You can use choose to use `Maven` or `Gradle` as a build tool but `Maven` is highlighted in the example project.

You'll also need `git`.

If you intend on creating containers, `docker` or `podman` is required. See docs [here](https://docs.oracle.com/en/operating-systems/oracle-linux/podman/podman-InstallingPodmanandRelatedUtilities.html#podman-install).

Great, with all of the prerequisites in place, we can move to the next steps.

### Building the Project

Let's begin by cloning the demo repository:

```
$ git clone https://github.com/swseighman/Spring-RESTClient-Graal.git
```
Now change directory to the new project:

```
$ cd Spring-RESTClient-Graal
```

To build the project, execute:
```
$ ./mvnw clean package
```
The previous command generates an executable `.jar` file in the `target` directory.

This example uses the [JSONPlaceholder](https://jsonplaceholder.typicode.com/) service to provide a free API we can use for testing.

After building the project, start the application:

```
$ java -jar target/spring-rest-demo-0.0.1-SNAPSHOT.jar
```

Now access the endpoint:

```
http://localhost:8080/api/posts/1
```

You should see the output below:


```
{
    "id": 1,
    "userId": 1,
    "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
    "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
}
```

You can use the `posts.http` file to test the endpoints via a HTTP client. 

Next, build the native image executable:

```
$ ./mvnw -Pnative native:compile -DskipTests
```

>**NOTE:** If you're using an Oracle Cloud Infrastructure (OCI) instance, you may need to install the `libstdc` library:
>```
>$ sudo dnf config-manager --set-enabled ol9_codeready_builder
>$ sudo dnf install libstdc++-static -y


To run the native executable application, execute the following:

```
$ target/spring-restclient

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.2.1)

2024-01-04T15:07:49.909-05:00  INFO 66800 --- [main] c.e.s.SpringRestClientApplication          : Starting AOT-processed SpringRestClientApplication using Java 21.0.1 with PID 66800 

<...snip....>

2024-01-04T15:07:49.964-05:00  INFO 66800 --- [main] c.e.s.SpringRestClientApplication          : Started SpringRestClientApplication in 0.064 seconds (process running for 0.067)
```

Of course you can test the endpoints once again.

### Building a PGO Executable

You can optimize this native executable even further by applying Profile-Guided Optimizations (PGO).

With PGO you can collect the profiling data in advance and then feed it to the `native-image` tool, which will use this information to optimize the performance of the resulting binary.

>**NOTE:** PGO is available with Oracle GraalVM only.

First, we'll build an instrumented native executable using the following command: 
```
$ ./mvnw -Ppgo-inst native:compile -DskipTests
```

Next, you'll need to run the newly created instrumented app to generate the profile information:

```
$  target/spring-restclient-pgoinst
```

Exercise the app by accessing the endpoints and then stop the application. A profile will be generated in the root directory (`default.iprof`).

Finally, we'll build an optimized native executable (using the pom.xml profile to specify the path to the collected profile information):

```
$ ./mvnw -Ppgo native:compile -DskipTests
```

### Building a Static Native Image (x64 Linux only)

See [instructions](https://docs.oracle.com/en/graalvm/enterprise/21/docs/reference-manual/native-image/StaticImages/index.html#static-and-mostly-static-images) for building and installing the required libraries.

>**NOTE:** Confirmed the static image will build using `musl 10.2.1` (fails to build with `musl 11.2.1`).
>To download `musl 10.2.1`, click on the `more ...` link under **toolchains** and then choose the `10.2.1` directory.

After the process has been completed, copy `$ZLIB_DIR/libz.a` to `$GRAALVM_HOME/lib/static/linux-amd64/musl/`

Also add `x86_64-linux-musl-native/bin/` to your PATH.

Then execute:
```
$ ./mvnw -Pstatic native:compile -DskipTests
```

To run the static native executable application, execute the following:
```
$ target/spring-restclient-static
```


### Deployment Options

Included in this example are options to create/deploy your application using containers using traditional methods plus Buildpacks and Kubernetes.

#### Using Buildpacks

Cloud Native Buildpacks are also supported to generate a lightweight container containing a native executable.

To use Buildpacks, enter the following command:

```
$ ./mvnw -Pnative spring-boot:build-image
```

When the process is completed, you should have a new image:

```
$ docker images
REPOSITORY                                TAG              IMAGE ID       CREATED         SIZE
spring-restclient                         0.0.1-SNAPSHOT   ce4805b5b97e   44 years ago   125MB
```

To start the container, execute:

```
$ docker run --rm -p 8080:8080 spring-restclient:0.0.1-SNAPSHOT
```

