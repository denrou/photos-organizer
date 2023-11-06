 # Use an official lightweight Alpine image as a parent image
 FROM alpine:latest

 # Install necessary packages
 RUN apk add --no-cache bash findutils coreutils grep exiftool fdupes

 # Set the working directory in the container
 WORKDIR /usr/src

 # Copy the script into the container
 COPY organize_photos.sh .

 # Make the script executable
 RUN chmod +x organize_photos.sh

 WORKDIR /usr/src/photos

 # Run the script when the container launches
 CMD ["/usr/src/organize_photos.sh"]
