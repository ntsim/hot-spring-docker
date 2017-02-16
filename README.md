## Hot Reload Spring Boot in Docker

Simply run:

    docker-compose up -d
    
Spring Boot will be fired up with local devtools using Gradle and classpath changes should be detected properly.
This is a more robust mechanism than the remote devtools equivalent:

- Behaviour should be the same as if it were in IntelliJ.
- Does not crash if excessive reloads are performed.
- The reload time is a lot faster.

All this Docker setup is doing is mapping the project directory into Docker and running `./gradlew`. Very simple, but 
the importance is in the volume mapping which allows us to utilise local devtools.