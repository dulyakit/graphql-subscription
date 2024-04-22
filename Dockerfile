# Use the official Node.js image as a base
FROM node:20

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN yarn -q install --production=false --silent && \
yarn run build && \
yarn -q install --production=true --silent && \
yarn cache clean

# Copy the rest of the application code to the working directory
COPY . .

# Command to run the Node.js application
CMD ["yarn", "run", "dev"] 
