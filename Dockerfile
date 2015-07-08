FROM ubuntu:14.04

MAINTAINER warwing@gmx.de

# this is a non-interactive automated build - avoid some warning messages
ENV DEBIAN_FRONTEND noninteractive

ENV MAVEN_VERSION=3.2.5
ENV MAVEN_CHECKSUM=41009327d5494e0e8970b25b77ffed8934cd7ca1

ENV JAVA_VERSION=1.8.0_45
ENV JAVA_DOWNLOAD_FILE=jdk-8u45-linux-x64.tar.gz
ENV JAVA_DOWNLOAD_FOLDER=http://download.oracle.com/otn-pub/java/jdk/8u45-b14/

# update dpkg repositories
RUN apt-get update

# install wget
RUN apt-get install -y wget

# get maven
RUN wget --no-verbose -O /tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
# verify checksum
RUN echo "$MAVEN_CHECKSUM apache-maven-$MAVEN_VERSION-bin.tar.gz" | sha1sum -c

# install maven
RUN tar xzf /tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-$MAVEN_VERSION /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz
ENV MAVEN_HOME /opt/maven

# install git
RUN apt-get install -y git

# install vim
RUN apt-get install -y vim

# remove download archive files
RUN apt-get clean


# download java, accepting the license agreement
RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/$JAVA_DOWNLOAD_FILE $JAVA_DOWNLOAD_FILE$JAVA_DOWNLOAD_FOLDER

# unpack java
RUN mkdir /opt/java-oracle && tar -zxf /tmp/$JAVA_DOWNLOAD_FILE -C /opt/java-oracle/
ENV JAVA_HOME /opt/java-oracle/jdk$JAVA_VERSION
ENV PATH $JAVA_HOME/bin:$PATH

# configure symbolic links for the java and javac executables
RUN update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 20000 && update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 20000

# copy jenkins war file to the container
ADD http://mirrors.jenkins-ci.org/war/latest/jenkins.war /opt/jenkins.war
RUN chmod 644 /opt/jenkins.war
ENV JENKINS_HOME /jenkins

# configure the container to run jenkins, mapping container port 8080 to that host port
ENTRYPOINT ["java", "-jar", "/opt/jenkins.war"]
EXPOSE 8080

CMD [""]
