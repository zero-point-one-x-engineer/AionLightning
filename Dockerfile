# syntax=docker/dockerfile:1

FROM eclipse-temurin:8-jdk AS builder

WORKDIR /src

# The project is built with the bundled Ant (Tools/Ant). Only source dirs + ant are needed.
COPY AL-Commons AL-Commons
COPY AL-Game AL-Game
COPY AL-Login AL-Login
COPY AL-Chat AL-Chat
COPY Tools/Ant Tools/Ant

# Build order matters: commons first, then the three servers.
# Each server's build.xml copies its libs/*.jar (which includes al-commons.jar) into the dist.
RUN chmod +x Tools/Ant/bin/ant && \
    cd AL-Commons && ../Tools/Ant/bin/ant && \
    cd /src && \
    cp AL-Commons/build/al-commons.jar AL-Login/libs/al-commons.jar && \
    cp AL-Commons/build/al-commons.jar AL-Game/libs/al-commons.jar && \
    cp AL-Commons/build/al-commons.jar AL-Chat/libs/al-commons.jar && \
    cd AL-Login && ../Tools/Ant/bin/ant && \
    cd /src/AL-Game && ../Tools/Ant/bin/ant && \
    cd /src/AL-Chat && ../Tools/Ant/bin/ant

# Runtime: the game server's javaagent (al-commons.jar) rewrites loaded classes and
# needs Java 7's split-verifier behavior, so stay on a Java 7 JDK image.
FROM azul/zulu-openjdk:7

RUN mkdir -p /opt/aion/login /opt/aion/game /opt/aion/chat

COPY --from=builder /src/AL-Login/build/dist/AL-Login/ /opt/aion/login/
COPY --from=builder /src/AL-Game/build/dist/AL-Game/   /opt/aion/game/
COPY --from=builder /src/AL-Chat/build/dist/AL-Chat/   /opt/aion/chat/

COPY docker/entrypoint.sh /opt/aion/entrypoint.sh

WORKDIR /opt/aion
ENTRYPOINT ["/opt/aion/entrypoint.sh"]