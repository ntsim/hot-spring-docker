# Hot reloading Spring Boot application in Docker

Proof-of-concept that we can run Spring Boot's devtools locally within a Docker container without 
needing to use remote devtools.

Spring Boot will be fired up with local devtools using Gradle and classpath changes should be 
detected properly.

This is a more robust mechanism than the remote devtools equivalent as:

- Behaviour should be the same as if it were in IntelliJ.
- Does not crash if excessive reloads are performed.
- The reload time is a lot faster.

Simply run:

    docker-compose up
    
Then test by changing something e.g. adding a `System.out.println` to `HomeController`, and 
triggering a restart by building the project in IntelilJ. You should be able to see restarts 
occurring in the Docker logs.

## Explanation

### Volume mapping

The key component is the mapping of the `app` directory into the Docker container. This allows us 
to use the Gradle wrapper from within the Docker container itself. 

To make this work we are looking to run `./gradlew bootRun`, which boots up the Spring Boot 
application.

### File permissions for volume

We also need to map this volume with the host machine user as the owner. A naive mapping would 
result in `root` owning the project and file permission conflicts would swiftly occur when we try
to work with the Gradle wrapper from outside of the Docker container (e.g. when building the 
project through IntelliJ).

As such, we assign ownership of the mapped volume to uid 1000 (referred to as `appuser` in the 
Docker container), which will usually refer to the host machine's current user if there is only 
one user on the machine.

If you are using a user that does not have uid=1000, then you will need to tweak the `Dockerfile`
with whatever uid that is required.

### Gradle caching

As Gradle has very aggressive caching, this also causes issues if we were to naively run `./gradlew`
from within the container. The container's Gradle process will gain the cache lock and will not 
release it. This means we won't be able to work with the Gradle wrapper outside of the Docker
container (similar situation to [File permissions for volume](#file-permissions-for-volume)).

Instead, we simply have to supply a different project cache directory to the Docker container's 
`./gradlew` command via `--project-cache-dir`. In this instance we use a `/tmp` directory. This 
means that there will be two separate cache directories, one in the Docker container, and one in the
actual project. As we should not be running any other `./gradlew` tasks in the Docker container,
this _should_ be okay.

## Caveats

- Can't re-use the project's `.gradle` cache directory. For large projects with large dependencies
  this could potentially eat into disk space. It could also cause weird build bugs in some undefined
  edge cases (not sure exactly).
- Has not been tested on Docker for Windows.
