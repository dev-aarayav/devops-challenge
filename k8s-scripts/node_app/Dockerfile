# Use the official Node.js image
FROM node:latest

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install app dependencies
RUN npm install

# Copy the app files to the working directory
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Define the command to start the app
CMD ["node", "app.js"]
