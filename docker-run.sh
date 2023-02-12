 #!/bin/sh

git clone http://github.com/mikesir87/example-mern-stack-app

cd example-mern-stack-app

git checkout -b Containerised

touch Dockerfile

printf 
"FROM node:lts-alpine AS base \n
WORKDIR usr/local/app \n
\n
FROM base AS dev \n
FROM base AS react-build \n
COPY client/package.json client/yarn.lock ./ \n
RUN yarn install \n
COPY client/public ./public \n
COPY client/src ./src \n
RUN yarn build \n
\n
FROM base \n
COPY backend\package.json backend/yarn.lock ./ \nRUN yarn install \n COPY backend/src ./src \n
COPY --from=react-build /usr/local/app/build/ usr/local/app/src/static \n
CMD [\"node\", \"src/index.js\"]\n" 
> Dockerfile

touch .dockerfile

printf "node_modules \nbuild\n" > .dockerignore

touch docker-compose.yml

printf 
"services:\n
mongo:\n    image: mongo\n    volumes:\n      - mongo-data:/data/db\n  backend:\n    build:\n      context: ./\n      target: development\n    volumes:\n      - ./backend:/usr/local/app\n      - ~/.yarn:/root/.yarn\n    ports:\n      - 4000:4000\n    environment:\n      MONGO_HOST: mongo\n  client:\n    build:\n      context: ./\n      target: development\n    volumes:\n      - ./client:/usr/local/app\n      - ~/.yarn:/root/.yarn\n    ports:\n      - 3000:3000\n  mongo-express:\n    image: mongo-express \n    ports:\n      - 8081:8081 \nvolumes: \n  mongo-data:\n" 
> docker-compose.yml

docker run --network=workshop --network-alias=mongo mongo

docker compose up
