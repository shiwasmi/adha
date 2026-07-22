# Use official Tomcat 9 with Java 21 pre-installed
FROM tomcat:9.0.82-jdk21-temurin

# Set maintainer label (optional but good practice)
LABEL maintainer="sagar.chattar@example.com"

# Remove default ROOT app (optional, keeps container clean)
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Create a user for running the application
RUN useradd -m adha

# Copy your JAR file into the webapps directory
# Copy your JAR file into the webapps directory
COPY ./target/adha*.jar /usr/local/tomcat/webapps/

# Expose the default Tomcat port
EXPOSE 8080

# Set the user to 'adha' for security
USER adha

# Default command to run Tomcat
CMD ["catalina.sh", "run"]
