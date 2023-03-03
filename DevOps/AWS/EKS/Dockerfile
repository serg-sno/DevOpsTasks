#-------------------------------------------------------------------------------------------------
# Description : Docker build file
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

FROM public.ecr.aws/amazoncorretto/amazoncorretto:17

EXPOSE 5000
RUN mkdir -p /opt/target
COPY target/DevOpsTasks-0.0.1-SNAPSHOT.jar /opt/target/
WORKDIR /opt/target
CMD ["java", "-jar", "DevOpsTasks-0.0.1-SNAPSHOT.jar"]
