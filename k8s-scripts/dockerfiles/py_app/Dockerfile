# Use the official Python image
FROM python:latest

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy the requirements file to the working directory
COPY requirements.txt ./

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app files to the working directory
COPY . .

# Expose the port the app runs on
EXPOSE 5000

# Define the command to start the app
CMD ["python", "app.py"]
