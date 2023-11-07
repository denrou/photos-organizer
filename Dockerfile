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

# Set up the cron job to run at noon every day
# The format is:
# minute hour day month day-of-week command
# so "0 12 * * *" means "at 12:00 on every day"
RUN echo '0 12 * * * /usr/src/organize_photos.sh > /proc/1/fd/1 2>&1' > /etc/crontabs/root

# Give execution rights on the cron job
RUN chmod 0644 /etc/crontabs/root

WORKDIR /usr/src/photos

# Start the cron daemon as the main process of the container
CMD crond -f -d 8
