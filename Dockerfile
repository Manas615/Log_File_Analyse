FROM ubuntu:24.04

# Install bash and any dependencies (e.g., coreutils for wc, grep, awk, etc.)
RUN apt-get update && apt-get install -y bash coreutils grep gawk

# Set working directory
WORKDIR /app

# Copy the script and (optionally) a sample log file into the container
COPY log_analyzer.sh .
COPY sample_log.log .

# Make sure the script is executable
RUN chmod +x log_analyzer.sh

# Set the default command to run the script (can be overridden at runtime)
CMD ["./log_analyzer.sh", "sample_log.log"]
