# Use iniweb OWASP ZAP stable Docker image as the base
FROM iniweb/owasp-zap2docker-stable:latest

# Fix the outdated repositories
RUN sed -i 's/archive.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list

# Install Python and pip
RUN apt-get update && apt-get install -y python3 python3-pip

# Download the Python 3.4-compatible get-pip.py script and upgrade pip
RUN curl https://bootstrap.pypa.io/pip/3.4/get-pip.py -o get-pip.py && python3 get-pip.py

# Install boto3 for interacting with AWS SQS
RUN pip3 install boto3

# Copy the script that polls SQS and runs ZAP
COPY poll_and_scan.py /poll_and_scan.py

# Set the entrypoint to run the script
ENTRYPOINT ["python3", "/poll_and_scan.py"]
