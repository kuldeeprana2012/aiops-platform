FROM node:20-alpine
WORKDIR /usr/src/app
COPY package.json package-lock.json* ./
RUN npm install --verbose
COPY . .
EXPOSE 4000
CMD ["npm", "start"]
