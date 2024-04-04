import express from 'express'
import { createServer } from 'http'
import { WebSocketServer } from 'ws'
import { useServer } from 'graphql-ws/lib/use/ws'
import { ApolloServer } from '@apollo/server'
import { expressMiddleware } from '@apollo/server/express4'
import cors from 'cors'
import bodyParser from 'body-parser'
import schema from './schema'

const initApollo = async () => {
  const app = express()
  const httpServer = createServer(app)

  const wsServer = new WebSocketServer({
    server: httpServer,
    path: '/graphql',
  })

  useServer({ schema }, wsServer)

  const server = new ApolloServer({ schema })

  await server.start()

  app.use(
    '/graphql',
    cors<cors.CorsRequest>(),
    bodyParser.json(),
    expressMiddleware(server)
  )

  httpServer.listen(4001, () => {
    console.log(`Server running on http://localhost:4001/graphql`)
  })
}

initApollo()
