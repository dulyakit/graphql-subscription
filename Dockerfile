# Use the official Node.js image as a base
FROM node:20

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN yarn install

# Copy the rest of the application code to the working directory
COPY . .

# Expose the port on which the Node.js application will run
EXPOSE 3000

# Command to run the Node.js application
CMD ["node", "server.ts"] 
